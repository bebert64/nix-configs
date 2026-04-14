---
description: Start Quality Tech Ticket investigations — pick pending tickets from Notion, investigate in parallel, write investigation files
---

Run this workflow to select unassigned Quality Tech tickets (**Status Intl** = "0 - Pending Workforce", Teams Intl ≠ Partner Inputs_Front), prioritize them, and have subagents investigate each one. Every investigation produces a file in `~/.claude/investigations/`.

**Important:** Use **Status Intl** (not "Status") for "pending" — Status Intl is the source of truth; a ticket can have Status = "0 - Pending Workforce" but Status Intl = "Done" and must be excluded.

## 0. How many tickets

- If the user specified a number in their message (e.g. "pick 5 tickets", "just 1"), use that.
- Otherwise use the default: **6**.
- Call this number **N**. This is the target number of **non-frontend** investigation files to produce. Frontend tickets don't count toward N — see section 5 for details.

## 1. Ignore list (local) and cleanup

- **File:** `/home/romain/Stockly/.cursor/ignored-quality-tickets.txt`
- **Format:** One Notion page ID per line (the `id` field from the API, e.g. `0000fd7f-2f85-49c5-8cd8-a61f0b731b47`). No header. Strip whitespace; skip empty lines.
- **Before selecting tickets:** Read this file if it exists. Build a set of ignored page IDs. When building the candidate list (after filter and sort), exclude any page whose `id` is in that set. **Also exclude** any ticket that already has a corresponding investigation in `~/.claude/investigations/` (see below). Then take the first **N** remaining.
- **Exclude tickets that already have an investigation:** List files in `~/.claude/investigations/` (`.md` only). A ticket (with short_id e.g. `ABCDE`) is considered to have one if there is a file whose name starts with `<short_id>-` (e.g. `ABCDE-fix-login.md`). Also check `~/.claude/plans/` for backward compat. Exclude those tickets from the list before taking the top N.
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
   - **sorts:** `[{"property": "Severity", "direction": "ascending"}, {"property": "Created At", "direction": "ascending"}]`
   - **filter:** `{"and": [{"property": "Status Intl", "select": {"equals": "🔴 0 - Pending Workforce"}}, {"property": "Assignee", "people": {"is_empty": true}}]}`
     > **Note:** The Status Intl values have emoji prefixes (🔴, 🔵, etc.). The parser also filters out assigned tickets as a safety net.

   The tool returns a message like "Large output has been written to: .../agent-tools/<uuid>.txt". Read that file; the JSON has `results`, `next_cursor`, and `has_more`.

2. **Paginate:** While the response has `has_more` true and a non-empty `next_cursor`, call `API-query-data-source` again with the **same** parameters (including **filter**) plus **start_cursor:** the value of `next_cursor` from the previous response. Read each new output file and append its `results` to your collected list.

3. **Merge:** Build a single JSON object: `{"results": <all collected page objects>}`. Write it to a file (e.g. the path of the first response file, or a new path under agent-tools) so the parser can read it.

4. **Get top N and apply ignore list and existing investigations:** Run the parser so you get structured lines you can use (id, url, title, short_id, severity, created_at). Parser path: `python3 ${CLAUDE_SKILL_DIR}/parse_qtt.py <path_to_json_file> [N]` — N defaults to 6. It prints `candidates_count=<m>` on stderr and one line per ticket `rank|id|url|title|short_id|severity|created_at` for the top N. Then exclude any line whose `id` is in the ignore set, any ticket whose short_id already has at least one file in `~/.claude/investigations/` or `~/.claude/plans/` (filename starting with `<short_id>-`). Take the first **N** tickets from the remaining list.

## 4. Detect special cases

Before launching subagents, check each ticket against the special case rules below. If a ticket matches, the subagent will receive an additional instruction file path to guide its investigation.

**Special case definitions** are stored in `${CLAUDE_SKILL_DIR}/special-cases/`. Each file there describes: (a) how to identify the ticket (title pattern, keywords, etc.) and (b) specific investigation instructions.

**Current special cases:**

| Pattern | File | How to identify |
|---------|------|-----------------|
| Check on consumer_backoffice sentries | `inspect-cbo-sentries.md` | Title (after the short_id prefix) matches "Check on consumer_backoffice sentries" (case-insensitive) |

For each ticket, check if its title matches any special case pattern. If it does, record the path `${CLAUDE_SKILL_DIR}/special-cases/<filename>` to pass to the subagent.

## 5. Investigate in parallel (with frontend backfill)

Launch subagents for the top **N** candidate tickets. For each, launch a **subagent** (Task tool) with a prompt that invokes the **`investigate`** skill and passes:
- The ticket's Notion page URL (from the `url` field of the result)
- The ticket's short_id
- If a special case was detected: the path to the special-case instruction file (e.g. `"Special case instructions: read <path> before investigating."`)

**Critical:** The investigate skill will ONLY write an investigation file — it will never start coding or create branches.

**Notification:** Send a notification to the user as soon as each subagent finishes (e.g. "Investigation done: ABCDE — <outcome type>").

**Frontend backfill:** N is the target number of non-frontend investigations. Each time a subagent returns with outcome `frontend-ticket`, pick the next candidate from the remaining pool (after ignore list and existing investigations) and launch a new subagent for it. Continue until you have **N non-frontend** investigation files or you run out of candidates.

**Stream results:** As soon as any subagent returns, **immediately** produce and display that ticket's super-synthetic resume (section 6) to the user — do not wait for the others.

## 6. Super-synthetic resume per ticket

As soon as a subagent returns, display a short scannable block: ticket title + short ID, one line "what it is", then the outcome type and a one-line summary of the investigation file content.

## 7. Final output

After **all** subagents have returned (and you have already displayed each ticket's resume as it completed):

- Provide a consolidated table of all investigated tickets (including frontend ones) with columns: **#**, **Short ID** (linked to Notion URL), **Title**, **Severity**, **Created**, **Outcome**, **Summary**. Clearly separate frontend tickets from the rest.
- State how many non-frontend investigations were produced vs. the target N.
- If fewer than N non-frontend tickets were available after the ignore list, existing investigations, or the Notion filter, say how many were found and process only those.
- If the Notion MCP is unavailable, say so and stop.
- Remind the user they can say "ignore [ticket]" to add it to the ignore list for future runs.
- Remind the user they can run **/tasks** to see all projects (grouped by short_id, with category, summary, copy-pastable commands to open files) and to clean up investigations for tickets whose Status Intl is done.
