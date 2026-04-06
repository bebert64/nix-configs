Rules live under `~/.claude/rules/`:

- `global/` — always loaded (all machines)
- `stockly/` — Stockly-specific, loaded on monsters only

## Rule vs. review-skill placement

**Test**: would violating this guidance while *writing* code introduce a bug, silent failure, correctness issue, or steer the implementation toward the wrong pattern?

- **Yes → rule**: must be active during implementation.
  Examples: no silent fail, make invalid states unrepresentable, batch queries instead of N+1.

- **No → review skill rule** (`skills/review/rules/`): only checked during code review.
  The bar: is this easy to fix once the implementation is done?
  Examples: import ordering, comment style, variable inlining, visibility modifiers.

When in doubt, prefer the review skill. Rules are loaded on every task.
