# Error Handling: Error vs Fail

The user uses a **two-level Result** pattern to distinguish infrastructure errors from business failures.

## The Pattern

```rust
pub(crate) fn perform(input: Input) -> ErrorResult<Result<Success, Fail>> { ... }
```

- **Outer `ErrorResult<...>`** — `Err` = infrastructure/unexpected error = the function has unexpected behavior or fails to uphold its guarantees. The code must be fixed.
- **Inner `Result<T, Fail>`** — `Err` = `Fail` = expected rejection (invalid inputs, business rule violations, entity not found, etc.)

The term **`Error`** is strictly reserved for bugs/infrastructure. For all expected rejection cases, the type is named **`Fail`**, never `Error`.

## The Error crate — `InternalError` vs `DonError`

Two crates implement this pattern with identical semantics and near-identical API. Use whichever is available in the repo you're working in:

| | Stockly monorepo | Personal repos |
|---|---|---|
| **Crate** | `lib/rust/InternalError` | `don_error` |
| **Error type** | `InternalError` | `DonError` |
| **Result alias** | `InternalResult<T>` | `DonResult<T>` |

Both wrap `anyhow::Error` with structured JSON context. `don_error` is a simplified subset — the same concepts apply, but with a smaller API surface.

```rust
// Stockly
pub type InternalResult<T> = Result<T, InternalError>;

// Personal repos
pub type DonResult<T> = Result<T, DonError>;
```

Created via `err_msg("...")`, `err_ctx!({ field })`, or the `?` operator on functions returning the matching result type.

## `Fail` (the business side)

Each function defines its own `Fail` enum with domain-specific variants:

```rust
#[derive(Debug)]
pub(crate) enum Fail {
    OrderLineFromOtherOrders(Vec<OrderId>),
    InvalidOrderLineIds(FieldInvalidity<MissingInDatabase<OrderLineId>>),
    DemanderBlocked(Vec<DemanderId>),
}
```

Variants carry structured data explaining what went wrong. Common patterns:

- `MissingInDatabase<T>` — entity ID not found after validation
- `FieldInvalidity<T>` — input field validation failure
- Struct variants with multiple fields for complex business conditions
- Newtype variants wrapping nested `Fail` types

## `try_or_wrap!` macro

Bridges the two levels. Unwraps an inner `Ok`, returns early on inner `Err` wrapped in outer `Ok`:

```rust
// Expands to: match expr { Ok(v) => v, Err(e) => return Ok(Err(e.into())) }
let order_lines = try_or_wrap!(
    OrderLineId::validated_prevalidated_with_db_batch(&input.order_lines_ids, db)?
        .on_field("order_lines_ids")
);
```

The `?` handles the outer result (`InternalResult` / `DonResult`), `try_or_wrap!` handles the inner `Result<_, Fail>`.

## Exhaustive Fail Matching

Always match every `Fail` variant explicitly. Never use catch-all `_`:

```rust
impl From<Fail> for RpcStatus {
    fn from(err: Fail) -> Self {
        match err {
            Fail::PurchaseNotFound(missing_id) => missing_id.into(),
            Fail::NoParcelItemOnPurchases(purchase_ids) => RpcStatus::with_message(
                RpcStatusCode::FAILED_PRECONDITION,
                format!("Purchases {purchase_ids:?} have no parcel item"),
            ),
            Fail::UnboundPurchases(purchase_ids) => RpcStatus::with_message(
                RpcStatusCode::FAILED_PRECONDITION,
                format!("Purchases {purchase_ids:?} are unbound"),
            ),
            // ... every variant listed
        }
    }
}
```

## Wrapping Fails with `derive_more::From`

When a function calls another that returns `Fail`, and every new fail case of the callee would also be a fail of the caller, you can wrap unconditionally:

```rust
#[derive(derive_more::From)]
pub(crate) enum Fail {
    #[from]
    PurchaseNotFound(MissingInDatabase<PurchaseId>),
    NoParcelItemOnPurchases(Vec<PurchaseId>),
    #[from]
    RegisterStocklyCancellationFail(RegisterStocklyCancellationFail),
}
```

`#[from]` generates `From<Inner>` for that variant, enabling `try_or_wrap!` to convert automatically.

## RPC Layer (Stockly only)

In gRPC handlers, the signature is typically:

```rust
pub(crate) fn perform(
    ctx: &RpcContext,
    req: &SomeRequest,
) -> InternalResult<RpcResult<SomeRecap>> { ... }
```

`RpcResult` is an alias for `Result<T, RpcStatus>`. The `From<Fail> for RpcStatus` impl converts business failures to gRPC status codes.
