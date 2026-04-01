---
description: Review all changes on the current branch — correctness, bugs, and style. Use when the user asks for a code review or /review. With "fix" argument, applies style fixes and commits them.
---

# Review

Review ALL changes introduced by the current branch (not just uncommitted changes).

## Modes

- `/review` — full review: correctness + style, report only
- `/review fix` — style fixes only: apply corrections and commit

## Workflow

### 1. Gather the diffs

Determine the base branch (usually `main` or `master`):

```bash
git diff origin/master...HEAD  # or origin/main...HEAD
git diff                        # unstaged
git diff --staged               # staged
```

If all empty, report "No changes to review" and stop.

### 2. Filter out non-reviewable files

Skip entirely:

- Generated files (e.g., proto-generated `*.rs` files in `protobuf_gen/` directories, `schema.rs`)
- Lock files: `Cargo.lock`, `pnpm-lock.yaml`
- Non-code: `*.md`, `*.json`, `*.yaml`, `*.yml`

### 3. Load context

Check if `git remote get-url origin` points to a known codebase and read `${CLAUDE_SKILL_DIR}/<codebase>.md` if it exists — it may add file filters, a guideline table, and additional checks.

### 4. Select applicable guidelines

Read rule files from `~/.claude/rules/` whose `paths:` frontmatter matches the changed file types. The codebase overlay (step 3) may provide an explicit table that supplements or overrides this.

### 5. Review each changed file

Use the Task tool to review up to 4 files concurrently. For each file:

1. Read the full file for context
2. Focus review **only on changed/added lines** — never flag unchanged code
3. In `/review` mode, check for:
   - Correctness and potential bugs
   - Missing or incorrect error handling
   - Performance concerns
   - Any TODO/FIXME left behind
   - Style, naming, comments, and code organization (built-in conventions in `conventions.md` + loaded rule files)
   - Spelling and grammar
4. In `/review fix` mode, check style only (conventions + rule files) — skip correctness
5. Every finding from rule files **must** reference the specific rule — never invent rules
6. Do NOT flag issues already enforced by `clippy`, `rustfmt`, `eslint`, or `prettier`

### 6. Classify each finding

- **Must-fix**: Bug, missing error handling, or direct violation of a codified rule
- **Nit**: Improves consistency with the spirit of the guidelines but isn't explicitly codified

### 7. Deduplicate

If the same violation occurs multiple times in a file, report it once listing all line references.

### 8. Output

#### Review mode (default)

Present a structured report grouped by file:

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

#### Fix mode (`/review fix`)

1. Apply all must-fix and nit style corrections to the files
2. Stage and commit:
   ```bash
   git add -A && git commit -m "style: apply review fixes"
   ```
3. Present a recap using the same grouped format, describing each item as a completed fix

---
