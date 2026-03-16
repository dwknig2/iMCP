# Patches

## MCP swift-sdk: NetworkTransport reconnection continuation misuse

**Issue:** The app can crash with `EXC_BREAKPOINT (SIGTRAP)` in `CheckedContinuation.resume(throwing:)` when the network transport handles reconnection (`handleReconnection` in `NetworkTransport.swift`). Continuations may be resumed more than once or leaked.

**App workaround:** The app disables reconnection per connection in `ServerController.swift` (`reconnectionConfig: .disabled`), so failed connections do not use the reconnection path and the crash is avoided.

**SDK patch (optional if re-enabling reconnection):** The script adds a single-resume guard and related fixes in `handleReconnection`. After a package reset, run from repo root:

```bash
bash Scripts/patch-mcp-sdk-reconnection.sh
```

The script patches the swift-sdk checkout in `build/SourcePackages/checkouts/swift-sdk` and, if present, in `~/Library/Developer/Xcode/DerivedData/iMCP-*/SourcePackages/checkouts/swift-sdk`.

**Upstream:** Consider opening an issue or PR on [modelcontextprotocol/swift-sdk](https://github.com/modelcontextprotocol/swift-sdk) so a future release fixes continuation handling in reconnection.
