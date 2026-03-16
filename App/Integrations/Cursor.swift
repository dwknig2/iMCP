import AppKit
import Foundation

enum Cursor {
    private static var serverCommandPath: String {
        Bundle.main.bundleURL
            .appendingPathComponent("Contents/MacOS/imcp-server")
            .path
    }

    /// Builds the Cursor MCP install deeplink URL. The `config` parameter must be the server
    /// configuration object only (e.g. `{"command": "..."}`); the `name` query param identifies the server.
    static func installDeeplinkURL() -> URL? {
        let config = ["command": serverCommandPath]
        guard let data = try? JSONSerialization.data(withJSONObject: config),
              let encoded = String(data: data, encoding: .utf8)
        else { return nil }
        let base64 = Data(encoded.utf8).base64EncodedString()
        var components = URLComponents()
        components.scheme = "cursor"
        components.host = "anysphere.cursor-deeplink"
        components.path = "/mcp/install"
        components.queryItems = [
            URLQueryItem(name: "name", value: "iMCP"),
            URLQueryItem(name: "config", value: base64),
        ]
        return components.url
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
