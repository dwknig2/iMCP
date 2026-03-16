---
name: imcp-apple-messages
description: Retrieves messages from Apple Messages (iMessage) for conversations with specific contacts via iMCP. Use when the user wants to fetch iMessage history, get messages with a contact, or read Apple Messages using iMCP.
---

# Retrieve Apple Messages via iMCP

## When to use

- User asks to get messages from Apple Messages / iMessage
- User wants messages with a specific contact or contacts
- User mentions iMCP and Messages together

## Prerequisites

1. **iMCP app running** – Menu bar icon visible, "Enable MCP Server" on
2. **Messages service enabled** – In iMCP menu, Messages service toggled on (user may need to grant access to `~/Library/Messages/chat.db` via file picker once)
3. **MCP server** – Cursor must have the iMCP server configured (e.g. in `~/.cursor/mcp.json`); tool is exposed as `messages_fetch` by the user-iMCP server

## Tool

Use the MCP tool **`messages_fetch`** from the **user-iMCP** server.

### Parameters

| Parameter       | Type     | Required | Description |
|----------------|----------|----------|-------------|
| `participants` | string[] | Yes*    | Contact handles: phone numbers in E.164 format or email addresses. Use for "conversations with specific contacts". |
| `start`        | string   | No      | Start of date range (inclusive). ISO8601; date-only uses local midnight. |
| `end`          | string   | No      | End of date range (exclusive). ISO8601; date-only uses local midnight. |
| `query`        | string   | No      | Filter messages by text content. |
| `limit`        | integer  | No      | Max messages to return (default 30, cap 1024). |

\* For "specific contacts" always pass `participants`. To fetch from all conversations, omit or pass an empty array (if supported); otherwise ask the user which contacts.

### Participant format

- **Phone**: E.164 (e.g. `+15551234567`)
- **Email**: Use the address the contact uses in Messages (e.g. `friend@icloud.com`)

If the user gives a name only, use **contacts_search** first to resolve name → phone/email, then call **messages_fetch** with the resolved handles.

## Response shape

The tool returns a Schema.org-style object:

- `@type`: `"Conversation"`
- `hasPart`: array of message objects, each with:
  - `@id` – message id
  - `sender` – `{ "@id": "me" }` or contact handle or `"unknown"`
  - `text` – message body
  - `createdAt` – ISO8601 timestamp

Empty or non-text messages are omitted.

## Workflow

1. **Identify contacts** – From the user request (names, numbers, or emails). If only names, call `contacts_search` and use the returned phone/email for `participants`.
2. **Optional date range** – If the user specifies a time window, set `start` and `end` (ISO8601).
3. **Call `messages_fetch`** – With `participants` (and optionally `start`, `end`, `query`, `limit`).
4. **Return or summarize** – Present the `hasPart` messages in order (oldest first by `createdAt`) or as requested.

## Examples

**User:** "Get my last 20 messages with John Smith"

1. Call `contacts_search` with `name: "John Smith"` → get phone or email.
2. Call `messages_fetch` with `participants: ["+15551234567"]` (or the email), `limit: 20`.

**User:** "Show messages from my sister in the last week"

1. Resolve "sister" via contacts (e.g. `contacts_search` by name or relationship if available).
2. Call `messages_fetch` with that contact’s handle, `start` and `end` set to 7 days ago and now (ISO8601), and a reasonable `limit`.

**User:** "Find messages with alice@icloud.com that mention 'dinner'"

- Call `messages_fetch` with `participants: ["alice@icloud.com"]`, `query: "dinner"`.

## Troubleshooting

- **Tool not found** – Ensure iMCP is running, Messages service is enabled, and Cursor’s MCP config includes the iMCP server. Restart Cursor after config changes.
- **Empty or permission error** – User must have granted iMCP access to Messages (and possibly selected `chat.db` in the file picker). Remind them to enable the Messages service in the iMCP menu and grant access if prompted.
- **No match for participant** – Handles are matched against the Messages database. Use E.164 for phones; use the exact address the contact uses in iMessage.
