#!/usr/bin/env bash
# Re-apply the NetworkTransport handleReconnection single-resume guard to the MCP swift-sdk checkout.
# Run from repo root after "Reset Package Caches" or a fresh clone.
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
FILE_REL="Sources/MCP/Base/Transports/NetworkTransport.swift"

patch_one() {
    local dir="$1"
    local f="$dir/$FILE_REL"
    if [[ ! -f "$f" ]]; then
        return 0
    fi
    if grep -q "ResumeGuard" "$f" 2>/dev/null; then
        echo "  Already patched: $f"
        return 0
    fi
    chmod u+w "$f" 2>/dev/null || true
    python3 - "$f" << 'PY'
import sys
path = sys.argv[1]
with open(path, "r") as f:
    content = f.read()

old = """        private func handleReconnection(
            error: Swift.Error,
            continuation: CheckedContinuation<Void, Swift.Error>,
            context: String
        ) async {
            if !isStopping,"""

new = """        private func handleReconnection(
            error: Swift.Error,
            continuation: CheckedContinuation<Void, Swift.Error>,
            context: String
        ) async {
            // Ensure we only resume the continuation once (avoids EXC_BREAKPOINT in CheckedContinuation.resume(throwing:)).
            final class ResumeGuard: @unchecked Sendable {
                var hasResumed = false
            }
            let resumeGuard = ResumeGuard()

            if !isStopping,"""

if "ResumeGuard" in content:
    sys.exit(0)
if old not in content:
    sys.stderr.write("  Pattern not found (SDK version may differ): " + path + "\n")
    sys.exit(1)
content = content.replace(old, new, 1)

old2 = """                Task {
                    try? await Task.sleep(for: .seconds(delay))
                    if !isStopping {
                        // Cancel the current connection before attempting to reconnect."""
new2 = """                Task {
                    try? await Task.sleep(for: .seconds(delay))
                    if resumeGuard.hasResumed { return }
                    resumeGuard.hasResumed = true
                    if !isStopping {
                        // Cancel the current connection before attempting to reconnect."""
content = content.replace(old2, new2, 1)

old3 = """            } else {
                // Not configured to reconnect, exceeded max attempts, or stopping
                self.connection.cancel()  // Ensure connection is cancelled
                continuation.resume(throwing: error)
            }
        }"""
new3 = """            } else {
                // Not configured to reconnect, exceeded max attempts, or stopping
                if resumeGuard.hasResumed { return }
                resumeGuard.hasResumed = true
                self.connection.cancel()  // Ensure connection is cancelled
                continuation.resume(throwing: error)
            }
        }"""
content = content.replace(old3, new3, 1)

with open(path, "w") as f:
    f.write(content)
PY
    local ret=$?
    [[ $ret -eq 0 ]] && echo "  Patched: $f"
    return $ret
}

echo "Patching MCP swift-sdk NetworkTransport (handleReconnection single-resume guard)..."
patched=0
patch_one "$REPO_ROOT/build/SourcePackages/checkouts/swift-sdk" && patched=1 || true
for dd in "$HOME/Library/Developer/Xcode/DerivedData"/iMCP-*/SourcePackages/checkouts/swift-sdk; do
    [[ -d "$dd" ]] || continue
    patch_one "$dd" && patched=1 || true
done
if [[ $patched -eq 0 ]]; then
    echo "No swift-sdk checkout found. Build the project once (Xcode or xcodebuild) to fetch packages, then run this script again."
    exit 1
fi
echo "Done. Rebuild the app (Xcode or xcodebuild) to use the patched SDK."
