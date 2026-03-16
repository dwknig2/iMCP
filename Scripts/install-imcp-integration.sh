#!/usr/bin/env bash
# Install iMCP app and integrate with Cursor, Claude Desktop, and ChatGPT (instructions).
# Run from repo root or pass REPO_DIR. Uses $HOME for config paths.
set -euo pipefail

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
IMCP_APP="${IMCP_APP:-/Applications/iMCP.app}"
IMCP_SERVER_CMD="${IMCP_APP}/Contents/MacOS/imcp-server"
CURSOR_MCP_JSON="${HOME}/.cursor/mcp.json"
CLAUDE_CONFIG="${HOME}/Library/Application Support/Claude/claude_desktop_config.json"

echo "=== iMCP install and client integration ==="
echo "  REPO_DIR=$REPO_DIR"
echo "  IMCP_APP=$IMCP_APP"
echo "  HOME=$HOME"
echo ""

# --- 1. Install iMCP.app if missing ---
if [[ ! -x "${IMCP_SERVER_CMD}" ]]; then
  echo "[1/4] iMCP app not at $IMCP_APP; building and copying..."
  if [[ ! -d "$REPO_DIR/iMCP.xcodeproj" ]]; then
    echo "  Error: Not an iMCP repo at $REPO_DIR. Install iMCP manually: brew install --cask mattt/tap/iMCP"
    exit 1
  fi
  BUILD_DIR="$REPO_DIR/build"
  mkdir -p "$BUILD_DIR"
  (cd "$REPO_DIR" && xcodebuild -scheme iMCP -configuration Release -destination 'platform=macOS' -derivedDataPath "$BUILD_DIR/DerivedData" build -quiet 2>/dev/null) || {
    echo "  Build failed. Try building in Xcode and copy iMCP.app to /Applications."
    exit 1
  }
  APP_PATH=$(find "$BUILD_DIR/DerivedData" -name "iMCP.app" -type d 2>/dev/null | head -1)
  if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
    echo "  Error: iMCP.app not found in build output."
    exit 1
  fi
  cp -R "$APP_PATH" /Applications/
  echo "  Installed iMCP.app to /Applications."
else
  echo "[1/4] iMCP app already at $IMCP_APP"
fi

# --- 2. Cursor: ensure ~/.cursor/mcp.json has iMCP ---
echo "[2/4] Cursor: merging iMCP into ~/.cursor/mcp.json"
mkdir -p "$(dirname "$CURSOR_MCP_JSON")"
if [[ -f "$CURSOR_MCP_JSON" ]]; then
  EXISTING=$(cat "$CURSOR_MCP_JSON")
  if command -v jq &>/dev/null; then
    NEW=$(echo "$EXISTING" | jq --arg cmd "$IMCP_SERVER_CMD" '.mcpServers["iMCP"] = {"command": $cmd}' 2>/dev/null || echo '{"mcpServers":{"iMCP":{"command":"'"$IMCP_SERVER_CMD"'"}}}')
    echo "$NEW" > "$CURSOR_MCP_JSON"
  else
    echo "  jq not found; skipping Cursor merge. Add iMCP manually to $CURSOR_MCP_JSON"
  fi
else
  echo "{\"mcpServers\":{\"iMCP\":{\"command\":\"$IMCP_SERVER_CMD\"}}}" > "$CURSOR_MCP_JSON"
fi
echo "  Cursor config: $CURSOR_MCP_JSON"

# --- 3. Claude Desktop: ensure config has iMCP ---
echo "[3/4] Claude Desktop: merging iMCP into claude_desktop_config.json"
mkdir -p "$(dirname "$CLAUDE_CONFIG")"
if [[ -f "$CLAUDE_CONFIG" ]]; then
  EXISTING=$(cat "$CLAUDE_CONFIG")
  if command -v jq &>/dev/null; then
    NEW=$(echo "$EXISTING" | jq --arg cmd "$IMCP_SERVER_CMD" '.mcpServers["iMCP"] = {"command": $cmd}' 2>/dev/null || echo '{"mcpServers":{"iMCP":{"command":"'"$IMCP_SERVER_CMD"'"}}}')
    echo "$NEW" > "$CLAUDE_CONFIG"
  else
    echo "  jq not found; skipping Claude merge. Add iMCP manually to $CLAUDE_CONFIG"
  fi
else
  echo "{\"mcpServers\":{\"iMCP\":{\"command\":\"$IMCP_SERVER_CMD\"}}}" > "$CLAUDE_CONFIG"
fi
echo "  Claude config: $CLAUDE_CONFIG"

# --- 4. ChatGPT: no local config ---
echo "[4/4] ChatGPT (desktop)"
echo "  ChatGPT adds MCP via workspace Developer mode (no local config file)."
echo "  Use iMCP menu bar → Configure ChatGPT to copy the server command and open docs."
echo "  Server command: $IMCP_SERVER_CMD"
echo ""
echo "Done. Restart Cursor and Claude Desktop to load iMCP. Keep iMCP app running (menu bar, Enable MCP Server on)."
