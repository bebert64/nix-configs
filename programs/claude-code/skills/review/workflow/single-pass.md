# Single-Pass Review Workflow

One review round, typically run by the agent as the final step of its own implementation workflow. Not user-driven.

## Flow

1. Run one review round — all batches × all themes in parallel (see SKILL.md)
2. Collect and deduplicate findings
3. Apply all `FIXABLE: yes` findings automatically (must-fix and nits)
4. Commit fixes if any: `git commit -m "review: apply findings"`
5. Report a brief summary to the user: what was fixed, then — if any `FIXABLE: no` findings exist — a clearly separated warning section:

```
⚠ Findings outside this PR's diff (not auto-fixed — likely from a previous PR, verify before acting):
  path/to/file.rs:42 [Rule: naming] <brief description>
  ...
```

## No iterations

Stop after one round regardless of remaining findings.
