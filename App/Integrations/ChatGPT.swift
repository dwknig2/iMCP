import AppKit
import Foundation

enum ChatGPT {
    private static var serverCommandPath: String {
        Bundle.main.bundleURL
            .appendingPathComponent("Contents/MacOS/imcp-server")
            .path
    }

    /// URL for OpenAI's MCP documentation (ChatGPT Apps / adding MCP servers).
    private static let mcpDocsURL = URL(string: "https://platform.openai.com/docs/mcp")!

    /// MCP server config in the same shape used by Claude Desktop / Cursor (for reference when adding in ChatGPT).
    static func mcpServerConfigJSON() -> String {
        let config: [String: Any] = [
            "iMCP": [
                "command": serverCommandPath,
            ],
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: config),
              let string = String(data: data, encoding: .utf8)
        else { return "{\"iMCP\":{\"command\":\"\(serverCommandPath)\"}}" }
        return string
    }

    /// Copies the iMCP server command to the pasteboard and shows an alert with instructions.
    /// ChatGPT desktop adds MCP via workspace/Apps (Developer mode), not a local config file.
    static func showConfigurationPanel() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(serverCommandPath, forType: .string)

        let alert = NSAlert()
        alert.messageText = "iMCP Server Command Copied"
        alert.informativeText = """
            The server path has been copied to the clipboard.

            To use iMCP with ChatGPT:
            • ChatGPT uses MCP through workspace Apps (Developer mode), not a local config file.
            • Enable Developer mode in your workspace: Settings → Permissions & Roles → Connected Data Developer mode.
            • When adding an MCP server, use the copied path as the server command.

            See OpenAI’s MCP docs for full steps.
            """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open MCP Docs")
        alert.addButton(withTitle: "OK")

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(mcpDocsURL)
        }
    }
}
