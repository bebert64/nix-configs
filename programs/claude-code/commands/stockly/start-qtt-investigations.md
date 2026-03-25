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
- **Before selecting tickets:** Read this file if it exists. Build a set of ignored page IDs. When building the candidate list (after filter and sort), exclude any page whose `id` is in that set. **Also exclude** any ticket that already has a corresponding plan or investigation in `~/.cursor/plans/` (see below). Then take the first **N** remaining.
- **Exclude tickets that already have a plan or investigation:** List files in `~/.cursor/plans/` (`.md` only). A ticket (with short_id e.g. `ABCDE`) is considered to have one if there is a file whose name starts with `<short_id>-` (e.g. `ABCDE-fix-login.md`, `ABCDE-investigation-2025-02-26T143052.md`), or a plan file whose content contains a `## Short ID` section with that same short_id. Exclude those tickets from the list before taking the top N.
- **Adding to the list:** If at any point (in this run or a follow-up) the user says they want to ignore a ticket (e.g. "ignore this one", "skip ABCDE", "add to ignore list"), append that ticket's Notion page ID to the file on a new line. Confirm to the user. The next run of this command will then skip it.
- If the file doesn't exist, create it when first adding an ID; otherwise proceed with an empty ignore set.

## 2. Notion database

- **Database (for retrieve):** `ebea444c-2ed2-4ed6-b6c4-76ec272de766` — "[DB] Quality Tech Tickets"
- **Data source (for query):** `d6cdb24f-62ac-4581-9503-c6035d22babf` (use this in `query-data-source`)

If the data source ID is missing, call `retrieve-a-database` with the database ID above; the response includes `data_sources[0].id`.

## 3. Filter and sort

**Notion MCP — query with status filter, then paginate if needed:** The API filter is applied server-side so you fetch only pending tickets (~38), not the full database. The parser still applies Assignee empty and Teams Intl ≠ Partner Inputs_Front.

- **Filter (property + type):** Use **Status Intl** with **select** and **equals**. This returns ~38 rows. Do not use "Status" or "status" — the source of truth is Status Intl.

1. **First request:** Call `API-query-data-source` (user-Notion) with:
   - **data_source_id:** `d6cdb24f-62ac-4581-9503-c6035d22babf`
   - **page_size:** **100**
   - **sorts:** `[{"property": "Severity", "direction": "ascending"}, {"property": "Updated At", "direction": "descending"}]`
   - **filter:** `{"property": "Status Intl", "select": {"equals": "0 - Pending Workforce"}}`

   The tool returns a message like "Large output has been written to: .../agent-tools/<uuid>.txt". Read that file; the JSON has `results`, `next_cursor`, and `has_more`.

2. **Paginate:** While the response has `has_more` true and a non-empty `next_cursor`, call `API-query-data-source` again with the **same** parameters (including **filter**) plus **start_cursor:** the value of `next_cursor` from the previous response. Read each new output file and append its `results` to your collected list.

3. **Merge:** Build a single JSON object: `{"results": <all collected page objects>}`. Write it to a file (e.g. the path of the first response file, or a new path under agent-tools) so the parser can read it.

4. **Parser:** The Notion API sort by Severity may not return SEV4 before SEV5; the parser re-sorts by Severity (SEV1 first, SEV5 last) then Updated At descending. Pass the **merged** file path to the parser.

**Get top N and apply ignore list and existing plans:** Run the parser so you get structured lines you can use (id, url, title, short_id). Parser path: `python3 /home/romain/Stockly/.cursor/parse_qtt.py <path_to_json_file> [N]` — N defaults to 3. It reads the JSON from the Notion query result file, filters (Status Intl = Pending workforce, Assignee empty, Teams Intl not Partner Inputs_Front), sorts by Severity then Updated At, prints `candidates_count=<m>` on stderr and one line per ticket `rank|id|url|title|short_id` for the top N. Then exclude any line whose `id` is in the ignore set, any ticket whose short_id already has at least one file in `~/.cursor/plans/` (filename starting with `<short_id>-`, e.g. plan or investigation). Take the first **N** tickets from the remaining list (if the parser was run with a large N, you already have a sorted list; drop ignored and already-planned, then take first N).

## 4. Investigate in parallel

For each of the top N tickets, launch a **subagent** (Task tool) with this prompt:

1. **Read and follow** the instructions in **`.cursor/skills/qtt-investigation/SKILL.md`** (path relative to workspace root). That skill defines how to investigate a Quality Tech ticket and the three possible outcomes (code → plan file; easy → next steps; else → ready-to-paste prompt).
2. **Then investigate** the ticket at the given Notion page URL.

When calling the Task tool, pass a single prompt that: (a) tells the subagent to read and follow `.cursor/skills/qtt-investigation/SKILL.md`, then (b) gives the ticket's Notion page URL (from the `url` field of the result) and asks to investigate that ticket.

Let each subagent return: clarifying questions **or** one of the three outcomes (A: plan path + branch; B: next steps; C: ready-to-paste prompt).

**Stream results:** As soon as the **first** subagent (or any subagent) returns, **immediately** produce and display that ticket's super-synthetic resume (section 5) to the user — do not wait for the others. As each further subagent returns, produce and display that ticket's resume in turn. When **all** subagents have returned, output the final section (section 6). This way the user sees results as they complete instead of waiting for the slowest one.

## 5. Super-synthetic resume per ticket

For each ticket, **as soon as** its subagent responds, produce exactly one of these three outcomes in a short, scannable block. The subagent should have chosen based on: **code will be needed** → A; **else, if easy** → B; **else** → C.

**A. Code will be needed (plan + branch)**

- Any amount of code, small or big, is fine. Create the plan file so **open-plans** will match it when the user is on the ticket's branch (the branch name is created by Stockly tooling and always includes the Short ID):
  - Path: `~/.cursor/plans/<short-id>-<slug>.md` (e.g. `~/.cursor/plans/ABCDE-fix-login.md`).
  - Content must include a line `## Short ID` and on the next line the **5-character Notion ticket code** (e.g. `ABCDE`). open-plans matches if the current branch name equals a `## Branch` value in the plan, or if the current branch **contains** that Short ID.
- **Open the plan in Cursor:** After writing the plan file, open it in the editor (e.g. run `cursor <absolute-path-to-plan>` or the equivalent so the file opens in Cursor; if that is not available, show the path clearly so the user can open it).
- In the resume: ticket title + short ID, one line "what it is", and: "**Plan + branch.** Plan written to `~/.cursor/plans/<filename>.md`. Switch to (or create) the ticket branch, open a new Agent window, and run open-plans to load the plan."

**B. Easy — summarize precisely the next steps**

- No plan file. In the resume: ticket title + short ID, one line "what it is", and: "**Next steps:**" followed by a short, ordered list of concrete steps the user should do to resolve it (no extra conversation needed).

**C. Else — prompt for another agent**

- No plan file. In the resume: ticket title + short ID, one line "what it is", and: "**Use a dedicated conversation.**" Then provide a **ready-to-paste prompt** the user can paste into a new Agent chat (context + goal + what's already known).

**After producing and displaying the resume for a ticket:** Persist the investigation result so the user can review it later (e.g. after closing the window or in a new agent). (1) Ensure `~/.cursor/plans/` exists (create the directory if it does not). (2) Write one `.md` file there with filename `{short_id}-investigation-{date}T{time}.md` (e.g. `ABCDE-investigation-2025-02-26T143052.md`; use ISO date and time without colons). File content: a header with `# {ticket title}`, `Short ID: {short_id}`, `## Category` and on the next line `qtt`, `Notion: {notion_url}`, `Notion page ID: {id}` (use the parser result `id` field), `Investigation date: {iso-date}`; then `## Resume` and the super-synthetic resume block you just displayed; then `## Full investigation` and the full subagent response. (3) If `~/.cursor/plans/_index.json` exists, update it to include this new file (see tasks command for index schema). This allows tasks to list summaries and clean up Done tickets.

## 6. Final output

After **all** subagents have returned (and you have already displayed each ticket's resume as it completed):

- Provide a consolidated list of the N tickets with their super-synthetic resume (A, B, or C) and ticket URL, so the user has everything in one place.
- If fewer than N tickets were available after the ignore list, existing plans, or the Notion filter, say how many were found and process only those.
- If the Notion MCP is unavailable, say so and stop.
- Remind the user they can say "ignore [ticket]" to add it to the ignore list for future runs.
- Remind the user they can run **/tasks** to see all projects (grouped by short_id, with category, summary, copy-pastable commands to open files) and to clean up plans/investigations for tickets whose Status Intl is done.
