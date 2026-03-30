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
  - **One-liners to start working** (display immediately after this block, not at the end of the list):
    - If the `Main_<short_id>_*` git worktree (directory) does **not** exist: `s wk <notion_url>` (use the project's Notion page URL). If the worktree already exists, omit this line.
    - In all cases: open the worktree on orthos via Remote-SSH, same pattern as **open-orthos** (`programs/cursor/default.nix`): `cursor --folder-uri=vscode-remote://ssh-remote+orthos/home/romain/Stockly/<worktree_dir> & disown` where `<worktree_dir>` is the project's worktree directory (e.g. `Main_<short_id>` or `Main_<short_id>_<suffix>`). Use the actual directory name when known (e.g. from index or from listing `Main_*` on orthos).
- Present in a clear, scannable way (e.g. one block per short_id). Each block is self-contained and includes its one-liners right after the file commands.

## 3. Index schema (for reference)

When creating or updating `_index.json`, use this shape so tasks and other commands can read it:

- **projects**: array of `{ "short_id", "category?", "status?", "files": [ { "path": "basename or relative", "type": "plan"|"investigation" } ], "notion_page_id?", "branch?", "updated_at?" }`.
- Agent can derive this from the directory when the index is missing; when writing a new plan or investigation, append or update the corresponding project entry and write the file back.
