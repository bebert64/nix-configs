---
description: Review all changes on the current branch — correctness, bugs, and style. Use when the user asks for a code review or /review. With "auto" argument, applies fixes automatically until done.
---

# Review

Review ALL changes introduced by the current branch (not just uncommitted changes).

## Modes

- `/review` — user-controlled: correctness + style, report only, user drives rounds
- `/review auto` — autonomous: correctness + style, applies fixes automatically, runs until done
- `/review once` — single pass: one round only, applies all findings automatically

## Rule themes

Rule files live in `${CLAUDE_SKILL_DIR}/rules/`. They are grouped into themes. Each theme is reviewed by a dedicated sub-agent so that rule attention is never diluted.

| Theme | Rule files |
|---|---|
| **Rust style** | `rust-style-and-conventions.md`, `naming.md`, `comments.md`, `imports.md` |
| **Data layer** | `diesel.md`, `sql.md` |
| **API / protocol** | `rpc_and_proto.md`, `http.md`, `serde.md` |
| **Project infra** | `stockly-specifics.md`, `cargo.toml.md` |
| **Correctness** | *(no rule files — bugs, missing error handling, performance, TODO/FIXME)* |


## Workflow

### 1. Gather the diffs

**If a commit reference was passed as an argument** (e.g. `/review once abc1234` or `/review once abc1234..def5678`):

```bash
git show <ref>              # single commit
# or
git diff <range>            # explicit range like abc1234..def5678
```

Use only that diff — do not include unstaged/staged changes or the full branch diff.

**Otherwise** (no argument — reviewing the full branch):

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

### 3. Load codebase context

Check if `git remote get-url origin` points to a known codebase and read `${CLAUDE_SKILL_DIR}/<codebase>.md` if it exists — it may add file filters, a guideline table, and additional checks.

### 4. Compute file batches

Group the filtered files into batches so that each batch contains at most **~700 changed lines** (additions + deletions combined). Small PRs will produce a single batch; large PRs will produce several.

### 5. Launch sub-agents

For each combination of **(batch × theme)**, launch a sub-agent via the Task tool. Run up to 4 sub-agents concurrently.

Each sub-agent receives:
- The diff for its file batch (full file content + diff hunks for context)
- The rule files for its theme (read from `${CLAUDE_SKILL_DIR}/rules/`)
- The mode (`review` or `auto`)
- This instruction set:

> **You are a focused code reviewer. Your only job is to find violations of the rules listed below.**
>
> - Read the full content of each changed file for context
> - Every finding **must** reference the specific rule it violates — never invent rules
> - Do NOT flag issues enforced by `clippy`, `rustfmt`, `eslint`, or `prettier`
> - Classify each finding as **Must-fix** (direct rule violation or bug) or **Nit** (spirit of guidelines, not explicitly codified)
> - If the same violation appears multiple times in a file, report it once with all line references
>
> **Diff scope:**
> - Lines **in the diff** (changed/added by this branch): flag and mark as `FIXABLE: yes`
> - Lines **outside the diff** (unchanged, from a previous PR): you may still flag if you are confident there is a real issue — but mark as `FIXABLE: no`. These are surfaced for the user's awareness but must never be auto-fixed, as they carry a higher risk of false positives.
>
> - Return findings in this exact format:
>
> ```
> FILE: path/to/file.rs
> SEVERITY: Must-fix | Nit
> FIXABLE: yes | no
> RULE: <rule name>
> LINES: 42, 78
> CURRENT:
> <code block>
> SUGGESTED:
> <code block>
> REASON: <one-line explanation>
> ---
> ```
>
> Return an empty response if you find nothing.

### 6. Aggregate findings

Once all sub-agents finish:

1. Collect all findings across batches and themes
2. Deduplicate: if two agents flagged the same file + line range for the same reason, keep one
3. Group by file, then by severity
4. Preserve the `FIXABLE` flag on each finding — workflow files use it to decide what gets auto-fixed

### 7. Hand off to workflow

Pass aggregated findings to the active workflow — see `workflow/user-controlled.md` or `workflow/autonomous.md`.
