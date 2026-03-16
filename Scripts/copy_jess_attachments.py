#!/usr/bin/env python3
"""
Copy all attachments from jess_messages.json into a folder with filenames:
  date_sender_index_originalname
e.g. 2024-07-27_me_0_report.pdf, 2024-08-01_13343285605_1_recording000000.mp4

Run after fetch_jess_messages.py. Requires the JSON path and (optional) output dir.
"""
import argparse
import json
import os
import re
import shutil
import sys


def sanitize(s: str) -> str:
    """Make string safe for filenames: no path separators or problematic chars."""
    s = (s or "").strip()
    s = s.replace("+", "").replace("@", "at").replace(".", "_")
    s = re.sub(r"[^\w\-]", "_", s)
    return s[:32] or "unknown"


def basename_from_attachment(att: dict, path: str) -> str:
    """Prefer transferName, else filename from path, else extension from mime."""
    name = (att.get("transferName") or "").strip()
    if name:
        return name
    if path:
        n = os.path.basename(path)
        if n:
            return n
    ext = ""
    mime = (att.get("mimeType") or "").lower()
    if "jpeg" in mime or "jpg" in mime:
        ext = ".jpg"
    elif "png" in mime:
        ext = ".png"
    elif "gif" in mime:
        ext = ".gif"
    elif "mp4" in mime:
        ext = ".mp4"
    elif "pdf" in mime:
        ext = ".pdf"
    elif "amr" in mime:
        ext = ".amr"
    else:
        ext = ".bin"
    return (att.get("@id") or "att")[:20] + ext


def main():
    p = argparse.ArgumentParser(description="Copy Jess message attachments to a folder with date/sender in filename.")
    p.add_argument("json_path", nargs="?", default=os.path.join(os.path.dirname(__file__), "jess_messages.json"), help="Path to jess_messages.json")
    p.add_argument("-o", "--out-dir", default=os.path.join(os.path.dirname(__file__), "jess_attachments"), help="Output directory")
    p.add_argument("--dry-run", action="store_true", help="Print what would be copied, do not copy")
    args = p.parse_args()

    if not os.path.isfile(args.json_path):
        print("Error: JSON not found:", args.json_path, file=sys.stderr)
        print("Run fetch_jess_messages.py first.", file=sys.stderr)
        sys.exit(1)

    with open(args.json_path) as f:
        data = json.load(f)

    messages = data.get("hasPart") or []
    out_dir = os.path.abspath(args.out_dir)
    if not args.dry_run:
        os.makedirs(out_dir, exist_ok=True)

    seen = set()
    copied = 0
    skipped = 0

    for msg in messages:
        created = (msg.get("createdAt") or "")[:10]  # YYYY-MM-DD
        sender_obj = msg.get("sender") or {}
        sender_id = sender_obj.get("@id") if isinstance(sender_obj, dict) else "unknown"
        sender = sanitize(str(sender_id))

        for i, att in enumerate(msg.get("attachments") or []):
            if not att.get("fileExists") or not att.get("path"):
                skipped += 1
                continue
            src = att["path"]
            if not os.path.isfile(src):
                skipped += 1
                continue

            base = basename_from_attachment(att, src)
            stem, ext = os.path.splitext(base)
            if not ext and att.get("mimeType"):
                base = stem + ".bin"
                stem, ext = os.path.splitext(base)
            name = f"{created}_{sender}_{i}_{base}"
            dest = os.path.join(out_dir, name)

            # Avoid overwrite: if exists, append _1, _2, ...
            if dest in seen or (not args.dry_run and os.path.isfile(dest)):
                k = 1
                while dest in seen or (not args.dry_run and os.path.isfile(dest)):
                    name = f"{created}_{sender}_{i}_{stem}_{k}{ext}"
                    dest = os.path.join(out_dir, name)
                    k += 1
            seen.add(dest)

            if args.dry_run:
                print(dest)
            else:
                shutil.copy2(src, dest)
            copied += 1

    print("Copied:", copied, file=sys.stderr)
    print("Skipped (missing or no path):", skipped, file=sys.stderr)
    if not args.dry_run:
        print("Output directory:", out_dir, file=sys.stderr)


if __name__ == "__main__":
    main()
