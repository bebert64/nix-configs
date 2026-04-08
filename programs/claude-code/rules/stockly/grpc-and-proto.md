---
paths:
  - "**/grpc/**/*.rs"
  - "**/protos/**/*.rs"
  - "**/proto/**/*.rs"
  - "**/*.proto"
  - "**/additionals/**/*.rs"
---

# gRPC & Proto Guidelines

## Proto file conventions

### Never use `..Default::default()` with proto structs

Always list every field explicitly when building or destructuring protobuf-generated structs. Never use `..Default::default()` (nor `..` when destructuring). This ensures new fields force every construction site to handle them.

```rust
// BAD
operations_proto_backoffice::CancellationDecisionWrapperForOpt {
	value: entry.map(operations_proto_basics::CancellationDecision::from).into(),
	..Default::default()
}

// GOOD
operations_proto_backoffice::CancellationDecisionWrapperForOpt {
	value: entry.map(operations_proto_basics::CancellationDecision::from).into(),
	unknown_fields: Default::default(),
	cached_size: Default::default(),
}
```

### Use PascalCase for protobuf enum values

Do not use SCREAMING_SNAKE_CASE.

```protobuf
// BAD
enum MyStatus {
	NOT_STARTED = 0;
	IN_PROGRESS = 1;
}

// GOOD
enum MyStatus {
	NotStarted = 0;
	InProgress = 1;
}
```

### Proto files may be symlinked

Proto files are symlinked into services that call them. Always edit the original source file (usually in the service that implements the RPC), not the symlink.

## Architecture

### Three-layer pattern and thin handlers

1. **Raw proto structs** (auto-generated in `protobuf_gen/`)
2. **Clean structs/enums in additionals** (with `From`/`Into` to raw proto)
3. **Applicative/service structs** (in service layer, convert to clean types)

RPC handler functions (files under `grpc/`) must contain no business logic. Their responsibility is strictly: validate and convert inputs, delegate to business logic, convert outputs. Any non-trivial logic belongs in domain/entity modules.

### Additionals pattern

- `additionals/structs.rs`: Clean business-logic Rust structs WITH their `From`/`TryFrom`/`validated()` conversions defined next to each struct.
- `additionals/mod.rs`: Re-exports.

**`.validated()` method**: A convenience method on proto types wrapping `TryFrom` — never duplicate validation logic:
```rust
impl proto::MyRequest {
    pub fn validated(&self) -> Result<MyRequest, DynFieldInvalidity<'static>> {
        self.try_into()
    }
}
```

In RPC handlers, use `req.validated()` instead of `(&*req).try_into().on_field("request")`.

### Model IDs

- Model ID definition crates (like `supply_messages_core`) are lightweight — always safe to depend on.
- Heavier features (Diesel integration with schema) are gated behind feature flags.
- Proto crates CAN depend on ID core crates without issues.
- Use proper model ID types instead of raw `i32` values.
- **When a core crate isn't lightweight** (like `operations_core` which pulls schema/diesel): define local `model_id!()` types in proto additionals with the same names, then convert via `.value` in the service layer (e.g., `operations_core::PurchaseId::assume_exists(proto_purchase_id.value)`).

### PreValidated vs Validated semantics

- `PreValidated<T>`: Format is valid (e.g., positive i32), but NOT verified to exist in DB.
- Raw `T` (ModelId): Confirmed to exist in the database.
- In RPC requests: Always use `PreValidated` — input comes from external caller, format checked, DB existence NOT verified.
- After DB validation: Can use raw `T` — use `.assume_exists()` only after DB confirms existence.
- **Loading from DB validates the ID**: If you load an entity from DB (e.g., `supplier`), use its fields for validated IDs (e.g., `supplier.id`) instead of re-constructing via `assume_exists(pre_validated.value)`.
- This applies to core services (Stockly entities). For non-Stockly entities (partner/external), it's mainly for strong typing.

## RPC design

### Input/output principles

- **Input**: the caller must send the precise information they have. Never let the RPC depend on server state that might have changed between the caller's read and the call.
- **Output**: don't send back info the caller already sent (they have it). Don't send unrelated info. Do send proof that the requested action was performed.
- **Noop rejection**: calls that are noops given the arguments (e.g., empty batch) must be rejected with `INVALID_ARGUMENT` to prevent unnecessary network calls. This differs from in-app functions, which should early-return success for noops. Idempotent calls that are effectively noops with proper arguments (e.g., setting value V when already V) should NOT error.

### Error handling in RPCs

- **`From<Fail> for RpcStatus`**: implement this conversion to enable `try_or_wrap!` in the RPC's `perform` function for legitimate caller-side failures (e.g., entity not found after pre-validation passed).
- **gRPC metadata limit**: hard limit of 16384 bytes for status code + error message through gRPC metadata channels.

### Register new RPCs in the policies macro

When adding a new RPC, it must be registered in `Service/src/auths.rs` inside the `policies!` macro so that users have the permission to call it.
