---
name: investigate
description: Investigates a Notion ticket. Use when the user asks to investigate a QTT, a Quality Tech ticket, a Notion ticket URL, or when following up on a ticket from the start-qtt-investigations workflow.
---

# Investigate a Notion ticket

Investigate the ticket from the given Notion page URL. Do not guess when information is missing; report what is missing and ask clarifying questions. **Never start coding, create branches, or create worktrees.** The sole output is an investigation file written to `~/.claude/investigations/`.

## Before choosing an outcome

### 0. Check for special case instructions (if provided)

If the caller passed a special-case instruction file path, **read that file before anything else** and follow its instructions. The special-case file takes precedence over all steps below — it may skip the Notion retrieval, define a specific investigation procedure, output format, or checklist. If it says to skip step 1 below, skip it.

### 1. Obtain and read Notion content (default first step)

**Unless a special-case file explicitly says to skip this step**, you must attempt to read the ticket page and all comments before doing any other investigation. Do not infer the ticket from code or Sentry alone.

- **How:** Use the Notion MCP (retrieve page + comments). If the MCP is not available, stop there and warn the user. Do NOT move to the next phase.
- **In your output:** State whether you read the comments, and if a human left a diagnostic, quote or summarize it and say how your conclusion follows from or differs from it.

### Then: use human diagnostic as the lead

**If there is a human diagnostic in the comments:** Treat it as the default lead. Evaluate whether they seem confident or are guessing; either way, investigate that lead first. Only suggest a different solution if you are absolutely sure the human diagnostic is wrong. Your investigation must explicitly reference the human diagnostic (e.g. "As suggested in the comments, …" or "The comment suggested X; we confirm / we diverge because …").

After investigating, choose exactly one of the outcomes below and write the corresponding investigation file.

---

## Investigation file format

**All investigation files** are written to `~/.claude/investigations/SHORTID-SLUG.md` (e.g. `~/.claude/investigations/ABCDE-fix-login.md`). Create the `~/.claude/investigations/` directory if it doesn't exist.

Every file starts with this header:

```markdown
## Short ID
ABCDE

## Category
investigation

## Notion URL
https://www.notion.so/...

## Outcome
<one of: implementation-plan, next-steps, agent-prompt, frontend-ticket, other>

## Summary
<one-line summary of the ticket and conclusion>
```

The rest of the file depends on the outcome type (see below).

If `~/.claude/plans/_index.json` exists, update it to include this investigation (use type `"investigation"`, category `"qtt"`).

---

## Outcome types

### 1. Implementation plan (`implementation-plan`)

When the fix or feature requires code changes (backend, scripts, config-as-code):

After the header, write a detailed implementation plan:

```markdown
## Root cause
<What is causing the issue — be specific, reference code paths>

## Human diagnostic
<Quote or summarize any human comments, and whether you agree/disagree>

## Implementation plan

1. <Step>
   A. <Sub-step>
   B. <Sub-step>
2. <Step>
   A. <Sub-step>

## Files to modify
- `path/to/file.rs` — <what to change>
- `path/to/other.rs` — <what to change>

## Tests to verify
- <How to verify the fix>
```

The plan must be detailed enough that another agent (or the user) can implement it without re-investigating.

### 2. Next steps (`next-steps`)

When resolution is clear and does not require writing code (e.g. config change, manual step, known runbook, close as duplicate, needs monitoring):

```markdown
## Next steps

1. <Concrete action>
2. <Concrete action>
3. ...
```

### 3. Agent prompt (`agent-prompt`)

When the ticket needs a dedicated conversation with another agent — complex investigation, needs more context gathering, or requires interactive back-and-forth:

```markdown
## Agent prompt

<Ready-to-paste prompt for another agent session. Include: context, goal, what is already known, what needs to be figured out, and any relevant file paths or links.>
```

### 4. Frontend ticket (`frontend-ticket`)

When the required work is mostly front-end:

```markdown
## Why this is a frontend ticket

- <Reason 1: e.g. "The bug is in the React component at path/to/Component.tsx">
- <Reason 2: e.g. "No backend changes needed — the API returns correct data">
- <Relevant files/areas>

## Suggested fix direction
<Brief description of what needs to change on the frontend>
```

### 5. Other

For anything that doesn't fit the above (e.g. product decision needed, cross-team coordination, unclear requirements):

```markdown
## Assessment
<What you found, why it doesn't fit the other categories>

## Recommended action
<What should happen next — who to talk to, what decision to make, etc.>
```

---

## Return to caller

After writing the file, return: the investigation file path, the outcome type, and a one-line summary.
