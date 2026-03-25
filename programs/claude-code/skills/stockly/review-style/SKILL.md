---
name: review-style
description: Stockly-specific review-style overlay. Extends the global review-style skill with Stockly guideline mappings and additional Rust conventions. Always used alongside the global review-style workflow.
---

# Stockly Review Style Overlay

This skill extends the global `review-style` workflow. Follow the global workflow engine, with these additions.

## Guideline file mapping

In step 3 of the global workflow, use this explicit table to select guideline files:

| Changed file pattern | Guideline file to read |
|---|---|
| Any `*.rs` | `~/.claude/rules/stockly/rust-code-guidelines.md` |
| `*.rs` under a `grpc/` or `proto/` path | Also `~/.claude/rules/stockly/rpc-code-guidelines.md` |
| `*.rs` under an `http/` path | Also `~/.claude/rules/stockly/http-api-code-guidelines.md` |
| Any `*.proto` | `~/.claude/rules/stockly/rpc-code-guidelines.md` |
| Diesel/SQL-related changes | `~/.claude/rules/stockly/diesel-schema.md` |

## Additional file filters

In step 2, also skip: proto-generated `*.rs` files in `protobuf_gen/` directories, `schema.rs`.

## Additional Stockly Rust style checks

Beyond the global conventions, also check:

- **Import ordering**: 4 sections separated by blank lines: (1) sub-modules, (2) relative (`super::`), (3) crate (`crate::`), (4) external (including other Stockly crates). Also applies to re-exports (`pub use`).
- **Wildcard import for `internal_error`**: Always `use internal_error::*;` — never import specific items individually.
- **Prefer `try_or_wrap!`** over `let ... else { return Ok(Err(...)) }` for extracting values with Fail returns.
- **Prefer `sort_helpers::Sorted`** trait over `sort`/`sort_unstable` on mutable variables.
