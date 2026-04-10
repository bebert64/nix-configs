# Autonomous Review Workflow

The orchestrator runs repeated rounds of review and applies fixes automatically, until no findings remain at the current de-escalation level.

## Round loop

1. Run a full review round — all batches × all applicable themes in parallel (see SKILL.md)
2. Collect and deduplicate findings
3. Split findings: set aside all `FIXABLE: no` findings into a running accumulator (never fix these, just collect across rounds)
4. If no `FIXABLE: yes` findings at the current de-escalation level → **stop** (see Termination)
5. Apply all `FIXABLE: yes` findings as code fixes
6. Commit and push: `git commit -m "review: round N fixes"` then `git push`
7. Increment round counter → go to step 1

## De-escalation rules

As rounds progress, the scope narrows to focus only on what was likely missed earlier:

| Rounds | Themes active |
|---|---|
| 1–3 | All themes — Correctness + all style themes (Must-fix + Nits) |
| 4–6 | Correctness + all style themes, **Must-fix only** (Nits skipped) |
| 7+ | **Correctness only** — all style themes skipped |

The **Correctness** theme is never skipped, regardless of round number.

Each sub-agent must be told the current round number and its active severity filter so it omits findings below the threshold before returning results.

## Termination

Stop when a round produces zero findings given the current de-escalation level.

Final report:

```
Review complete after N rounds.
  Round 1: X findings fixed
  Round 2: Y findings fixed
  ...
  Round N: 0 findings — done

⚠ Findings outside this PR's diff (not auto-fixed — likely from a previous PR, verify before acting):
  path/to/file.rs:42 [Rule: naming] <brief description>
  ...
```

If the accumulator is empty, omit the warning section entirely.
