# Quality Tech Tickets (QTT) — Filter for start-qtt-investigations

When querying the Notion database "[DB] Quality Tech Tickets" to pick pending tickets for investigation:

- **Pending Workforce:** Filter by **Status Intl** = "0 - Pending Workforce" (source of truth) and **Status** = "0 - Pending Workforce" so results match the "0 - Pending Workforce" table view (e.g. ~34 entries). Status Intl is authoritative (a ticket can have Status = Pending Workforce but Status Intl = Done — exclude those).
- Also apply: Assignee empty, Teams Intl does NOT contain "Partner Inputs_Front".
- **Priority order:** By Severity (SEV1 first, then SEV2 … SEV5 last), then by Updated At descending. SEV4 must rank before SEV5. The Notion API sort by Severity may not return that order, so use **page_size 100** and rely on the parser (`parse_qtt.py`) to re-sort.

Data source ID: `d6cdb24f-62ac-4581-9503-c6035d22babf`. Database ID: `ebea444c-2ed2-4ed6-b6c4-76ec272de766`.
