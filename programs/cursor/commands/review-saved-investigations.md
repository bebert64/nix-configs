---
description: List saved investigations grouped by short_id with summary and copy-pastable commands; optionally clean up Done tickets
---

When invoked, list all saved investigations in `~/.cursor/saved-investigations/` (e.g. `/home/romain/.cursor/saved-investigations/`), grouped by short_id, with a global summary per ticket and copy-pastable terminal commands to open the full file. Optionally clean up files for tickets whose Notion Status Intl is done.

## 1. List files

- Read `~/.cursor/saved-investigations/` (`.md` files only).
- If the directory does not exist or is empty, output "No saved investigation results" and stop.

## 2. Group by short_id

- From each filename `{short_id}-{timestamp}.md`, extract the short_id (the 5-character prefix before the first `-`).
- Group all files by short_id.

## 3. Per short_id (newest first)

- For each short_id, determine the **latest** file (by file modification time or by parsing the timestamp in the filename).
- Parse that latest file: read the title (first `#` line), and the **Resume** section (from `## Resume` to the next `##` or end of file). If there is no `## Resume`, use the first paragraph or first 200–300 characters as fallback.
- **Summarize the global content** for that ticket in one block (e.g. from the latest resume); do not describe each investigation file one by one.
- List the path(s) to the full file(s), at least the latest file per short_id. **Output each path as a clickable link** so the user can open the file in the editor (e.g. `[path](file:///full/path/to/file.md)` or raw path if the UI supports clickable paths).

## 4. Copy-pastable block

- For each ticket (or for the latest file per ticket), output a terminal command the user can paste to open the full investigation file, e.g. `cursor /home/romain/.cursor/saved-investigations/ABCDE-2025-02-26T143052.md`.
- Present these commands in a **single copy-pastable block** (e.g. one command per line, or one block per short_id with the command to open the latest file).

## 5. Clean-up (Done tickets)

Do **not** fetch all tickets with status Done (that would return thousands of results). The Notion API does not support a single call that returns multiple pages by a list of IDs. Only **retrieve-a-page** (one page_id per call) is available. Use **one request per ticket**.

**Status Intl value for done:** `🟣 3 - Done` (exact string from the Notion Quality Tech Tickets database; use it when comparing).

- Collect unique (short_id, page_id) from saved-investigation files: for each short_id, parse the **Notion page ID** from the latest file (line `Notion page ID: ...` in the header).
- For each such page_id, call **API-retrieve-a-page** (user-Notion) with that `page_id`. From the response, read the **Status Intl** property (the select's `name` value).
- If it equals `🟣 3 - Done`, delete all files in `~/.cursor/saved-investigations/` whose filename starts with that ticket's short_id (e.g. `ABCDE-`).
- Total: one API call per ticket in saved-investigations (typically 3–4).

## 6. Output format

- Present the list in a clear, scannable way (e.g. one block per short_id with summary, path(s) as clickable links, and the copy-pastable command).
- After the list, include the copy-pastable command block so the user can open files easily in the terminal.
- If clean-up was run, briefly state how many tickets were cleaned up (files removed for which short_ids).
