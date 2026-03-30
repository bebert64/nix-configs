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

## Rust Code Guidelines

- **Visibility**: apply in order: private (default) → `pub(crate)` → `pub`. Avoid `pub(super)` and `pub(in path)`.
- **Destructure structs without `..`**: especially in function arguments, to force handling every field when the struct changes. Exception: when renaming many fields would be more confusing.
- **Avoid `#[allow(unused)]` on Fail fields**: use fields explicitly when converting to RPC status — produces better error messages.

## Proto Guidelines

- **Naming convention**: Clean additionals structs use the "default" names (e.g., `RenderAndSendMessageRequest`). Proto types are the "dirty" ones and should be aliased if needed (e.g., `ProtoRenderAndSendMessageRequest`).
- **Proto generation**: To regenerate proto Rust code after modifying a `.proto` file, run `cargo check` in the service where the protos are defined — `build.rs` handles regeneration automatically.
- **Recap struct**: when an RPC returns complex results, create a named `Recap` struct with properly named fields in the application code, then convert it to the corresponding proto `Recap` in the RPC layer.

## RPC Code Guidelines

- **Destructure `req` in RPC handlers**: Destructure the `req` argument directly, unless it is passed as-is to a validation function or is a simple id / `Empty`. If the request type name is longer than 20 characters, rename it in imports: `use proto::SendManualMessageRequest as Request;`
- **Define proto messages in order of first appearance**: Messages and enums in `.proto` files must be defined in the order they first appear (as a field type, request, or response).
- **Deref `ctx.caller.id`**: Use `*ctx.caller.id` to get a `PreValidated<EntityId>`, not `EntityId::pre_validated(ctx.caller.id.value)`.
- **Use `SingularPtrFieldExt` for optional proto fields**: Use helpers like `as_ref_or_missing()`, `ok_or_missing()`, `try_from_ref()` (from `grpc_helpers_core`) with `.on_field(...)` instead of manually matching and returning `RpcStatus`.
- **Use `Into<RpcStatus>` for `MissingInDatabase<Id>`**: Call `.into()` on the value instead of manually constructing an `RpcStatus`.

## HTTP API Code Guidelines

- **Destructure `Json`/`Query` handler inputs**: In HTTP handler functions, destructure `Json(...)` or `Query(...)` directly in the argument pattern (e.g. `Json(MyInput { field_a, field_b }): &Json<MyInput>`), unless the value is passed as-is to another function or contains a single field.

## Stockly Coding

- **`intl!` message wording**: Sentry aggregates events by title — variable parts (IDs, counts, etc.) break aggregation. Put variable details in parentheses, which are excluded from aggregation. E.g. `"Email has too many attachments ({count}, limit is {max})"` aggregates on "Email has too many attachments" while keeping details visible.
