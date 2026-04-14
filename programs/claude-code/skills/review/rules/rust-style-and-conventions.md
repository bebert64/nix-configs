# Code structure (Rust)

- **No single-field wrapper Config**: When a `Config` struct contains a single field wrapping another struct, flatten the inner struct into `Config` directly. The extra nesting level adds nothing and forces every access through a redundant field (e.g. `CONFIG.app.foo` instead of `CONFIG.foo`).
- **Inline single-use variables**: Do not introduce a variable used only once. Inline the expression at its usage site. Exception: keep if inlining would break the code. Applies to ALL code including tests.
- **Inline single-use functions**: Do not extract a private function called from exactly one place. Exception: genuinely reusable logic or trait implementations.
- **Module declaration**: No inline modules (except short tests <20 lines). Place all modules in separate files. `mod` declarations grouped together, alphabetically sorted, at the top.
- **Items ordering**: Mirror top-down reading order -- outermost to innermost. Input/Recap/Fail structs above the public function they serve, private helpers at the bottom ordered by first reference. All item definitions ordered by first reference, outermost first.
- **Code ordering**: Most relevant to least relevant (top to bottom). Local helpers at the bottom.
- **Prefer `match`** over `if let ... else` when both branches of an Option/Result are handled. `if let` without `else` is fine.

# Coding Preferences

## Rust

- Always favor `to_owned()` over `to_string()` to get a `String` from an `&str` or `&String`. For `Cow<str> -> String`, use `into_owned()` instead.

- **Prefer `try_or_wrap!`** over `let ... else { return Ok(Err(...)) }` for extracting values with Fail returns.

# Coding Principles

## Performance

- **Optimize for the happy path** — the common case should be fast; edge cases can be slower.

# Rust Code Guidelines

- **Visibility**: apply in order: private (default) → `pub(crate)` → `pub`. Avoid `pub(super)` and `pub(in path)`.
- **Destructure structs without `..`**: especially in function arguments, to force handling every field when the struct changes. Exception: when renaming many fields would be more confusing.
- **Avoid `#[allow(unused)]` on Fail fields**: use fields explicitly when converting to something else — produces better error messages.

# split never returns an empty iterator

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

# Deref for wrapper structs

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

# Entry API: prefer `.or_default()`

Use `.entry(key).or_default()` instead of `.entry(key).or_insert(Vec::new())` or `.or_insert(HashMap::new())` when the default value is `Default::default()`.

# Named constants for domain-specific values

Extract delay, timeout, and threshold literals into named `const` values when they have domain-specific semantics or are used in more than one place. Include a comment explaining *why* the value is what it is:

```rust
// Communicated to customers in messages
const PUBLIC_SENDING_DELAY: TimeDelta = TimeDelta::days(10);
// Internal deadline — longer than public to reduce "close to deadline" complaints
const INTERNAL_SENDING_DELAY: TimeDelta = TimeDelta::days(14);
```

# Input struct for many same-type arguments

When a function takes several arguments that share a type (e.g. multiple `String`, multiple `bool`), group the domain arguments into a named struct so that each field is labeled — makes accidental swaps easier to spot in review. Keep infrastructure arguments (`db`, loggers) as separate parameters.
