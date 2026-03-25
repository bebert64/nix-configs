## Two-phase execution model

Concentrate questions upfront, then execute autonomously.

### Phase 1 — Explore & ask

Read code, investigate context, identify all unknowns. Then ask every question needed in a single, thorough round. No question is too small — the goal is to eliminate ambiguity before committing to work.

**Task tiers** determine phase 1 depth:
- **Light tasks** (bug fixes, style fixes, test additions, small migrations): brief exploration, few or no questions.
- **Heavy tasks** (new features, architecture, cross-service work): deep exploration, comprehensive question round.

### Phase 2 — Execute & verify

Once answers are in, work autonomously through the full implement → compile → test → lint → fix loop without stopping to ask.

**Only interrupt phase 2 for genuine surprises** — code doesn't behave as documented, a design assumption is wrong, or a decision with significant trade-offs wasn't covered in phase 1.

## Asking and confirming

- If anything's unclear during phase 1, **ask** — asking is non-negotiable.
- If rules conflict with each other, with what the user is trying to achieve, or with what the user asks for, always ask for instructions instead of trying to resolve the conflict independently.
- **NEVER fall back on an "easier" route without confirming with the user first and explaining why.** Always ask before simplifying or changing approach.
- **Wait for confirmation before implementing design decisions**: When discussing architecture/design with multiple valid approaches, present the options and wait for explicit approval before writing code.

## Verification

Implementation must include verification. After code changes:

- Run compilation checks after each change.
- Run lints + tests after each logical unit.
- On failure: read error → fix → re-run → loop until green or escalate to the user.
- Never commit code that doesn't compile.

## Testing

- For any code change touching logic, identify affected tests and run them before and after the change.
- Do NOT create new tests unless the user explicitly asks.
- **Bug fix exception**: write a failing test that reproduces the bug, then implement the fix, then confirm the test passes. This is the one case where creating a test without being asked is appropriate.

## Proactivity

- **Make things better as you go** — consider improvements while working, but ask when they imply non-trivial changes. Suspect existing patterns might be that way for good reason, but don't blindly follow suboptimal patterns.
- **Be proactive about taking notes**: When the user teaches something new (patterns, preferences, libs to use, things to avoid), add it to the appropriate rule file immediately. Don't be reticent — if in doubt, write it down. Forgetting is expensive.
- **Self-review expectations**: When asked to self-review or look for improvements, proactively suggest simplifications like removing unnecessary closures, inlining code, eliminating redundant variables, etc. Don't wait for the user to spot these — finding them is part of the review.

## Tooling

- **Don't bypass tooling**: When a tool isn't working as expected, do not assume it's a bug or try to work around it manually. Instead, assume you're either using it incorrectly or there's an issue, and ask the user what to do next. Never bypass tooling without asking first.

## Code review

- When reviewing PRs, always commit and push the changes at the end so the user can see the review diff on GitHub.

## Plans

These rules apply **whenever** you create or write a plan or investigation file under `~/.claude/plans/` — including when the user did not explicitly ask for a "plan". Do not skip them.

- **Implementation plan formatting**: Use numbered top-level steps (1., 2., 3.) and lettered sub-points (A, B, C) so that implementation items are labeled 1.A, 1.B, 2.A, 2.B, etc.
- **Always include the git branch**: Before creating a plan, run `git branch --show-current` and include a `## Branch` line at the top of the plan body (use the actual branch name).
- **Required in every plan/investigation file**: `## Short ID` (next line: the 5-character ticket code or identifier) and `## Category` (next line: one of `qtt`, `review`, `tech-task`, or another category). Optional: `## Status`.
- **Index**: If `~/.claude/plans/_index.json` exists, update it: ensure there is a project entry with `short_id`, `category`, and `files` containing `{ "path": "<basename>.md", "type": "plan"|"investigation" }`; set `notion_page_id` if the plan is tied to a Notion ticket, and `updated_at` (ISO date). Merge with existing projects array; do not overwrite the whole file with a single project.
