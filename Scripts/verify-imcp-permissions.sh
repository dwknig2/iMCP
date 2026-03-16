#!/usr/bin/env bash
# List system permissions iMCP needs and open System Settings so you can verify iMCP is allowed.
# Run after installing iMCP.app. Grant any missing permissions when the app prompts or in System Settings.
set -euo pipefail

BUNDLE_ID="co.dododo.iMCP"
TCC_USER="$HOME/Library/Application Support/com.apple.TCC/TCC.db"

echo "=== iMCP system permissions ($BUNDLE_ID) ==="
echo ""

# Query TCC for current app if readable
if [[ -f "$TCC_USER" ]]; then
  GRANTED=$(sqlite3 "$TCC_USER" "SELECT service FROM access WHERE client = '$BUNDLE_ID' AND auth_value = 2;" 2>/dev/null || true)
  if [[ -n "$GRANTED" ]]; then
    echo "Currently allowed for iMCP:"
    echo "$GRANTED" | while read -r s; do echo "  • $s"; done
    echo ""
  else
    echo "No TCC permissions found for $BUNDLE_ID yet (app will prompt when you use each feature)."
    echo ""
  fi
fi

echo "Permissions the app may request (when you enable each in iMCP Settings or use a tool):"
echo "  • Local Network     – required for MCP (Bonjour); prompt on first client connect"
echo "  • Contacts          – enable Contacts in iMCP"
echo "  • Calendars         – enable Calendar in iMCP"
echo "  • Reminders         – enable Reminders in iMCP"
echo "  • Location          – enable Location / Maps in iMCP"
echo "  • Camera            – when an MCP tool uses camera"
echo "  • Microphone        – when an MCP tool uses microphone"
echo "  • Files (Messages)  – when you enable Messages and select chat.db"
echo "  • Automation        – optional (e.g. Terminal); if you use Apple Events"
echo ""
echo "To verify or fix: System Settings → Privacy & Security → [category] → ensure iMCP is allowed."
echo ""

# Open Privacy & Security on macOS 13+
if [[ "$(uname)" == "Darwin" ]]; then
  if open "x-apple.systempreferences:com.apple.preference.security?Privacy" 2>/dev/null; then
    echo "Opened System Settings → Privacy & Security"
  else
    echo "Open System Settings → Privacy & Security manually to review permissions."
  fi
fi

echo ""
echo "Quick test: run iMCP, connect from Cursor/Claude; grant Local Network when prompted."
