---
name: operations-sentries
description: Triage the top Operations error/outage sentries — regroup them by top in-repo reporting site (file-level), then investigate each group against a catalog of pluggable "leads". Use when the user runs `/operations-sentries` or asks to look at Operations sentries.
---

# Operations Sentries Triage

Triages unresolved error/outage sentries for the **Operations** service (Sentry project id `1729915`). The skill is **analysis-only** — the sole output is one investigation file per group under `~/.claude/investigations/`. **Never write code, open PRs, or create branches.**

## Delegation model — the main agent orchestrates, sub-agents do the work

This skill is **token-heavy** (large Sentry payloads, full stack traces, multiple code reads per group). To keep the main context lean, the main agent is an **orchestrator only**. It delegates:

1. **Phase 1 in its entirety** (fetch → filter → fetch stack traces → regroup → sort) to **one sub-agent**. The sub-agent returns a compact JSON/markdown summary of groups; the main agent never sees raw Sentry payloads.
2. **Phase 2 per group** to **one sub-agent per group**. Each sub-agent investigates its assigned group end-to-end (load leads, match, investigate, write the investigation file) and returns only: the output file path, the matched lead (or `none`), and a one-line summary.

Launch Phase 2 sub-agents **in parallel** (up to 4 concurrently) using a single message with multiple Agent tool calls. The main agent stitches results together for the final return.

**Use `subagent_type: "general-purpose"`** for both phases unless a more specific agent type is clearly warranted. Each sub-agent must receive a self-contained prompt — it does not share the main agent's conversation history.

## Phase 1 — Fetch & regroup (delegated to a sub-agent)

Launch a single sub-agent with a prompt that instructs it to perform all four steps below and return a compact result. **Do not run these steps in the main agent.**

The sub-agent's prompt must include the skill path and must ask it to return, per group:

- Rank, total 14d occurrences
- Grouping key (top in-repo file path, relative to repo root)
- List of distinct reporting sites (`file::function (line)`)
- List of distinct entry points (bottom in-repo frames)
- List of distinct representative titles
- List of member Sentry shortIds + URLs + per-issue counts

The sub-agent must NOT dump raw Sentry payloads into its return.

### 1. Query Sentry

Call the Sentry MCP tool `mcp__sentry__list_issues` with exactly these parameters:

```json
{
  "organizationSlug": "stockly",
  "projectSlugOrId": "operations",
  "query": "is:unresolved issue.category:[error,outage]",
  "sort": "freq",
  "statsPeriod": "14d",
  "limit": 30,
  "regionUrl": "https://us.sentry.io"
}
```

Fixed facts (do not re-resolve them at runtime):
- Operations project slug: `operations` (numeric id `1729915` — either works).
- Stockly is on the US Sentry region: `https://us.sentry.io`.
- Issue ids look like `OPERATIONS-XXXX` and are returned in the `shortId` / `id` field of each issue.

Reference URL (for humans, not for fetching): `https://stockly.sentry.io/issues/errors-outages/?project=1729915&query=is%3Aunresolved%20issue.category%3A%5Berror%2Coutage%5D&referrer=issue-list&sort=freq&statsPeriod=14d`

### 2. Filter by volume

Keep only issues with **more than 1000 occurrences** in the 14d window. At time of writing this should return ~12 issues; if the count explodes (e.g. >30) stop and warn the user — Sentry's categorization may have drifted.

### 3. Regroup by top in-repo file

Sentry's default grouping splits same-bug issues across many entries because it weights the full stack (including entry points). Matching full stack traces only merges near-duplicates. A much better key is **the top in-repo reporting site**: the deepest stack frame that lives in the Stockly monorepo.

For each kept issue, call `mcp__sentry__list_issue_events` to fetch a recent event with its stack frames:

```json
{
  "organizationSlug": "stockly",
  "issueId": "<the shortId from phase 1, e.g. OPERATIONS-1J1R>",
  "statsPeriod": "14d"
}
```

Then, for each issue's stack trace:

1. **Strip non-repo frames.** Drop every frame whose absolute file path does NOT live under `/home/romain/Stockly/Main/`. This removes `internal_error::*`, `anyhow::*`, `diesel_helpers::*`, `clokwerk::*`, `rusty_pool::*`, `rayon_core::*`, `graceful_shutdown_sync::*`, `grpc_helpers_server::*`, `std::`, `core::`, `tokio::`, `tonic::`, `tower::`, third-party crates, etc. — keep only frames whose file path is a real file inside the monorepo.

   The check must be on the **file path**, not on the module path string — some crates have confusing module paths but the file path is authoritative.

2. **Identify the top in-repo frame.** After stripping, the top remaining frame is the "reporting site" — the function in our code where the error actually originated (where `.report()` / `err_msg!` / `err_ctx!` was called, or where the failing RPC call is issued).

3. **Extract the bottom in-repo frame.** The bottom remaining frame is the "entry point" — usually a scheduler handler, a gRPC unary handler, or a background worker loop. Keep it around; it's useful output but NOT part of the grouping key.

### 4. Compute the grouping key

The grouping key for an issue is the **file path of the top in-repo frame** (not the function — just the file). Two issues belong to the same group iff they share the same grouping key.

Why file-level and not function-level: the same file often contains several closely-related reporting sites (several functions or closures) that are really facets of the same bug. Merging at file level collapses them into a single investigation; the distinct reporting functions/lines are preserved in the group's output so the investigation can still see and address them separately.

### 5. Collect per-group data

For each group, record:

- **Grouping key** — the top in-repo file path (relative to the repo root), e.g. `operations/Service/src/demand/messages/send/send.rs`
- **Distinct reporting sites** — deduplicated list of `file::function (line)` tuples taken from the top in-repo frame of each member issue. Multiple entries here means the file has several closely-related failure points.
- **Distinct entry points** — deduplicated list of bottom in-repo frames across members (e.g. `schedule::init::{{closure}} (schedule.rs:147)`, `grpc::demand::register_message::perform`, ...). This tells the investigator which call paths feed the reporting site.
- **Distinct representative titles** — deduplicated list of the Sentry issue titles of the members. Multiple very different titles means the file fails in multiple ways; the investigation should say so.
- **Member Sentry issues** — every shortId + URL + per-issue count.
- **Total occurrences** — sum of counts across members.

### 6. Sort groups

Sort the resulting groups by **total occurrences**, descending. This is the investigation order.

## Phase 2 — Investigate each group (one sub-agent per group, in parallel)

Once Phase 1 returns, the main agent launches **one sub-agent per group**, in parallel (up to 4 concurrently per message). Each sub-agent is given a self-contained prompt containing:

- The group's full data from Phase 1 (member issues, occurrences, normalized stack trace, top frame).
- The path to this skill directory, with instructions to load every file under `leads/`.
- The target output file path (`~/.claude/investigations/operations-sentries-NN-SLUG.md`).
- Instructions to perform steps A–D below and write the investigation file itself.
- Instructions to return only: `{ file_path, matched_lead, one_line_summary }`.

The main agent does **not** perform steps A–D itself and does **not** read the investigation files it receives — it only collects the compact returns.

For each group, the assigned sub-agent:

### A. Load the leads catalog

Read every file under `leads/` in this skill directory. Each file describes one pattern (a "lead") and tells you:

- How to recognize a group that matches it
- What evidence to collect
- What recommended action to write out

Leads are **plug-in** — new patterns are added by dropping a new file in `leads/`. Do not hard-code lead logic in this SKILL.md.

### B. Try to match the group against each lead

For each lead, follow its matching procedure. A group matches a lead if the lead's conditions are clearly satisfied. Ambiguous matches are **not** matches — record them but keep searching.

### C. If a lead matches

Follow the lead's "recommended action" section to produce the investigation file body (see *Output* below).

### D. If no lead matches — switch to real investigation

Do a normal root-cause investigation:

1. Open the representative Sentry issue, read the error message, context, tags, and the full stack trace.
2. Read the code at the top in-repo frame. Walk up the call graph enough to understand what was being attempted.
3. Form a hypothesis for the root cause. Back it with code references (`file.rs:line`).
4. Propose a concrete next step: a fix direction, a question for the user, or a "needs more data" note with exactly which data.

The output file still uses the format below, with `## Matched lead` set to `none — investigated from scratch`.

### E. Quality bar for the `Recommended action` section — READ THIS CAREFULLY

The `Recommended action` is **not** a plan outline — it is a **ready-to-implement coding plan** that the user will hand to an implementer (human or agent) without further analysis. It must satisfy every point below. If you cannot satisfy a point, **do the missing verification right now during the investigation** rather than deferring it.

1. **No deferred verifications.** The recommended action must not contain phrases like "double-check that...", "verify that...", "confirm whether...", "TBD", "needs more analysis", "the implementer should investigate...". Every such check must be resolved during the investigation itself, and the **result** of the check baked into the action. Example: instead of "double-check that the caller handles the error without raising its own sentry", you must read the caller yourself, report what you found, and write the concrete change (or absence of change) needed at the caller.

2. **Exact file paths and line ranges.** Every change site must be named with `file.rs:line` or `file.rs:line-line`. No "somewhere in the module", no "the relevant call site".

3. **Before/after code** (or at minimum a precise description of the edit). For non-trivial edits, include a short before/after snippet. For trivial edits (rename, delete a line), naming the line is enough.

4. **All affected call sites enumerated.** If the fix touches a helper used in multiple places, list every caller you must also update (grep for it during the investigation). Do not leave "and anywhere else this is called" as an exercise.

5. **Status-code / Fail-variant discrimination baked in.** When a group's titles show mixed error flavors (different gRPC status codes, different `Fail` variants, different error messages), the action must address each flavor explicitly. Do not treat a heterogeneous group as a monolith — split the action by flavor, or explicitly state that flavor X is not handled by this change and why.

6. **External dependencies confirmed, not assumed.** When the recommendation depends on data living somewhere else (a downstream sentry already has the request payload; a DB trigger already enforces the invariant; a PR already merged the fix), the investigation must include the **actual verification** — open the downstream sentry event, read the trigger migration, find the commit — and quote the evidence in the `Evidence` section. The `Recommended action` section may then rely on it without caveats.

7. **Self-sufficient.** An implementer reading only the `Recommended action` section (plus the quoted `Evidence`) should be able to start editing code immediately, without having to re-run the investigation.

If any lead's action template produces an action that violates these rules, **override the template** and write a compliant action instead — the quality bar wins.

## Output — one investigation file per group

Path: `~/.claude/investigations/operations-sentries-NN-SLUG.md` where `NN` is the 1-based rank of the group (01 = most occurrences) and `SLUG` is a short kebab-case hint (e.g. `apico-register-tracking-timeout`).

Header (standard investigation header, see `~/.claude/rules/global/ai-behavior.md`):

```markdown
## Short ID
OPSNT

## Category
investigation

## Outcome
next-steps

## Summary
<one-line summary of what this group is and the recommended action>
```

Body:

```markdown
## Group

- **Rank:** NN of M
- **Total occurrences (14d):** <sum>
- **Top in-repo file:** `path/to/file.rs`
- **Reporting sites in that file:**
  - `function_a (line X)` — from issues OPERATIONS-AAAA, OPERATIONS-BBBB
  - `function_b::{{closure}} (line Y)` — from issue OPERATIONS-CCCC
- **Entry points that feed these sites:**
  - `scheduled job at schedule.rs:147`
  - `grpc handler Demand::register_foo`
- **Distinct titles seen:**
  - "<title 1>"
  - "<title 2>"
- **Member Sentry issues:**
  - <sentry issue url> — <individual count>
  - <sentry issue url> — <individual count>

## Matched lead

<lead file name, or "none — investigated from scratch">

## Evidence

<what you read in the code and what it tells you — include file:line references. If the group has multiple distinct reporting sites or multiple distinct titles, explicitly say whether you believe they are one bug or several, and if several, address each.>

## Recommended action

<concrete next step. If a lead matched, this comes from the lead's action template. Otherwise, your root-cause proposal. If the group contains multiple distinct bugs, list the action per reporting site.>
```

## Ledger — cross-run state

The skill maintains a **ledger** of groups it has already looked at so consecutive runs do not re-spend tokens on groups that are already investigated, in progress, implemented, or explicitly parked.

**Location:** `~/.claude/investigations/operations-sentries-ledger.json` (single JSON file, main-agent-written).

**Key:** the grouping key itself — the top in-repo file path, relative to repo root (e.g. `operations/Service/src/parcels/status_updates/parcel_items_to_osa/transmit_tracking_info.rs`). The file path is stable across runs; Sentry `shortId`s are not.

**Entry schema:**

```json
{
  "<file_path>": {
    "status": "investigated",
    "last_investigated_at": "YYYY-MM-DD",
    "last_occurrences_14d": 139441,
    "last_investigation_file": "operations-sentries-01-<slug>.md",
    "matched_lead": "01-re-reported-downstream-rpc",
    "summary": "<one-line>",
    "implemented_at": null,
    "pr": null,
    "notes": null
  }
}
```

**Statuses:**

- `investigated` — investigation file written, nothing shipped yet. Stale after **30 days** → re-investigate.
- `in_progress` — user is working on it / PR open. Skip on subsequent runs. (User marks this manually.)
- `implemented` — fix shipped. Populate `implemented_at` (ISO date) and `pr`. Skip on subsequent runs **unless** Sentry still has unresolved post-fix events (see below).
- `wontfix` — user decided to leave as-is. Skip forever. `notes` must contain the reason.

### Phase 1 ledger integration

After computing the groups (before sorting / returning), the Phase 1 sub-agent must:

1. **Load the ledger.** Read `~/.claude/investigations/operations-sentries-ledger.json`. If the file does not exist, treat it as `{}`.
2. **Classify each group** against its ledger entry into one of three buckets:
   - **fresh** — no ledger entry for this file path. Investigate.
   - **re-investigate** — one of:
     - entry status is `investigated` and `last_investigated_at` is older than 30 days (stale);
     - entry status is `implemented` **and** any member issue's `lastSeen` timestamp (from the Sentry API response) is after `implemented_at`. This means new sentries have fired since the fix — the fix did not work (or regressed). Volume is irrelevant; any post-fix activity triggers re-investigation.
     - entry status is `investigated`/`implemented` but the `matched_lead` or investigation file is missing/unreadable — treat as stale.
   - **skip** — everything else (status `in_progress`; status `wontfix`; status `investigated` and recent; status `implemented` with no post-fix activity).
3. **Return the classification** alongside the group data so the main agent can act on it.

Phase 1 must pass through `lastSeen` for each member issue so the main agent can compute the post-fix check without a second Sentry fetch. `mcp__sentry__list_issues` returns `lastSeen` per issue.

### Phase 2 skip and return contract

The main agent launches Phase 2 sub-agents only for **fresh** and **re-investigate** groups. It does **not** spawn sub-agents for **skip** groups.

Each Phase 2 sub-agent, in addition to its existing return, must include a `ledger_entry` object for its group in its compact return. Schema:

```json
{
  "file_path": "...",
  "matched_lead": "...",
  "one_line_summary": "...",
  "ledger_entry": {
    "grouping_key": "operations/Service/src/.../foo.rs",
    "status": "investigated",
    "last_investigated_at": "YYYY-MM-DD",
    "last_occurrences_14d": 12345,
    "last_investigation_file": "operations-sentries-NN-<slug>.md",
    "matched_lead": "...",
    "summary": "<one-line>"
  }
}
```

The sub-agent **does not write the ledger itself**. It only returns the entry.

### Main agent responsibilities

After Phase 1:

1. **Show the skip list to the user** — one compact line per skipped group: `"[<status>] <file_path> (<last_occurrences_14d> → <current_occurrences_14d>) — <reason>"`. Include it in the final summary so the user can override any skip on the spot (they may say "also re-investigate group X" and the main agent then spawns a sub-agent for it).
2. **Launch Phase 2** only for fresh + re-investigate groups, in parallel batches of ≤4.
3. **After Phase 2 completes**, merge each sub-agent's `ledger_entry` into the on-disk ledger:
   - Load `~/.claude/investigations/operations-sentries-ledger.json` (default `{}`).
   - For each returned entry, upsert by `grouping_key`. Do not overwrite `status`, `implemented_at`, `pr`, or `notes` if they are already set to a "sticky" value (`in_progress`, `implemented`, `wontfix`) — in that case only refresh the volume/last-seen fields and leave the sticky metadata alone.
   - Write the ledger back.
4. **Report ledger changes** in the final user-facing summary: N entries created, N updated, N skipped, N manually-marked entries preserved.

### Manual transitions (user-driven)

When the user tells the main agent "I shipped the fix for group NN" / "parking group NN as wontfix" / "opened PR #XYZ for group NN":

- The main agent finds the group's entry in the ledger (keyed by the grouping file path from the investigation file).
- Updates `status`, `implemented_at` (if implemented), `pr`, `notes` accordingly.
- Writes the ledger back.

Future runs then honor the new status automatically.

## Return to caller

After writing all files and merging the ledger, return:

- Number of groups investigated this run (fresh + re-investigate)
- Number of groups skipped, with one line each (status, file path, last-known volume → current volume, reason)
- For each investigated group: rank, total occurrences, matched lead (or "none"), one-line action
- The list of investigation file paths written
- Ledger summary: `created`, `updated`, `preserved-sticky` counts
