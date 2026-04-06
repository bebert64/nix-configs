---
description: Start Quality Tech Ticket investigations — pick pending tickets from Notion, investigate in parallel, output super-synthetic resumes
---

Run this workflow to select unassigned Quality Tech tickets (**Status Intl** = "0 - Pending Workforce", Teams Intl ≠ Partner Inputs_Front), prioritize them, and have subagents investigate. Produce a **super-synthetic resume** for each ticket.

**Important:** Use **Status Intl** (not "Status") for "pending" — Status Intl is the source of truth; a ticket can have Status = "0 - Pending Workforce" but Status Intl = "Done" and must be excluded.

## 0. How many tickets

- If the user specified a number in their message (e.g. "pick 5 tickets", "just 1"), use that.
- Otherwise ask: "How many tickets do you want to work on? (default 3)" and use their answer, or 3 if they don't care.
- Call this number **N**. You will fetch candidates, exclude ignored ones and tickets that already have a corresponding plan, then take the top **N** and run subagents for those.

## 1. Ignore list (local) and cleanup

- **File:** `/home/romain/Stockly/.cursor/ignored-quality-tickets.txt`
- **Format:** One Notion page ID per line (the `id` field from the API, e.g. `0000fd7f-2f85-49c5-8cd8-a61f0b731b47`). No header. Strip whitespace; skip empty lines.
- **Before selecting tickets:** Read this file if it exists. Build a set of ignored page IDs. When building the candidate list (after filter and sort), exclude any page whose `id` is in that set. **Also exclude** any ticket that already has a corresponding plan or investigation in `~/.claude/plans/` (see below). Then take the first **N** remaining.
- **Exclude tickets that already have a plan or investigation:** List files in `~/.claude/plans/` (`.md` only). A ticket (with short_id e.g. `ABCDE`) is considered to have one if there is a file whose name starts with `<short_id>-` (e.g. `ABCDE-fix-login.md`, `ABCDE-investigation-2025-02-26T143052.md`), or a plan file whose content contains a `## Short ID` section with that same short_id. Exclude those tickets from the list before taking the top N.
- **Adding to the list:** If at any point (in this run or a follow-up) the user says they want to ignore a ticket (e.g. "ignore this one", "skip ABCDE", "add to ignore list"), append that ticket's Notion page ID to the file on a new line. Confirm to the user. The next run of this command will then skip it.
- If the file doesn't exist, create it when first adding an ID; otherwise proceed with an empty ignore set.

## 2. Notion database

- **Database (for retrieve):** `ebea444c-2ed2-4ed6-b6c4-76ec272de766` — "[DB] Quality Tech Tickets"
- **Data source (for query):** `d6cdb24f-62ac-4581-9503-c6035d22babf` (use this in `query-data-source`)

If the data source ID is missing, call `retrieve-a-database` with the database ID above; the response includes `data_sources[0].id`.

## 3. Filter and sort

**Notion MCP — query with filter, then paginate if needed:**

1. **First request:** Call `API-query-data-source` (user-Notion) with:
   - **data_source_id:** `d6cdb24f-62ac-4581-9503-c6035d22babf`
   - **page_size:** **100**
   - **sorts:** `[{"property": "Severity", "direction": "ascending"}, {"property": "Created At", "direction": "descending"}]`
   - **filter:** `{"and": [{"property": "Status Intl", "select": {"equals": "0 - Pending Workforce"}}, {"property": "Assignee", "people": {"is_empty": true}}]}`

   The tool returns a message like "Large output has been written to: .../agent-tools/<uuid>.txt". Read that file; the JSON has `results`, `next_cursor`, and `has_more`.

2. **Paginate:** While the response has `has_more` true and a non-empty `next_cursor`, call `API-query-data-source` again with the **same** parameters (including **filter**) plus **start_cursor:** the value of `next_cursor` from the previous response. Read each new output file and append its `results` to your collected list.

3. **Merge:** Build a single JSON object: `{"results": <all collected page objects>}`. Write it to a file (e.g. the path of the first response file, or a new path under agent-tools) so the parser can read it.

4. **Get top N and apply ignore list and existing plans:** Run the parser so you get structured lines you can use (id, url, title, short_id). Parser path: `python3 ${CLAUDE_SKILL_DIR}/parse_qtt.py <path_to_json_file> [N]` — N defaults to 3. It prints `candidates_count=<m>` on stderr and one line per ticket `rank|id|url|title|short_id` for the top N. Then exclude any line whose `id` is in the ignore set, any ticket whose short_id already has at least one file in `~/.claude/plans/` (filename starting with `<short_id>-`, e.g. plan or investigation). Take the first **N** tickets from the remaining list.

## 4. Investigate in parallel

For each of the top N tickets, launch a **subagent** (Task tool) with a prompt that invokes the **`investigate`** skill and passes the ticket's Notion page URL (from the `url` field of the result).

Let each subagent return: clarifying questions **or** one of the three outcomes (A: plan path + branch; B: next steps; C: ready-to-paste prompt).

**Stream results:** As soon as the **first** subagent (or any subagent) returns, **immediately** produce and display that ticket's super-synthetic resume (section 5) to the user — do not wait for the others. As each further subagent returns, produce and display that ticket's resume in turn. When **all** subagents have returned, output the final section (section 6). This way the user sees results as they complete instead of waiting for the slowest one.

## 5. Super-synthetic resume per ticket

As soon as a subagent returns, display a short scannable block: ticket title + short ID, one line "what it is", then the outcome summary (A/B/C as defined in the `investigate` skill).

## 6. Final output

After **all** subagents have returned (and you have already displayed each ticket's resume as it completed):

- Provide a consolidated list of the N tickets with their super-synthetic resume (A, B, or C) and ticket URL, so the user has everything in one place.
- If fewer than N tickets were available after the ignore list, existing plans, or the Notion filter, say how many were found and process only those.
- If the Notion MCP is unavailable, say so and stop.
- Remind the user they can say "ignore [ticket]" to add it to the ignore list for future runs.
- Remind the user they can run **/tasks** to see all projects (grouped by short_id, with category, summary, copy-pastable commands to open files) and to clean up plans/investigations for tickets whose Status Intl is done.
