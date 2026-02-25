---
description: Start Quality Tech Ticket investigations — pick pending tickets from Notion, investigate in parallel, output super-synthetic resumes
---

Run this workflow to select unassigned Quality Tech tickets (status "0 - Pending Workforce", Teams Intl ≠ Partner Inputs_Front), prioritize them, and have subagents investigate. Produce a **super-synthetic resume** for each ticket.

## 0. How many tickets

- If the user specified a number in their message (e.g. "pick 5 tickets", "just 1"), use that.
- Otherwise ask: "How many tickets do you want to work on? (default 3)" and use their answer, or 3 if they don't care.
- Call this number **N**. You will fetch candidates, exclude ignored ones, then take the top **N** and run subagents for those.

## 1. Ignore list (local) and cleanup

- **File:** `/home/romain/Stockly/.cursor/ignored-quality-tickets.txt`
- **Format:** One Notion page ID per line (the `id` field from the API, e.g. `0000fd7f-2f85-49c5-8cd8-a61f0b731b47`). No header. Strip whitespace; skip empty lines.
- **Before selecting tickets:** Read this file if it exists. Build a set of ignored page IDs. When building the candidate list (after filter and sort), exclude any page whose `id` is in that set. Then take the first **N** remaining.
- **Adding to the list:** If at any point (in this run or a follow-up) the user says they want to ignore a ticket (e.g. "ignore this one", "skip ABCDE", "add to ignore list"), append that ticket's Notion page ID to the file on a new line. Confirm to the user. The next run of this command will then skip it.
- If the file doesn't exist, create it when first adding an ID; otherwise proceed with an empty ignore set.

**Prune the ignore list (each run):** So the list doesn't grow indefinitely, at the start of each run — after reading the ignore file — prune it. For each page ID in the file, use the Notion API (e.g. `retrieve-a-page`) to check whether that page still exists and would still match the selection criteria (assignee empty, status "0 - Pending Workforce", Teams Intl not "Partner Inputs_Front"). If the page is missing (e.g. 404 / object_not_found), or it exists but no longer matches (e.g. now has an assignee, or status changed, or Teams Intl is Partner Inputs_Front), remove that ID from the ignore file. Write the file back. Then proceed with the pruned list. That way entries for deleted, assigned, or otherwise no-longer-eligible tickets are dropped automatically.

## 2. Notion database

- **Database (for retrieve):** `ebea444c-2ed2-4ed6-b6c4-76ec272de766` — "[DB] Quality Tech Tickets"
- **Data source (for query):** `d6cdb24f-62ac-4581-9503-c6035d22babf` (use this in `query-data-source`)

If the data source ID is missing, call `retrieve-a-database` with the database ID above; the response includes `data_sources[0].id`.

## 3. Filter and sort

Query the data source with:

- **Filter:** All of:
  - Assignee is empty (people, `is_empty: true`)
  - Status = "0 - Pending Workforce" (select; option id `54ae61a7-3a83-4cda-aac2-d0b44d71b0da` or name match)
  - Teams Intl does NOT contain "Partner Inputs_Front" (multi_select: empty is OK; if not empty, must not contain that option — id `b9a27f92-bb7a-42fc-8590-0f13340fc994`)
- **Sort:** 
  1. Severity ascending (SEV1 first, SEV5 last — use property "Severity" and order so SEV1 is first)
  2. Then most recent first (e.g. "Updated At" or "Created At" descending)
- **Page size:** Fetch enough to have **N + size(ignore list)** candidates (e.g. at least N + 20, or 50 cap) so that after excluding ignored IDs you still have at least N. Apply sort in memory if the API does not support the full sort.

Apply the ignore list (section 1): remove any page whose `id` is in the ignore set. Take the **top N** tickets from the remaining list.

## 4. Investigate in parallel

For each of the top N tickets, launch a **subagent** (Task tool) with:

- The ticket's Notion page URL (from the `url` field of each result).
- Instruction: "Investigate this Quality Tech ticket. Do not guess if information is missing — report what's missing and ask questions. Output either: (1) clarifying questions for the user, or (2) an action plan. If you write an action plan, the user will work on a branch whose name includes the ticket's Notion short ID (the 5-character code at the start of the ticket title, e.g. `ABCDE`). Write the plan so it can be picked up by the open-plans command: save it as a plan file with a `## Branch` section whose value is the suggested branch name (e.g. `ABCDE-short-description`)."

Let each subagent return: questions **or** an action plan (and optionally a suggested branch name and plan path).

## 5. Super-synthetic resume per ticket

For each ticket, after the subagent responds, produce exactly one of these outcomes in a short, scannable block:

**A. Needs a plan and a git branch / worktree**  
- Create the plan file so **open-plans** will match it:
  - Path: `~/.cursor/plans/<short-id>-<slug>.md` (e.g. `~/.cursor/plans/ABCDE-fix-login.md`).
  - Content must include a line `## Branch` and on the next line the **exact branch name** the user will use (e.g. `ABCDE-fix-login`). Match the format used by open-plans (it matches the current git branch to the value after `## Branch`).
- In the resume: ticket title + short ID, one line "what it is", and: "**Plan + branch.** Plan written to `~/.cursor/plans/<filename>.md`. Create branch `<suggested-branch>`, open a new Agent window, and run open-plans or load that plan to work on it."

**B. Super easy — clear next steps**  
- No plan file. In the resume: ticket title + short ID, one line "what it is", and: "**Next steps:**" followed by a short, ordered list of concrete steps the user should do to resolve it (no extra conversation needed).

**C. Not super easy, not really code-related, no git branch**  
- No plan file. In the resume: ticket title + short ID, one line "what it is", and: "**Use a dedicated conversation.**" Then provide a **ready-to-paste prompt** the user can paste into a new Agent chat to continue (e.g. context + goal + what's already known).

## 6. Final output

- List the N tickets with their super-synthetic resume (A, B, or C) and ticket URL.
- If fewer than N tickets were available after the ignore list (or after the Notion filter), say how many were found and process only those.
- If the Notion MCP is unavailable, say so and stop.
- Remind the user they can say "ignore [ticket]" to add it to the ignore list for future runs.
