---
paths:
  - "**/grpc/**/*.rs"
  - "**/protos/**/*.rs"
  - "**/proto/**/*.rs"
  - "**/*.proto"
---

# RPC Code Guidelines

## Never Use `..Default::default()` with Proto Structs

When building or destructuring protobuf-generated structs, always list every field explicitly. Never use `..Default::default()` to fill in remaining fields (nor `..` when destructuring). This ensures that when a proto message gains new fields, every construction site is forced to handle them.

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

## Destructure `req` in RPCs

In RPC handler functions, destructure the `req` argument directly, unless:

- It is passed as-is to a validation function, or
- It is a simple id or `Empty`.

If the request type name is longer than 20 characters, rename it in imports: `use proto::SendManualMessageRequest as Request;`

## Use PascalCase for Protobuf Enum Values

Always use PascalCase for protobuf enum variant names. Do not use SCREAMING_SNAKE_CASE.

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

## Define Messages in Order of First Appearance

Messages and enums in `.proto` files must be defined in the order they first appear (as a field type, request, or response). This keeps the high-level structure visible first and details further down, mirroring a top-down reading order.

## Register New RPCs in the Policies Macro

When adding a new RPC, it must be registered in `Service/src/auths.rs` inside the `policies!` macro so that users have the permission to call it.

## Keep RPC Handlers Thin

RPC handler functions (files under `grpc/`) must contain as little business logic as possible. Their responsibility is strictly limited to:

1. **Validate and convert inputs**
2. **Delegate to business logic**
3. **Convert outputs**

Any non-trivial logic belongs in domain/entity modules, not in the handler itself.

## Deref `ctx.caller.id` to Get a PreValidated Id

To convert `ctx.caller.id` into a `PreValidated<EntityId>`, dereference it with `*`. Do not manually call `EntityId::pre_validated` on the inner value.

```rust
// BAD
EntityId::pre_validated(ctx.caller.id.value)

// GOOD
*ctx.caller.id
```

## Use `SingularPtrFieldExt` for Optional Proto Fields

When extracting a required value from a `SingularPtrField`, use the `SingularPtrFieldExt` trait (from `grpc_helpers_core`) instead of manually matching on `as_ref()` and returning an `RpcStatus`. The trait provides `as_ref_or_missing()`, `ok_or_missing()`, `try_from_ref()`, and many other helpers that compose with `.on_field(...)` for consistent validation.

```rust
// BAD
match send_to_email.as_ref() {
	Some(v) => v,
	None => {
		return Ok(Err(RpcStatus::with_message(
			RpcStatusCode::INVALID_ARGUMENT,
			"send_to_email is required".to_owned(),
		)));
	}
}

// GOOD
try_or_wrap!(send_to_email.as_ref_or_missing().on_field("send_to_email"))
```

## Use `Into<RpcStatus>` for `MissingInDatabase<Id>`

When converting a fail variant that wraps a `MissingInDatabase<Id>` into an `RpcStatus`, use the existing `Into<RpcStatus>` implementation instead of manually building the status.

```rust
// BAD
SendFail::RetailerEntityNotFound { missing_in_database } => {
	RpcStatus::with_message(
		RpcStatusCode::NOT_FOUND,
		format!("Retailer entity not found: {missing_in_database}"),
	)
}

// GOOD
SendFail::RetailerEntityNotFound { missing_in_database } => missing_in_database.into(),
```

## Proto Files May Be Symlinked

Proto files are symlinked into services that call them. To update a proto file, always edit the original source file (usually located in the service that implements the RPC), not the symlink.
