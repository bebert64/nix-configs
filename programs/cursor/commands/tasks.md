---
description: List all tasks (plans and investigations) by short_id, with category, status, summary and copy-pastable commands; optionally clean up Done tickets
---

Show all projects (short_id) that have at least one plan or investigation in `~/.cursor/plans/`. For each project, show **category** (qtt, review, tech-task, etc.), status, a short summary, the list of files, and copy-pastable `cursor <path>` commands to open them. Optionally run cleanup: delete files for tickets whose Notion Status Intl is Done and update the index.

**Zoom on one project** is not part of this command — run **open-plans** when on that project's branch to get context and open matching plans/investigations.

## 1. Build or read the index

- If `~/.cursor/plans/_index.json` exists, read it. Schema: `{ "projects": [ { "short_id": "...", "category": "qtt"|"review"|"tech-task"|..., "status": "...", "files": [ { "path": "ABCDE-fix-login.md", "type": "plan"|"investigation" } ], "notion_page_id": "...", "updated_at": "..." } ] }`. Use it to build the list of projects.
- If the file does not exist or is invalid, build the index from the directory: list all `.md` files in `~/.cursor/plans/` (exclude `_index.json` if present). For each file, extract short_id from the filename (segment before the first `-` in `<short_id>-<rest>.md`). Optionally read the first ~30 lines of each file to get `## Category`, `## Status`, `## Short ID`, `Notion page ID: ...`. Group files by short_id.

## 2. Output: all projects with category and summary

- For each short_id (project), output:
  - **Short ID** and **category** (from file content or inferred: `*-investigation-*.md` → qtt or from `## Category`; `*-review-*.md` → review or from `## Category`; implementation plan → tech-task or from `## Category`; if missing, show "—").
  - **Status** (from `## Status` in content or leave blank).
  - **Summary**: from the latest file (by mtime or by timestamp in filename) — e.g. title (first `#` line), and the `## Resume` section or first 200–300 characters if no Resume.
  - **Files**: list of paths (clickable or raw). For each, a copy-pastable command: `cursor ~/.cursor/plans/<filename>` (or full path).
- Present in a clear, scannable way (e.g. one block per short_id). Include a single copy-pastable block with one `cursor ...` command per file (or per latest file per short_id) so the user can open files easily.

## 3. Cleanup (Notion Done) — optional

Do **not** fetch all tickets with status Done from Notion. Use **one request per short_id** that has a Notion page ID in its file(s).

- **Status Intl value for done:** `🟣 3 - Done` (exact string from the Notion database; use it when comparing).
- Collect (short_id, notion_page_id) from plan/investigation files: for each short_id, parse **Notion page ID** from the latest file (line `Notion page ID: ...` in the header). If a file has no Notion page ID, skip that short_id for cleanup.
- For each such page_id, call **API-retrieve-a-page** (user-Notion) with that page_id. From the response, read the **Status Intl** property (the select's `name` value).
- If it equals `🟣 3 - Done`, delete all files in `~/.cursor/plans/` whose filename starts with that short_id (e.g. `ABCDE-`, so `ABCDE-fix-login.md`, `ABCDE-investigation-*.md`, `ABCDE-review-*.md`, etc.).
- Update `~/.cursor/plans/_index.json` to remove the deleted entries (or rebuild the index from the directory after deletions).
- Report how many tickets were cleaned up (which short_ids).

## 4. Index schema (for reference)

When creating or updating `_index.json`, use this shape so tasks and other commands can read it:

- **projects**: array of `{ "short_id", "category?", "status?", "files": [ { "path": "basename or relative", "type": "plan"|"investigation" } ], "notion_page_id?", "branch?", "updated_at?" }`.
- Agent can derive this from the directory when the index is missing; when writing a new plan or investigation, append or update the corresponding project entry and write the file back.

## 5. Migration note (one-time)

If the user still has files in `~/.cursor/saved-investigations/`, they can migrate by moving each `{short_id}-{timestamp}.md` to `~/.cursor/plans/{short_id}-investigation-{timestamp}.md`, then removing the empty `saved-investigations/` directory. After that, run **tasks** once to rebuild or create `_index.json` from the plans directory.
