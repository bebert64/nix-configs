# Rust Gotchas

Tips for subtle Rust pitfalls. Read when working with the specific patterns below.

## split never returns an empty iterator

Per its documentation, `str::split().next()` always returns `Some`. Using `unwrap_or(...)` hides this invariant. Instead:

- In fallible functions: use the project error helper (e.g. `.ok_or_don_err(...)`, `.ok_or_internal_err(...)`) with `?`
- In infallible functions: use `.expect("split never returns an empty iterator")`

```rust
// Bad: hides that the None case is impossible
let mime = ct.split(';').next().unwrap_or("").trim();

// Good (fallible):
let mime = ct.split(';').next().ok_or_err("split never returns an empty iterator")?;

// Good (infallible):
let mime = ct.split(';').next().expect("split never returns an empty iterator");
```

## Deref for wrapper structs

When creating a wrapper struct around an inner type, derive `Deref` targeting the inner type so callers can access the inner methods directly without writing `.inner`.

Use `derive_more::Deref` with `#[deref]` on the inner field:

```rust
#[derive(derive_more::Deref)]
struct MyWrapper {
    #[deref]
    inner: InnerType,
    extra_field: bool,
}

wrapper.some_inner_method()  // calls InnerType method directly
```

## Diesel nullable left joins

When building a nullable struct from a left join, at least one selected column must come from the right table and be nullable (e.g. its primary key). Otherwise, expressions like `is_not_null()` or non-optional columns can make the tuple non-optional and the struct always `Some`, even when there is no matching row.

Include a column from the right table that is NULL when the row is missing (e.g. the right table `id`).
