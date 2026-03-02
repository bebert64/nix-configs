---
description: List all plans and investigations, mark stale or Done, offer to delete and update index
---

**This is the single cleanup command:** it lists everything in the plans directory, marks what can be cleaned (stale branches, Notion Done tickets), then lets the user choose which files to delete and updates the index. There is no separate "cleanup" command — clean-plans does both.

List all files in `~/.cursor/plans/` (`.md` only): implementation plans (`<short_id>-<slug>.md`), investigation results (`<short_id>-investigation-<timestamp>.md`), review results (`<short_id>-review-<timestamp>.md`), and any other `.md` in that directory. Give a brief summary of each (a few lines max).

For each file, assign a number (1, 2, 3...) so the user can easily reference them in follow-up messages.

If two plans or investigations are very similar (same short_id), highlight which is the most recent one and describe the key differences between them.

**Stale (branch deleted):** For each implementation plan that contains a `## Branch` section, check whether the branch still exists by running `git branch --list <branch_name>` and `git branch -r --list 'origin/<branch_name>'`. If the branch no longer exists (neither locally nor on remote), prefix the entry with **[STALE - branch deleted]** and note that it is very likely no longer useful and should probably be deleted.

**Notion Done cleanup:** For each short_id that has a Notion page ID in its file(s) (parse from header line `Notion page ID: ...` in plan or investigation content), call **API-retrieve-a-page** (user-Notion) with that page_id. From the response, read the **Status Intl** property (the select's `name` value). If it equals `🟣 3 - Done`, prefix that short_id's entries with **[DONE - can clean]** and note that these files can be removed. Do not fetch all Done tickets from the API — use one request per short_id that appears in the plans directory.

Then ask the user which plans/investigations to delete (by number). When deleting:
- Remove the selected files from `~/.cursor/plans/`.
- If `~/.cursor/plans/_index.json` exists, update it to remove the deleted files (see tasks command for index schema).
