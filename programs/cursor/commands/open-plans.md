---
description: Open all plans and investigations for the current branch's short_id (zoom on one project)
---

# open-plans

**Zoom on one project:** Run this command when on that project's branch to get context, all related documents, and open points.

1. Run `git branch --show-current` to get the current branch name.
2. **Determine the short_id** for this branch: the 5-character code (letters or digits) that Stockly puts in branch names (e.g. `EN4QK` in `EN4QK-BoMessagesSentToSupplierArenTLinkedToThread`). The branch name contains the short_id; extract it (e.g. segment before the first `-`, or the known 5-char pattern).
3. List all `.md` files in `~/.cursor/plans` (or the user's Cursor plans directory) whose **filename starts with `<short_id>-`**. That includes:
   - Implementation plans: `<short_id>-<slug>.md` (e.g. `ABCDE-fix-login.md`)
   - Investigation results: `<short_id>-investigation-<timestamp>.md`
   - Review results: `<short_id>-review-<timestamp>.md`
   Any other file whose name starts with `<short_id>-` is also included — match **all** documents related to this short_id.
4. Open every matching file in the editor by running `cursor <path>` via the Shell tool for each.
5. For each opened file, read it and provide:
   - **Implementation plans** (no `-investigation-` or `-review-` in name): 2–3 line synthesis, current status (pending vs completed steps), remaining items.
   - **Investigation or review files** (filename contains `-investigation-` or `-review-`): 2–3 line synthesis (e.g. from title and `## Resume` or first paragraph), brief status if relevant.
6. If no file in `~/.cursor/plans/` has a name starting with that short_id, say so (e.g. "No plans or investigations found for short_id XYZ.").
