# Cursor Rules Consolidation Plan

## Problem

When working on Rust files in the Stockly workspace, ~1120 lines of rules load from 3 sources.
Of those, ~240 lines are duplicated (same rules worded slightly differently across sources).
This wastes context budget and creates contradictions that the agent must reconcile.

## Sources

| # | Path | Editable | Loaded in |
|---|------|----------|-----------|
| A | `~/Stockly/Main/.cursor/rules/` + `AGENTS.md` | NO (work repo) | Stockly workspace |
| B | `~/nix-configs/programs/cursor/stockly/rules/` | YES | Stockly workspace |
| C | `~/nix-configs/programs/cursor/rules/` | YES | All workspaces (global `~/.cursor/rules/`) |
| D | Personal repo `.cursor/rules/` | YES | Personal repo workspace only |

## Strategy

1. B overlaps A: remove from B (both Stockly-specific; A is canonical, immutable)
2. C overlaps A: remove from C, add to D (personal repo still needs the rules; Stockly gets them from A)

---

## Part 1: Deduplicate nix-configs/stockly/rules/ against the work repo

Only one file has meaningful overlap with Main/.cursor/rules/.

### 1.1 stockly-proto.mdc: remove "Request handling" sub-section

Remove the `### Request handling` heading and its two bullets from the `## RPC design` section:

```
### Request handling

- **Destructure the `req` argument** in RPC handlers unless it is passed directly
  to a validation function or is a simple id/`Empty`. For long type names, rename
  in imports (e.g., `use SendManualMessageRequest as Request`).
- **Avoid `allow(unused)` for Fail variant fields**: when Fail variants have fields
  used only in Debug, don't suppress the warning. Instead, use the fields explicitly
  when converting to `RpcStatus`.
```

Why: First bullet is identical to rpc-code-guidelines.mdc "Destructure req in RPCs".
Second bullet is identical to rust-code-guidelines.mdc "Avoid #[allow(unused)] on Fail Fields".

### No other changes in stockly/rules/

The remaining 4 files (stockly-coding, stockly-database, stockly-pr, stockly-tooling)
have no meaningful overlap with the repo rules.

---

## Part 2: Deduplicate nix-configs/rules/ against the work repo

Three files need changes: rust-patterns.mdc, fail-vs-error.mdc, ai-behavior.mdc.

### 2.1 rust-patterns.mdc: remove 6 sections entirely, trim 5 others

This file (140 lines) is the largest source of duplication. rust-code-guidelines.mdc
in the repo (284 lines) is essentially a superset of many of its sections.

#### Sections to REMOVE entirely

A. "Inline single-use variables" (currently lines 24-36)
Entire section from `## Inline single-use variables` through the `Exception:` line.
Covered by: rust-code-guidelines.mdc "Inline Single-Use Variables".

B. "Prefer match over if let else" (currently lines 38-55)
Entire section from `## Prefer` through the closing code block.
Covered by: rust-code-guidelines.mdc "Prefer match Over if let ... else".

C. "Module organization" (currently lines 71-74)
Entire section: heading and 3 bullets.
Covered by: rust-code-guidelines.mdc "Module Declaration".

D. "Visibility" (currently lines 76-84)
Entire section from heading through `Avoid pub(super)...`.
Covered by: rust-code-guidelines.mdc "Visibility and Privacy".

E. "Items ordering" (currently lines 86-104)
Entire section from heading through the Bad code block.
Covered by: rust-code-guidelines.mdc "Items Ordering" (superset, adds file-level structure).

F. "Serde" (currently lines 110-115)
Entire section: heading and 3 bullets.
Covered by: rust-code-guidelines.mdc "Serde: Prefer Enums..." and "Serde: Prefer Vec...".

#### Sections to TRIM (remove only the duplicated lines)

G. "Imports": remove the 4-group ordering description. Keep ONLY these unique bullets:
- `Imports must be grouped using use { ... } syntax.`
- `Visibility (pub) doesn't affect grouping...`
- `Never use more than one super::...`
- `Use wildcard import for don_error...`

Lines to remove from this section:
```
- Import groups must be separated by exactly one empty line.
- Groups are sorted in this order (each separated by one empty line):
  1. Sub-modules (`self::`)
  2. Relative modules (`super::`, `crate::`)
  3. Crate modules
  4. External libraries (including other project libraries)
```
Covered by: rust-code-guidelines.mdc "Import Ordering".

H. "Destructuring": remove the `..` ban line only. Keep the rest (default-to-destructure
philosophy, binary operators guidance, proto TryFrom note).

Line to remove:
```
- **Never use `..`** -- it defeats compile-time safety. Instead: `field: _, // why not relevant here`
```
Covered by: rust-code-guidelines.mdc "Destructure Structs Without ..".

I. "Compilation and testing": remove 3 of 4 bullets. Keep ONLY
`Always suggest unit tests for important and non-trivial logic...` which is NOT in the repo.

Lines to remove:
```
- Always use `--quiet` with cargo commands...
- Always use `cargo check` instead of `cargo build`...
- Run `cargo machete` after modifying Rust code...
```
Covered by: environment-setup.mdc and rust-development.mdc.

J. "Database": remove the schema.rs bullet. Keep the other 3 bullets
(up.sql only, Diesel full paths, join cardinality) which are NOT in the repo.

Line to remove:
```
- **Always read `src/schema.rs` before writing or modifying queries**...
```
Covered by: diesel-schema.mdc.

K. "Project tooling": remove the direnv bullet. Keep the other 2 bullets
(worktree care, scratch directory) which are NOT in the repo.

Line to remove:
```
- When entering a project with `.envrc`, **try the command directly first**...
```
Covered by: environment-setup.mdc.

#### Expected result

rust-patterns.mdc goes from ~140 lines to ~55 lines. All remaining content is unique.

---

### 2.2 fail-vs-error.mdc: trim to unique content only

The core Fail vs Error concept is fully covered by rust-code-guidelines.mdc
"Error vs Fail: Two-Level Result Pattern", "Fails MUST be matched exhaustively",
and "Exception for wrapping Fails".

Keep only these unique parts:

1. `Result<T, Fail> without an outer error Result is rare and reserved for thin wrappers around the Fail itself.`
2. The try_or_wrap! macro section (the repo mentions the macro name but does not explain it)

Remove everything else: the intro paragraph, the key rules about Result<Result<T, Fail>, Error>,
the `must not be convertible via ?` rule, the `Do not implement std::error::Error` rule,
and the wrapping exception section with code example.

The resulting file should be approximately:

```
---
description: Conventions for Fail enums vs error types
globs: "**/*.rs"
alwaysApply: false
---

# Fail vs Error: Addenda

`Result<T, Fail>` without an outer error Result is rare and reserved for thin wrappers
around the `Fail` itself.

## try_or_wrap! macro

Helper for working with `Result<Result<T, Fail>, Error>`:
- Unwraps the outer `Ok` and returns early on inner `Err` wrapped in `Ok`.
- Pattern: `match x { Ok(v) => v, Err(e) => return Ok(Err(e)) }` -> `try_or_wrap!(x)`
```

#### Expected result

fail-vs-error.mdc goes from ~38 lines to ~16 lines.

---

### 2.3 ai-behavior.mdc: remove 2 sub-sections

Remove "Before implementing" section (currently lines 14-17):

```
## Before implementing

- **Read similar/relevant code first** -- before implementing any change, identify
  existing patterns or similar code in the codebase and read them.
- **Recap current behavior** -- before making a change, explicitly state the current
  behavior. This catches misunderstandings early.
```

Covered by: agent-workflow.mdc "Before Implementing a Task" (steps 1-2).

Remove "Task delegation" section (currently lines 33-38):

```
## Task delegation

- **Break plans into subagent-delegable blocks**: Decompose work into independent units...
- Launch independent subagents concurrently (up to 4 at a time)...
- Only keep sequential what truly depends on prior steps' output...
- Each delegated block should have a clear, self-contained description...
```

Covered by: agent-workflow.mdc "Task Planning & Delegation" (nearly identical text).

#### Expected result

ai-behavior.mdc goes from ~44 lines to ~30 lines.

---

## Part 3: Add removed content to personal repo

All content removed from nix-configs/rules/ (Part 2) must be re-created in the personal
repo's .cursor/rules/ so it is still available when working there.

Use the nix-configs version of each rule (not the Stockly repo version).

Read all source files BEFORE making any edits so you have the content to copy.

### 3.1 Create personal-repo/.cursor/rules/rust-conventions.mdc

Frontmatter:
```
---
description: Rust coding conventions
globs: "**/*.rs"
alwaysApply: false
---
```

Include the following sections, copied verbatim from the CURRENT (pre-edit)
nix-configs/rules/rust-patterns.mdc:

| Section to copy | Source reference |
|-----------------|-----------------|
| Inline single-use variables | Removed in 2.1.A |
| Prefer match over if let else | Removed in 2.1.B |
| Import ordering (the 4-group system) | Removed in 2.1.G |
| Never use `..` in destructuring | Removed in 2.1.H |
| Module organization | Removed in 2.1.C |
| Visibility | Removed in 2.1.D |
| Items ordering | Removed in 2.1.E |
| Serde patterns | Removed in 2.1.F |
| Compilation: --quiet, cargo check, cargo machete | Removed in 2.1.I |
| Database: read schema.rs before queries | Removed in 2.1.J |
| Direnv: try command first, only run direnv on failure | Removed in 2.1.K |

### 3.2 Create personal-repo/.cursor/rules/fail-vs-error.mdc

Frontmatter:
```
---
description: Fail vs Error pattern
globs: "**/*.rs"
alwaysApply: false
---
```

Include the content removed from nix-configs/rules/fail-vs-error.mdc in Part 2.2:
- Intro paragraph defining Fail (expected failures) vs Error (unexpected bugs)
- Key rules about `Result<Result<T, Fail>, Error>` signature
- Fail must not be convertible to outer error type via ?
- Do not implement std::error::Error on Fail types
- Wrapping exception: derive_more::From + try_or_wrap! code example

### 3.3 Create personal-repo/.cursor/rules/agent-workflow.mdc

Frontmatter:
```
---
description: Agent workflow guidelines
alwaysApply: true
---
```

Include the content removed from nix-configs/rules/ai-behavior.mdc in Part 2.3:
- "Before implementing" section (read similar code, recap current behavior)
- "Task delegation" section (subagent blocks, concurrency, self-contained descriptions)

---

## Remaining minor overlaps (intentionally not addressed)

These overlaps exist but are NOT worth fixing. Surgical removal would make the
remaining rules incoherent or lose unique surrounding context:

| In nix-configs/rules/ | Overlaps with repo rule | Why kept |
|------------------------|------------------------|----------|
| coding-preferences.mdc naming: no test_ prefix, no get prefix, redundant prefixes | rust-code-guidelines.mdc Naming | 3 lines within a 30-line section with unique context (4-step naming method, encode type info, etc.) |
| coding-principles.mdc "impossible situations" | rust-code-guidelines.mdc serde section | Different framing: general design principle vs serde-specific rule |

---

## Expected savings

| Metric | Before | After |
|--------|--------|-------|
| rust-patterns.mdc | 140 lines | ~55 lines |
| fail-vs-error.mdc | 38 lines | ~16 lines |
| ai-behavior.mdc | 44 lines | ~30 lines |
| stockly-proto.mdc | 73 lines | ~67 lines |
| Total (Rust context) | ~1120 lines | ~990 lines |
| Duplicated lines | ~240 | ~20 |

The line savings (~130) are modest, but the real win is near-elimination of duplication
(~240 to ~20 lines). The agent no longer wastes attention reconciling two phrasings of
the same rule.

---

## Execution order

1. Read all nix-configs rule files first: Part 3 needs content from their pre-edit state.
2. Execute Part 3: create files in the personal repo.
3. Execute Part 2: edit nix-configs/rules/ files.
4. Execute Part 1: edit nix-configs/stockly/rules/ files.
5. Verify: confirm no section was removed without being added to the personal repo.
