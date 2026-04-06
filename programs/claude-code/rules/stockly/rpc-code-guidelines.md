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

## Register New RPCs in the Policies Macro

When adding a new RPC, it must be registered in `Service/src/auths.rs` inside the `policies!` macro so that users have the permission to call it.

## Keep RPC Handlers Thin

RPC handler functions (files under `grpc/`) must contain as little business logic as possible. Their responsibility is strictly limited to:

1. **Validate and convert inputs**
2. **Delegate to business logic**
3. **Convert outputs**

Any non-trivial logic belongs in domain/entity modules, not in the handler itself.

## Proto Files May Be Symlinked

Proto files are symlinked into services that call them. To update a proto file, always edit the original source file (usually located in the service that implements the RPC), not the symlink.
