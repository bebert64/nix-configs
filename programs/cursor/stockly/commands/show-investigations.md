---
description: List Quality Tech Investigation plans with resume, status, Notion link, and worktree check
---

When invoked, list all **Quality Tech Investigation** plans and report a short summary for each.

## 1. Find all plans

- Look in **`~/.cursor/plans/`** (e.g. `/home/romain/.cursor/plans/`).
- If the workspace has a **`.cursor/plans/`** directory, include those plans too (merge and deduplicate by plan identity, e.g. same Short ID or same filename).

## 2. Identify investigation plans

A plan is a **Quality Tech Investigation** if any of the following hold:

- **Branch section**: The `## Branch` section contains **only a ShortId** (5-character code, e.g. `NV9WQ`), or a **ShortId-slug** branch name (e.g. `Q2PS8-register-supplier-cancellation-500`), or **narrative text** such as "Create or use a branch whose name includes the ticket Short ID" instead of a full descriptive branch name (e.g. `BDXNS-IncompleteDeliveryClaimsAskForDocuments`).
- **Short ID section**: The plan has a `## Short ID` section (typical for investigation plans).
- **Resume / content**: The title, overview, or body clearly refer to an "investigation", "Quality Tech", or similar (e.g. "Mismatch investigation", "500 on …").

When in doubt, treat a plan as an investigation if it has both `## Short ID` and a Branch section that does **not** look like a long descriptive branch name in backticks.

## 3. For each investigation plan, report

1. **Quick resume** — One or two sentences from the plan (title, overview, or first paragraph).
2. **Status** — If the plan file or frontmatter indicates status (e.g. todos, outcome), summarize it; otherwise state "unknown" or "not specified".
3. **Notion ticket URL** — If the plan contains a Notion link (e.g. `https://www.notion.so/...` or `https://notion.so/...`), output that URL; otherwise "—".
4. **Worktree** — Whether a directory matching **`Main_<ShortID>*`** exists under **`/home/romain/Stockly`** (e.g. `Main_NV9WQ`, `Main_Q2PS8-register-supplier-cancellation-500`). Report "yes" or "no". Use the Short ID from the plan (e.g. from `## Short ID` or from the Branch value or filename).

## 4. Output format

Present the list in a clear, scannable way (e.g. one block per investigation with the four points above). If there are no investigation plans, say so explicitly.
