---
paths:
  - "**/*.rs"
---

## Destructuring

- **Destructuring should be the default** — always consider it first.
- Benefits: compiler forces handling new fields, clearer code, expresses intent.
- **Only opt out with a reason**: typically verbosity when fields aren't semantically related in the current context.
- Especially important for proto TryFrom/From impls — if a new field is added, compiler forces you to handle it.
- **For binary operators** (like `eq`, `cmp`, custom comparisons): destructuring `self` is enough — if a new field is added, compiler will force handling it. No need to destructure both sides.

## Exhaustive matching

- **Match exhaustively on enums by default**, especially on error/failure types.
- When ignoring errors, match each variant explicitly and comment why it's safe to ignore.
- Avoid `let _ = ...` or `Err(_)` wildcards — they hide what's being discarded.
- This ensures new variants added later force review of the handling logic.

## Imports

- **Never use more than one `super::`** (e.g., `super::super::...`). Use `crate::explicit::path` instead for anything beyond immediate parent.

## Safety

- **`unsafe` is banned** unless absolutely necessary. If needed, add `#[allow(unsafe_code)]` with a comment justifying why it is safe. Exception: `std::env::set_var` in tests.

## Compilation and testing

- Always suggest unit tests for important and non-trivial logic, even if it requires adjusting architecture slightly to make logic unit-testable.

## Database

- Diesel: always use full `schema::table_name::column` path. Never import tables into scope (no `use schema::table_name;` or `use schema::table_name::dsl::*;`). For `#[derive(Selectable)]`, explicitly specify `#[diesel(table_name = schema::table_name)]`.
- **Join cardinality**: when doing joins (inner or left), check the relationship cardinality. Non-1:1 joins produce duplicate rows that can corrupt aggregations — handle with `GROUP BY`, deduplication, or restructuring the query.

## Project tooling

- After creating worktrees, be careful not to commit ported untracked files (hardlinks/symlinks from the main worktree).
- Place generated/temp files (scripts, intermediate outputs) in `.claude/scratch/`. This directory should be gitignored.
