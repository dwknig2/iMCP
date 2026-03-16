#!/usr/bin/env python3
"""
Fetch all Apple Messages with Jess (Jul 2024 – present) from chat.db.
Includes attachments (audio, video, images, documents). Uses date-ordered
pagination (500 per chunk) to ensure complete coverage.

Attachments:
  - Each message has an "attachments" array with path, mimeType, kind, fileExists.
  - kind: "audio" | "video" | "image" | "document" | "other"
  - Android voice notes often arrive as video/mp4 (recording000000.mp4); we
    classify them as "audio" when transferName contains "recording" or size < 500KB.
  - path is expanded (~ -> home). Use path to play/copy files (fileExists if on disk).

Usage:
  python3 fetch_jess_messages.py
  # Optional: export a flat list of attachment paths by kind:
  python3 -c "
  import json
  d = json.load(open('Scripts/jess_messages.json'))
  for m in d['hasPart']:
    for a in m.get('attachments', []):
      if a.get('fileExists') and a.get('kind') == 'audio':
        print(a['path'])
  "
"""
import json
import os
import sqlite3
import sys
from datetime import datetime, timezone

DB = "/Users/daniel/Library/Messages/chat.db"
# Jess handles: +13343285605 (SMS/iMessage/RCS), booniejess@gmail.com
JESS_HANDLE_IDS = (15, 69, 93, 132)
# Chat IDs that include Jess (from chat_handle_join)
JESS_CHAT_IDS = (79, 100, 114, 118, 121, 154, 181, 387, 559, 561, 568)
# July 1 2024 00:00:00 UTC -> Apple epoch nanoseconds (2001-01-01)
START_NS = 741484800000000000
END_NS = 795398399000000000
CHUNK = 500
# MP4s smaller than this (bytes) are likely voice notes, not real video
VOICE_MP4_MAX_BYTES = 500_000


def attachment_kind(mime_type: str, uti: str, transfer_name: str, total_bytes: int) -> str:
    """Classify attachment as audio | video | image | document | other.
    Android voice notes often arrive as video/mp4 (recording000000.mp4)."""
    mime = (mime_type or "").lower()
    name = (transfer_name or "").lower()
    uti_lower = (uti or "").lower()
    if mime.startswith("audio/") or "audio" in uti_lower or "m4a" in uti_lower or "coreaudio" in uti_lower:
        return "audio"
    if mime.startswith("video/"):
        # Many Android voice messages are stored as MP4 with "recording" in name or small size
        if "recording" in name or (mime == "video/mp4" and total_bytes and total_bytes < VOICE_MP4_MAX_BYTES):
            return "audio"
        return "video"
    if mime.startswith("image/"):
        return "image"
    if mime in ("application/pdf",) or "pdf" in uti_lower or "pdf" in name:
        return "document"
    if "wordprocessing" in mime or "spreadsheet" in mime or "presentation" in mime:
        return "document"
    return "other"


def expand_attachment_path(filename: str) -> str:
    """Expand ~ to home and return path; empty if filename missing."""
    if not filename or not isinstance(filename, str):
        return ""
    path = os.path.expanduser(filename.strip())
    return path


def ns_to_iso(ns: int) -> str:
    """Convert Apple epoch nanoseconds to ISO8601."""
    if ns is None or ns <= 0:
        return ""
    # Apple epoch is 2001-01-01 00:00:00 UTC
    ref = datetime(2001, 1, 1, tzinfo=timezone.utc)
    sec = ref.timestamp() + ns / 1e9
    return datetime.fromtimestamp(sec, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def main():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row

    # Get actual max date and total count for verification
    cur = conn.execute(
        """
        SELECT MAX(m.date) AS max_date,
               COUNT(*) AS expected_count
        FROM message m
        JOIN chat_message_join cmj ON m.ROWID = cmj.message_id
        WHERE cmj.chat_id IN ({})
          AND m.date >= ?
          AND m.date <= ?
        """.format(",".join(map(str, JESS_CHAT_IDS))),
        (START_NS, END_NS),
    )
    row = cur.fetchone()
    end_ns = row["max_date"] if row and row["max_date"] else END_NS
    expected_count = row["expected_count"] if row else 0
    cur.close()

    all_messages = []
    current_start = START_NS
    chunk_size = CHUNK + 1  # request 501 to detect “more”
    hit_limit = False

    while current_start < end_ns:
        cur = conn.execute(
            """
            SELECT m.ROWID, m.guid, m.text, m.date, m.is_from_me, h.id AS sender_id
            FROM message m
            JOIN chat_message_join cmj ON m.ROWID = cmj.message_id
            LEFT JOIN handle h ON m.handle_id = h.ROWID
            WHERE cmj.chat_id IN ({})
              AND m.date >= ?
              AND m.date <= ?
            ORDER BY m.date ASC
            LIMIT ?
            """.format(",".join(map(str, JESS_CHAT_IDS))),
            (current_start, end_ns, chunk_size),
        )
        rows = cur.fetchall()
        cur.close()

        if not rows:
            break

        for r in rows:
            text = (r["text"] or "").strip()
            all_messages.append({
                "_rowid": r["ROWID"],
                "@id": r["guid"],
                "sender": {"@id": "me" if r["is_from_me"] else (r["sender_id"] or "unknown")},
                "text": text,
                "createdAt": ns_to_iso(r["date"]),
                "date_ns": r["date"],
            })

        n = len(rows)
        if n >= chunk_size:
            hit_limit = True
            # Move start to last message date + 1 ns to avoid duplicates
            current_start = rows[-1]["date"] + 1
        else:
            break

    # Fetch all attachments for these messages
    message_rowids = [m["_rowid"] for m in all_messages]
    attachment_map = {}  # message_id -> list of attachment dicts
    if message_rowids:
        placeholders = ",".join("?" * len(message_rowids))
        cur = conn.execute(
            """
            SELECT maj.message_id, a.guid, a.filename, a.mime_type, a.uti,
                   a.transfer_name, a.total_bytes
            FROM message_attachment_join maj
            JOIN attachment a ON a.ROWID = maj.attachment_id
            WHERE maj.message_id IN ({})
            """.format(placeholders),
            message_rowids,
        )
        for row in cur.fetchall():
            msg_id = row[0]
            path = expand_attachment_path(row[2])
            kind = attachment_kind(
                row[3], row[4], row[5] or "", row[6] or 0
            )
            att = {
                "@id": row[1],
                "path": path,
                "fileExists": os.path.isfile(path) if path else False,
                "mimeType": row[3] or "",
                "uti": row[4] or "",
                "transferName": row[5] or "",
                "totalBytes": row[6],
                "kind": kind,
            }
            attachment_map.setdefault(msg_id, []).append(att)
        cur.close()

    conn.close()

    # Sort by date and attach attachment lists; drop temp keys
    all_messages.sort(key=lambda x: x["date_ns"])
    for m in all_messages:
        m["attachments"] = attachment_map.get(m["_rowid"], [])
        del m["date_ns"]
        del m["_rowid"]

    total = len(all_messages)
    complete = total == expected_count
    out = {
        "@context": "https://schema.org",
        "@type": "Conversation",
        "hasPart": all_messages,
        "_meta": {
            "totalMessages": total,
            "expectedCount": expected_count,
            "dateRange": {"start": ns_to_iso(START_NS), "end": ns_to_iso(end_ns)},
            "hitLimitInChunk": hit_limit,
            "completeCoverage": complete,
        },
    }

    out_path = "/Users/daniel/Documents/GitHub/iMCP/Scripts/jess_messages.json"
    with open(out_path, "w") as f:
        json.dump(out, f, indent=2)

    print("Total messages:", total, file=sys.stderr)
    print("Expected (DB count):", expected_count, file=sys.stderr)
    print("Hit limit in chunk:", hit_limit, file=sys.stderr)
    print("Complete coverage:", complete, file=sys.stderr)
    print("Output:", out_path, file=sys.stderr)
    print(json.dumps(out["_meta"]))


if __name__ == "__main__":
    main()
