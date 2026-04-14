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

### 2. Investigate issues one by one — follow every trail to its end

Go through the issues starting from the most frequent. For each issue:

- Read the issue details (title, frequency, trend, stack trace)
- **Investigate the root cause in depth** — do not stop at surface-level observations

#### Investigation depth requirements

For every issue, you MUST answer these questions before you can classify it:

1. **What is the root cause?** Read the stack trace, find the relevant code in the monorepo, understand why this error occurs.
2. **Can we prevent this error from happening at all?** Look at the code that produces the error. Is there a bug? A missing check? A misconfiguration?
3. **If the error comes from an upstream service (e.g. operations returns INTERNAL):** INTERNAL errors are bugs — something unexpected happened that the code didn't handle. Follow the trail into that service's code: find the RPC handler, read the code path, identify the exact line(s) that produce the error, and determine what the bug is. The fix belongs as close to the source as possible — in the service that produces the error, not in the caller. We own the entire monorepo; "fix belongs in service X" is a starting point, not a conclusion. Find the bug and propose the fix at the source.
4. **If the error is an expected business scenario (e.g. FAILED_PRECONDITION):** Why does it create a Sentry alert? Should CBO handle this status code gracefully instead of reporting it as an error? If yes, propose how. If there's a valid reason to keep the Sentry (e.g. it's a canary for a real problem), explain that reason explicitly.
5. **If it's an informational log that shouldn't be an error:** Why is it being reported to Sentry? Can we change the log level, filter it out, or fix the underlying condition so the log never fires?

#### Classification (only AFTER thorough investigation)

**Non-actionable** — use this classification sparingly, and only when you can explain why no code change would help:
- Client-side network errors (HTTP status 0, connection reset by peer) where the client simply disconnected — no server-side code path is involved
- Transient external-to-Stockly failures (e.g. a third-party API was briefly down) where we already have appropriate retry/fallback logic
- Already has a fix merged or in-progress (link the PR/commit)

**Actionable** (the default assumption — prove an issue is non-actionable, not the reverse):
- Any error where a code change in the monorepo could prevent, handle gracefully, or reduce the frequency of the issue
- Upstream service INTERNAL errors — these are bugs. Trace to the source, identify the failing code, and propose a fix at the origin (not a workaround in the caller)
- Expected business rejections that are reported as errors — with a proposal to handle them gracefully
- Informational logs reported at the wrong level — with a proposal to fix the log level or root cause

### 3. Limits

- Stop once you have **3 actionable** issues, OR after inspecting **10 issues** total, whichever comes first.

### 4. Output: multiple investigation files

**For each actionable issue**, write a separate investigation file:

`~/.claude/investigations/SHORTID-cbo-sentry-N.md` (where SHORTID is the ticket's short_id and N is 1, 2, 3...)

Each file uses the standard investigation header, with:
- `## Outcome` → `implementation-plan`
- The body should contain: Sentry issue title, link, frequency, stack trace summary, **root cause analysis with code references**, and an implementation plan to fix it. If the fix is in an upstream service, the plan targets that service — not CBO.

**For each frontend-only issue**, write a separate investigation file:

`~/.claude/investigations/SHORTID-cbo-sentry-fe-N.md`

Each file uses the standard investigation header, with:
- `## Outcome` → `frontend-ticket`
- The body should explain why this is frontend-only, which files/components are involved, and a suggested fix direction.

**For all genuinely non-actionable issues**, write a single file:

`~/.claude/investigations/SHORTID-cbo-sentries-non-actionable.md`

With:
- `## Outcome` → `next-steps`
- A table or list of each inspected non-actionable issue: title, frequency, and a **thorough explanation** of why no code change would help. "Upstream service error" or "expected behavior" are NOT sufficient explanations — you must show that you investigated the upstream code or the handling logic and concluded no improvement is possible.

### 5. Return to caller

Return: the list of files written, how many actionable vs non-actionable, and a one-line summary.
