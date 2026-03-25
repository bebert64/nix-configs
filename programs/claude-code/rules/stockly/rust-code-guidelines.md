---
paths:
  - "**/*.rs"
---

# Rust Code Guidelines (Correctness)

## Dependency Re-exports

Do NOT import shared crates directly when they are already re-exported by a higher-level helper crate. Use the re-export path instead to keep the dependency graph shallow and avoid feature duplication. Helper crates are usually under /lib/rust/{Crate}Helpers and named {crate}_helpers.

Special cases:

- `diesel` must remain in `Cargo.toml` **without explicit features** (`diesel.workspace = true`) because diesel's proc-macro expansions reference `::diesel::` absolute paths. All feature flags (chrono, uuid, etc.) must be activated through `diesel_helpers` features (`with_chrono`, `with_uuid`, etc.).
- In grpc server, access the validation crate through grpc_helpers_server.

## Ids Must Use `model_id` Types

Never manipulate Ids as raw `i32`. Always use the typed wrapper from `model_id` (e.g., `OrderLineId`, `PurchaseId`). This includes `EntityId`s, typically stored in `{action}_by` columns (e.g., `created_by`, `invalidated_by`). The only exception is proto-generated structs, which use `i32` at the serialization boundary. Convert to/from `model_id` types as early/late as possible.

A bare `ModelId` (e.g., `OrderLineId`) means the Id is **trusted** -- use it only when:

- The Id has been validated against the database, or
- The Id is defined by the service itself (e.g., `ShipmentsParcelId` sent by the shipments service).

When the Id comes from an external source and has NOT been validated, wrap it in `PreValidated<ModelId>` (e.g., `PreValidated<OrderLineId>`).

## Use Typed Wrappers Instead of Raw Strings for Domain Values

Never pass around domain values as raw `String` or `&str` when a typed wrapper exists. Use the structured type from the appropriate crate (e.g., `countries::Language`, `countries::Alpha3`, `countries::Currency`). Parse raw strings into the typed wrapper at the serialization boundary and propagate the typed value through the rest of the code.

## Visibility and Privacy

Apply visibility in this priority order:

1. **Private** (default) -- leave everything private unless you need otherwise.
2. **`pub(crate)`** -- when you need access outside the module without re-exporting.
3. **`pub`** -- only when the item is part of the crate's public API. Avoid `pub` otherwise because it suppresses `unused` warnings.

**Avoid** `pub(super)` and `pub(in path)` -- they increase refactoring cost.

## Error vs Fail: Two-Level Result Pattern

Use two levels of `Result` to distinguish infrastructure errors from business failures:

- **Outer** `InternalResult<...>` -- `Err` = `Error` = the function has unexpected behavior or fails to uphold its guarantees (its code must be changed).
- **Inner** `Result<T, Fail>` -- `Err` = `Fail` = expected rejection (invalid inputs, business rule violations, etc.).

The term `Error` is strictly reserved for when the service/function is at fault. For all expected rejection cases, name the type `Fail`, never `Error`.

### `Result<T, Fail>` without an outer error Result

This is rare and reserved for thin wrappers around the `Fail` itself.

### `try_or_wrap!` macro

Helper for working with `Result<Result<T, Fail>, Error>`:
- Unwraps the outer `Ok` and returns early on inner `Err` wrapped in `Ok`.
- Pattern: `match x { Ok(v) => v, Err(e) => return Ok(Err(e)) }` becomes `try_or_wrap!(x)`

### Fails MUST be matched exhaustively

Always match every `Fail` variant explicitly. Do NOT use catch-all (`_`) patterns. This ensures new variants are handled at every call site.

### Exception for wrapping Fails

You may wrap a `Fail` unconditionally into another `Fail` (without matching each variant) **if and only if** every new fail case of the called function would always also be a fail of the current function. Use `#[derive(derive_more::From)]` or the `try_or_wrap!` macro for this.

## Destructure Structs Without `..`

By default, destructure structs without the `..` rest pattern, especially in function arguments. This forces handling or acknowledging every field when the struct is updated. Skip destructuring only if you would need to rename a significant number of fields for clarity or conflict.

## Avoid `#[allow(unused)]` on Fail Fields

When Fail variant fields are only used in the Debug implementation, do NOT suppress the unused warning with `#[allow(unused)]`. Instead, use the fields explicitly when converting the Fail to an RPC status -- this produces better error messages and ensures the data is relevant.
