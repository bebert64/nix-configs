---
description: Stockly gRPC proto design patterns — three-layer architecture, TryFrom conversions, PreValidated IDs, RPC input/output principles. Use when designing, implementing, or reviewing proto types and RPC handlers in the Stockly monorepo.
---

# Proto Design Patterns

How Stockly structures gRPC services and the conversion between proto and Rust types.

## Three-Layer Pattern

1. **Raw proto structs** — auto-generated in `protobuf_gen/` by `build.rs`. Never edited by hand.
2. **Clean structs in `additionals/`** — hand-written Rust types with `TryFrom`/`From` conversions to raw proto. Live in `<proto_crate>/src/additionals/`.
3. **Service/application structs** — business logic types in the service layer that use clean types from layer 2.

### Naming convention

Clean structs use the "default" names (e.g., `RenderAndSendMessageRequest`). Proto types are the "dirty" ones and get aliased with a `Proto` prefix when disambiguation is needed (e.g., `ProtoRenderAndSendMessageRequest`).

## `additionals/` Module Layout

Each proto crate has:
```
<proto_crate>/src/
├── additionals/
│   ├── mod.rs           # Re-exports
│   └── structs.rs       # Clean types + From/TryFrom conversions
├── protobuf_gen/        # Auto-generated (do not edit)
└── lib.rs
```

## `.validated()` Method

Every proto type that needs conversion gets a convenience method:

```rust
impl proto::DemanderTakeConfig {
    pub fn validated(&self) -> Result<DemanderTakeConfig, DynFieldInvalidity<'static>> {
        self.try_into()
    }
}
```

This is always a thin wrapper over `TryFrom` — never duplicate validation logic. In handlers, call `req.validated()` instead of `(&*req).try_into().on_field("request")`.

## `TryFrom` Conversion Pattern

Destructure all proto fields explicitly (no `..`), convert each field, collect validation errors:

```rust
impl TryFrom<&proto::DemanderTakeConfig> for DemanderTakeConfig {
    type Error = DynFieldInvalidity<'static>;

    fn try_from(proto: &proto::DemanderTakeConfig) -> Result<Self, Self::Error> {
        let proto::DemanderTakeConfig {
            source,
            function,
            unknown_fields: _,
            cached_size: _,
        } = proto;

        Ok(DemanderTakeConfig {
            source: (*source).into(),
            function: function.try_from_ref().on_field("function")?,
        })
    }
}
```

Always destructure `unknown_fields: _` and `cached_size: _` from proto types.

## Validation crate API

A full reference of all public items in the `validation` crate is available at `~/.claude/docs/stockly/validation.md`. **Check there before exploring the source.**

## PreValidated vs Validated IDs

- `PreValidated<T>`: format is valid (e.g., positive i32), but NOT verified to exist in DB. Used in RPC request parsing.
- Raw `T` (e.g., `OrderLineId`): confirmed to exist in the database. Used after DB validation.
- `assume_exists()`: converts `PreValidated<T>` → `T` only after DB has confirmed existence.
- Loading from DB validates the ID: use `entity.id` directly instead of `assume_exists(pre_validated.value)`.

## RPC Design Principles

**Input:** the caller sends the precise information they have. Never let the RPC depend on server state that might have changed.

**Output:** don't echo back info the caller already sent. Don't send unrelated info. Do send proof the action was performed.

**Noop rejection:** RPCs that are noops given the arguments (e.g., empty batch) must be rejected with `INVALID_ARGUMENT`. Idempotent calls that are effectively noops (setting value V when already V) should NOT error.

**Recap structs:** when an RPC returns complex results, create a named `Recap` struct in application code, convert to proto in the RPC layer.

## Error Handling in RPCs

Implement `From<Fail> for RpcStatus` to enable `try_or_wrap!` in handlers:

```rust
impl From<Fail> for RpcStatus {
    fn from(fail: Fail) -> Self {
        match fail {
            Fail::AlreadyExists { id } => RpcStatus::with_message(
                RpcStatusCode::ALREADY_EXISTS,
                format!("Already exists: {id}"),
            ),
            // ... exhaustive matching
        }
    }
}
```

gRPC metadata limit: 16384 bytes for status code + error message.

## Proto Generation

To regenerate proto Rust code after modifying a `.proto` file, run `cargo check` in the service — `build.rs` handles regeneration automatically.

## Model IDs in Proto Crates

- Lightweight ID core crates (like `supply_messages_core`) can be depended on by proto crates.
- When a core crate is heavyweight (like `operations_core` which pulls schema/diesel), define local `model_id!()` types in proto additionals with the same names, then convert via `.value` in the service layer.
