# Stockly — review overlay

## Guideline file mapping

| Changed file pattern | Guideline file to read |
|---|---|
| Any `*.rs` | `~/.claude/rules/stockly/rust-code-guidelines.md` |
| `*.rs` under `grpc/` or `proto/` | Also `~/.claude/rules/stockly/rpc-code-guidelines.md` |
| `*.rs` under `http/` | Also `~/.claude/rules/stockly/http-api-code-guidelines.md` |
| Any `*.proto` | `~/.claude/rules/stockly/rpc-code-guidelines.md` |
| Diesel/SQL-related changes | `~/.claude/rules/stockly/diesel-schema.md` |

## Additional file filters

In step 2, also skip: proto-generated `*.rs` files in `protobuf_gen/` directories, `schema.rs`.

## Additional Stockly Rust style checks

- **Import ordering**: 4 sections separated by blank lines: (1) sub-modules, (2) relative (`super::`), (3) crate (`crate::`), (4) external (including other Stockly crates). Also applies to re-exports (`pub use`).
- **Wildcard import for `internal_error`**: Always `use internal_error::*;` — never import specific items individually.
- **Prefer `try_or_wrap!`** over `let ... else { return Ok(Err(...)) }` for extracting values with Fail returns.
- **Prefer `sort_helpers::Sorted`** trait over `sort`/`sort_unstable` on mutable variables.
