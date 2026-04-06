# `don_error` API Reference

**Version:** 0.1.0  
**Generated:** 2026-04-04 12:01 UTC  
**Source:** `/home/romain/code/Main/libs/don_error/Crate/src`  

> This file is auto-generated. Verify against source before acting on any signature.


## `don_error`

```rust
pub struct DonError { ... }
```

> Wrapper around `anyhow::Error` with support for additional json context

```rust
pub struct DonErrorInner { ... }
```

```rust
pub fn report(&self) { ... }
```

```rust
pub fn with_ctx(mut self, context: &DonErrorContext) -> Self { ... }
```

```rust
pub fn with_ctx_val<K, V>(mut self, key: K, value: V) -> Self
    where
        DonErrorContextPair<K, V>: DonErrorContextPairT, { ... }
```

```rust
pub fn with_ctx_ser<K, S: serde::Serialize>(self, key: K, serializable: S) -> Self
    where
        DonErrorContextPair<K, DonErrorContextValueSerialize<S>>: DonErrorContextPairT, { ... }
```

```rust
pub fn add_ctx(&mut self, ctx: &DonErrorContext) -> &mut Self { ... }
```

```rust
pub fn add_ctx_val<K, V>(&mut self, key: K, value: V) -> &mut Self
    where
        DonErrorContextPair<K, V>: DonErrorContextPairT, { ... }
```

```rust
pub fn add_ctx_ser<K, S: serde::Serialize>(&mut self, key: K, serializable: S) -> &mut Self
    where
        DonErrorContextPair<K, DonErrorContextValueSerialize<S>>: DonErrorContextPairT, { ... }
```

```rust
pub fn add_ctx_pair(&mut self, ctx_pair: impl DonErrorContextPairT) { ... }
```

```rust
pub fn into_inner(self) -> (anyhow::Error, BTreeMap<String, serde_json::Value>) { ... }
```


## `don_error_ctx`

```rust
pub struct DonErrorContext<'l> { ... }
```

> This is a structure to store a lazy representation of things that could be transformed into
> owned data for being put into an error

```rust
pub trait FromRefDonErrorContextPairT { ... }
```

> Represents the ability for a type to turned in an owned context pair from a reference

```rust
pub fn new() -> Self { ... }
```

```rust
pub fn add(&mut self, pair: impl FromRefDonErrorContextPairT + 'l) -> &mut Self { ... }
```

```rust
pub fn add_val<K, V>(&mut self, key: K, value: V) -> &mut Self
    where
        DonErrorContextPair<K, V>: FromRefDonErrorContextPairT + 'l, { ... }
```

```rust
pub fn add_ser<K, S: serde::Serialize>(&mut self, key: K, serializable: S) -> &mut Self
    where
        DonErrorContextPair<K, DonErrorContextValueSerialize<S>>: FromRefDonErrorContextPairT + 'l, { ... }
```

```rust
pub fn with(mut self, pair: impl FromRefDonErrorContextPairT + 'l) -> Self { ... }
```

```rust
pub fn with_val<K, V>(mut self, key: K, value: V) -> Self
    where
        DonErrorContextPair<K, V>: FromRefDonErrorContextPairT + 'l, { ... }
```

```rust
pub fn with_ser<K, S: serde::Serialize>(mut self, key: K, serializable: S) -> Self
    where
        DonErrorContextPair<K, DonErrorContextValueSerialize<S>>: FromRefDonErrorContextPairT + 'l, { ... }
```

```rust
pub struct DonErrorContextValueSerialize<S: serde::Serialize> { ... }
```

> This is the typical structure that could be put in value: anything that is serializable can be
> turned into a `serde_json::Value`

```rust
pub trait DonErrorContextPairT { ... }
```

> Represents the ability for a type to be turned in an owned context pair

```rust
pub struct DonErrorContextPair<K, V> { ... }
```

> This structures is typically used to store a pair of key/value for context


## `helpers`

```rust
pub use yew::ReportedDonError;
```


## `helpers::yew`

```rust
pub struct ReportedDonError {}

impl From<DonError> for ReportedDonError { ... }
```


## `crate`

```rust
pub use { ... }
```

```rust
pub use helpers::*;
```

```rust
pub type DonHttpResult<T> = DonResult<actix_web::web::Json<T>>;
```

```rust
pub type DonHttpResult2<T, F> = DonResult<Result<actix_web::web::Json<T>, F>>;
```

```rust
pub type DonResult<T> = std::result::Result<T, DonError>;
```

```rust
pub fn try_or_report(lambda: impl FnOnce() -> DonResult<()>) { ... }
```

> Execute lambda and report in case of error


## `option_extensions`

```rust
pub trait DonResultOptionExtensions: Sized { ... }
```


## `result_extensions`

```rust
pub trait DonResultResultExtensions: Sized { ... }
```

> Utility functions for adding context to result

```rust
pub trait DonResultFlattenExtensions<T, E> { ... }
```
