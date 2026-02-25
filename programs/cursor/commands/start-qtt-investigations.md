---
description: Start Quality Tech Ticket investigations — pick pending tickets from Notion, investigate in parallel, output super-synthetic resumes
---

Run this workflow to select unassigned Quality Tech tickets (**Status Intl** = "0 - Pending Workforce", Teams Intl ≠ Partner Inputs_Front), prioritize them, and have subagents investigate. Produce a **super-synthetic resume** for each ticket.

**Important:** Use **Status Intl** (not "Status") for "pending" — Status Intl is the source of truth; a ticket can have Status = "0 - Pending Workforce" but Status Intl = "Done" and must be excluded.

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

**Prune the ignore list (each run):** So the list doesn't grow indefinitely, at the start of each run — after reading the ignore file — prune it. For each page ID in the file, use the Notion API (e.g. `retrieve-a-page`) to check whether that page still exists and would still match the selection criteria (assignee empty, **Status Intl** = "0 - Pending Workforce", Teams Intl not "Partner Inputs_Front"). If the page is missing (e.g. 404 / object_not_found), or it exists but no longer matches (e.g. now has an assignee, or Status Intl changed, or Teams Intl is Partner Inputs_Front), remove that ID from the ignore file. Write the file back. Then proceed with the pruned list.

## 2. Notion database

- **Database (for retrieve):** `ebea444c-2ed2-4ed6-b6c4-76ec272de766` — "[DB] Quality Tech Tickets"
- **Data source (for query):** `d6cdb24f-62ac-4581-9503-c6035d22babf` (use this in `query-data-source`)

If the data source ID is missing, call `retrieve-a-database` with the database ID above; the response includes `data_sources[0].id`.

## 3. Filter and sort

**Notion MCP:** Call `API-query-data-source` (user-Notion) with:

- **data_source_id:** `d6cdb24f-62ac-4581-9503-c6035d22babf`
- **filter:** `{"and": [{"property": "Status Intl", "select": {"equals": "0 - Pending Workforce"}}, {"property": "Assignee", "people": {"is_empty": true}}, {"or": [{"property": "Teams Intl", "multi_select": {"is_empty": true}}, {"property": "Teams Intl", "multi_select": {"does_not_contain": "Partner Inputs_Front"}}]}]}`
- **sorts:** `[{"property": "Severity", "direction": "ascending"}, {"property": "Updated At", "direction": "descending"}]`
- **page_size:** Use **100** (or more). The Notion API sort by Severity may not return SEV4 before SEV5; the parser re-sorts by Severity (SEV1 first, SEV5 last) then Updated At descending. Fetching enough results ensures SEV4 tickets (higher priority) are in the set and the parser will order them correctly.

The tool returns a message like "Large output has been written to: .../agent-tools/<uuid>.txt" — copy that full path and pass it to the parser.

**Get top N and apply ignore list:** Run the parser so you get structured lines you can use (id, url, title, short_id). Parser path: `python3 /home/romain/Stockly/.cursor/parse_qtt.py <path_to_json_file> [N]` — N defaults to 3. It reads the JSON from the Notion query result file, filters (Status Intl = Pending workforce, Assignee empty, Teams Intl not Partner Inputs_Front), sorts by Severity then Updated At, prints `candidates_count=<m>` on stderr and one line per ticket `rank|id|url|title|short_id` for the top N. Then exclude any line whose `id` is in the ignore set and take the first **N** tickets from the remaining list (if the parser was run with a large N, you already have a sorted list; drop ignored IDs and take first N).

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
