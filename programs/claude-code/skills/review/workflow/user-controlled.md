# User-Controlled Review Workflow

The orchestrator runs one review round per user request and reports findings only — it never modifies files. The user drives pacing and decides when to stop.

## Round flow

1. Run a full review round — all batches × all themes in parallel (see SKILL.md)
2. Load `.claude/reviews/<branch-name>.json` if it exists
3. Re-validate each approved item against the current code (see Re-validation below)
4. Filter out still-valid approved items from findings
5. Present remaining findings to the user using this format:

   ```
   ## path/to/file.rs

   ### Must-fix

   1. **[Guideline: <rule name>]** <brief description>
      Lines: 42, 78
      Current:
      <code block>
      Suggested:
      <code block>

   ### Nit

   1. **[Guideline: <rule name>]** <brief description>
      Line: 15
      Current / Suggested as above

   ---

   ## Summary

   - X must-fix across Y files
   - Z nits across W files
   ```
6. Wait for user action — they may approve findings, request another round, or stop

## Approved findings file

To avoid re-surfacing accepted trade-offs in subsequent rounds, approvals are persisted in:

```
.claude/reviews/<branch-name>.json
```

Each entry:

```json
{
  "file": "path/to/file.rs",
  "lines": [42, 78],
  "rule": "naming",
  "user_reasoning": "We use this name for consistency with the external API",
  "code_snapshot": "<exact content of those lines at the time of approval>"
}
```

The `code_snapshot` captures exactly the code the user was reasoning about. It is the anchor for re-validation.

## Re-validation

Before filtering, the orchestrator must verify each approval is still sound:

1. Read the current file content at the approved lines
2. Compare with `code_snapshot`
3. **Unchanged** → approval is still valid; filter the finding out
4. **Changed** → re-surface the finding with a warning:
   `⚠ Previously approved but code has changed — re-review`

This prevents a code edit from silently invalidating the user's reasoning (e.g., a renamed variable that was the entire basis for approving a naming decision).

## Approving a finding

After each round the user may say something like:

> "Approve finding 3 in service/foo.rs — keeping this pattern for consistency with the client"

The orchestrator then:
1. Records the approval to `.claude/reviews/<branch-name>.json` with the user's reasoning verbatim
2. Captures the current code snapshot at the relevant lines
3. Confirms which finding was approved and asks if they want another round

## No automatic fixes

The orchestrator never modifies source files in this mode. If the user wants a fix applied they ask for it explicitly, outside the review workflow.
