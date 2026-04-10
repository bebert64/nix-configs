# Special case: Check on consumer_backoffice sentries

## Identification
Title (after the 5-char short_id prefix and separator) matches "Check on consumer_backoffice sentries" (case-insensitive). Example: "PRC5Q: Check on consumer_backoffice sentries".

## Important: do NOT read the Notion ticket

This is a recurring ticket whose content never changes. All the context you need is in this file. **Skip the Notion page retrieval step entirely** — do not call retrieve-a-page or retrieve-a-comment for this ticket. The Notion URL is still included in the investigation file headers for reference, but you must not fetch it.

## Procedure

### 1. Query the Sentry dashboard

Use the Sentry MCP to list issues for the consumer_backoffice projects in production over the last 7 days. The relevant Sentry project slugs are:
- `consumer-backoffice`
- `consumer-backoffice-front`

Organization: `stockly`. Environment: `prod`. Time range: last 7 days. Sort by frequency (most recurring first).

### 2. Inspect issues one by one

Go through the issues starting from the most frequent. For each issue:

- Read the issue details (title, frequency, trend, stack trace)
- Determine if it is **actionable** or **non-actionable**

**Non-actionable** (skip these):
- Network errors (HTTP status code 0, connection timeouts, DNS failures)
- Known transient issues (third-party API flakiness, rate limits)
- Already assigned to someone or already has a linked ticket in the comments
- Already resolved/ignored in Sentry

**Frontend-only** (flag but don't count as actionable):
- Errors whose fix is entirely in frontend code (React components, CSS, client-side JS)
- These get their own investigation file with outcome `frontend-ticket`, but do NOT count toward the 3-actionable limit

**Actionable** (investigate further):
- New or increasing errors that indicate a real bug fixable in backend/non-frontend code
- Errors with a clear root cause that can be fixed in code
- Recurring errors that haven't been addressed and aren't transient

### 3. Limits

- Stop once you have **3 actionable** issues, OR after inspecting **10 issues** total, whichever comes first.

### 4. Output: multiple investigation files

**For each actionable issue**, write a separate investigation file:

`~/.claude/investigations/SHORTID-cbo-sentry-N.md` (where SHORTID is the ticket's short_id and N is 1, 2, 3...)

Each file uses the standard investigation header, with:
- `## Outcome` → `implementation-plan`
- The body should contain: Sentry issue title, link, frequency, stack trace summary, root cause analysis, and an implementation plan to fix it.

**For each frontend-only issue**, write a separate investigation file:

`~/.claude/investigations/SHORTID-cbo-sentry-fe-N.md`

Each file uses the standard investigation header, with:
- `## Outcome` → `frontend-ticket`
- The body should explain why this is frontend-only, which files/components are involved, and a suggested fix direction.

**For all non-actionable issues**, write a single file:

`~/.claude/investigations/SHORTID-cbo-sentries-non-actionable.md`

With:
- `## Outcome` → `next-steps`
- A table or list of each inspected non-actionable issue: title, frequency, and why it's non-actionable (e.g. "network error — status 0", "already assigned to X", "transient third-party timeout").

### 5. Return to caller

Return: the list of files written, how many actionable vs non-actionable, and a one-line summary.
