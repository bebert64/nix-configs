---
name: review-style
description: Reviews changed code on the current branch for style guideline violations, assuming correctness. Default mode reports violations; with "fix" argument, applies corrections and commits them. Use when the user invokes /review-style or /review-style fix.
---

# Review Style

Review changed code on the current branch against style conventions and the project's rule files.
Assume the code works. Focus solely on style, naming, ordering, and patterns.

## Modes

- `/review-style` — report violations without making changes
- `/review-style fix` — apply all fixes, commit them, and present a recap

## Workflow

### 1. Gather the diffs

```bash
git diff origin/master...HEAD  # or origin/main...HEAD depending on the repo
git diff                        # unstaged
git diff --staged               # staged
```

If all empty, report "No changes to review" and stop.

### 2. Filter out non-reviewable files

Skip entirely:
- Generated files (e.g., proto-generated `*.rs`)
- Lock files: `Cargo.lock`, `pnpm-lock.yaml`
- Non-code: `*.md`, `*.json`, `*.yaml`, `*.yml`

### 3. Select applicable guidelines

Read rule files from `~/.claude/rules/` whose `paths:` frontmatter matches the changed file types. For example, if `*.rs` files changed, read rules with `paths: ["**/*.rs"]`.

If a project-specific review-style overlay skill exists, it may provide an explicit guideline table that supplements or overrides this automatic discovery.

### 4. Review each changed file

Use the Task tool to review up to 4 files concurrently. For each file:

1. Read the full file for context
2. Focus review **only on changed/added lines** — never flag unchanged code
3. Check against: (a) the built-in conventions below, (b) applicable rule files from step 3, (c) spelling and grammar
4. Every finding from rule files **must** reference the specific rule — never invent rules
5. Do NOT flag issues already enforced by `clippy`, `rustfmt`, `eslint`, or `prettier`

### 5. Classify each finding

- **Must-fix**: Directly violates a codified rule or built-in convention
- **Nit**: Improves consistency with the spirit of the guidelines but isn't explicitly codified

### 6. Deduplicate

If the same violation occurs multiple times in a file, report it once listing all line references.

### 7. Output

#### Review mode (default)

Present a structured report grouped by file:

```
## path/to/file.rs

### Must-fix

1. **[Guideline: <rule name>]** <brief description>
   Lines: 42, 78
   Current:
   <code block with violating code>
   Suggested:
   <code block with corrected code>

### Nit

1. **[Guideline: <rule name>]** <brief description>
   Line: 15
   Current / Suggested as above

---

## Summary

- X must-fix across Y files
- Z nits across W files
```

If no violations found, report "No style violations found."

#### Fix mode (`/review-style fix`)

1. Apply all must-fix and nit corrections to the files
2. Stage and commit:
   ```bash
   git add -A && git commit -m "style: apply review-style fixes"
   ```
3. Present a recap using the same grouped format, describing each item as a completed fix

---

## Built-in Conventions

These are always checked, regardless of which rule files are loaded. Read `conventions.md` in this skill directory for the full checklist.
