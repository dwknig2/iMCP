import AppKit
import Foundation

enum Cursor {
    private static var serverCommandPath: String {
        Bundle.main.bundleURL
            .appendingPathComponent("Contents/MacOS/imcp-server")
            .path
    }

    /// Builds the Cursor MCP install deeplink URL. Cursor expects config to be base64-encoded JSON
    /// with the same shape as mcp.json: { "iMCP": { "command": "<path>" } }.
    static func installDeeplinkURL() -> URL? {
        let config = ["iMCP": ["command": serverCommandPath]]
        guard let data = try? JSONSerialization.data(withJSONObject: config),
              let encoded = String(data: data, encoding: .utf8)
        else { return nil }
        let base64 = Data(encoded.utf8).base64EncodedString()
        let urlString = "cursor://anysphere.cursor-deeplink/mcp/install?name=iMCP&config=\(base64)"
        return URL(string: urlString)
    }

    /// Returns a JSON snippet suitable for pasting into ~/.cursor/mcp.json or .cursor/mcp.json.
    /// Caller can merge the "iMCP" entry into existing mcpServers.
    static func mcpJSONSnippet() -> String {
        let snippet: [String: Any] = [
            "mcpServers": [
                "iMCP": [
                    "command": serverCommandPath,
                ],
            ],
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: snippet),
              let string = String(data: data, encoding: .utf8)
        else { return "{\"mcpServers\":{\"iMCP\":{\"command\":\"\(serverCommandPath)\"}}}" }
        return string
    }

    /// Opens the Cursor MCP install deeplink so Cursor can prompt to add the server.
    static func openInstallDeeplink() {
        guard let url = installDeeplinkURL() else { return }
        NSWorkspace.shared.open(url)
    }

    /// Copies the Cursor mcp.json snippet to the pasteboard.
    static func copyMCPJSONSnippetToPasteboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(mcpJSONSnippet(), forType: .string)
    }
}
