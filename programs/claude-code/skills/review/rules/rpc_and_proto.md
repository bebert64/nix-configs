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
