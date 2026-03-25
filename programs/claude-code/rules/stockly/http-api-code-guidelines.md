---
paths:
  - "**/http/**/*.rs"
---

# HTTP API Code Guidelines

## Destructure Query/Body Inputs in Handlers

In HTTP handler functions, destructure the `Json(...)` or `Query(...)` argument directly, unless:

- It is passed as-is to another function, or
- It contains a single field (e.g., a simple id).

```rust
// BAD
fn handler(Json(input): &Json<PasswordInput>) -> InternalResult<Response> {
	do_something(input.email, input.password)
}

// GOOD
fn handler(
	Json(PasswordInput { email, password }): &Json<PasswordInput>,
) -> InternalResult<Response> {
	do_something(email, password)
}
```

The same applies to `Query`:

```rust
// GOOD
fn handler(
	Query(VerifyQuery { id, token }): &Query<VerifyQuery>,
) -> InternalResult<Response> {
	verify(*id, token)
}
```
