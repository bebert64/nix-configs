# `internal_error` API Reference

**Version:** 1.0.0  
**Generated:** 2026-04-04 12:01 UTC  
**Source:** `/home/romain/Stockly/Main/lib/rust/InternalError/src`  

> This file is auto-generated. Verify against source before acting on any signature.


## `context_pair`

```rust
pub trait InternalErrorContextPairT { ... }
```

> Represents the ability for a type to be turned in an owned context pair

```rust
pub struct InternalErrorContextPair<K, V> { ... }
```

> This structures is typically used to store a pair of key/value for context


## `context_structs`

```rust
pub struct InternalErrorContextValueSerialize<S: serde::Serialize> { ... }
```

> This is the typical structure that could be put in value: anything that is serializable can be turned into a
> `serde_json::Value`

```rust
pub struct InternalErrorContextValueIter<I> { ... }
```

> This version is for serializing iterators

```rust
pub struct InternalErrorContextValueFn<F> { ... }
```

> This version is for lazily outputting values that can be serialized

```rust
pub struct InternalErrorContextValueIterFn<F> { ... }
```

> This version is for lazily outputting an iterator whose elements can be serialized

```rust
pub struct InternalErrorContextValueDebug<D> { ... }
```

> This version is for lazily outputting Debug values

```rust
pub struct InternalErrorContextValueIterDebug<I> { ... }
```

> This version is for lazily outputting iterators of Debug values


## `internal_error`

```rust
pub struct InternalError { ... }
```

> Wrapper around `anyhow::Error` with support for additional json context

```rust
pub struct InternalErrorInner { ... }
```

```rust
pub fn with_ctx(mut self, context: &InternalErrorContext) -> Self { ... }
```

```rust
pub fn with_ctx_val<K, V>(mut self, key: K, value: V) -> Self
	where
		InternalErrorContextPair<K, V>: InternalErrorContextPairT, { ... }
```

```rust
pub fn with_ctx_iter<K, I: IntoIterator>(self, key: K, iter: I) -> Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueIter<I>>: InternalErrorContextPairT, { ... }
```

```rust
pub fn with_ctx_ser<K, S: serde::Serialize>(self, key: K, serializable: S) -> Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueSerialize<S>>: InternalErrorContextPairT, { ... }
```

```rust
pub fn with_ctx_fn<K, F>(self, key: K, f: F) -> Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueFn<F>>: InternalErrorContextPairT, { ... }
```

```rust
pub fn with_ctx_iter_fn<K, F>(self, key: K, iter_f: F) -> Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueIterFn<F>>: InternalErrorContextPairT, { ... }
```

```rust
pub fn with_ctx_debug<K, D>(self, key: K, debug: D) -> Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueDebug<D>>: InternalErrorContextPairT, { ... }
```

```rust
pub fn with_ctx_iter_debug<K, I>(self, key: K, iter_debug: I) -> Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueIterDebug<I>>: InternalErrorContextPairT, { ... }
```

```rust
pub fn add_ctx(&mut self, ctx: &InternalErrorContext) -> &mut Self { ... }
```

```rust
pub fn add_ctx_val<K, V>(&mut self, key: K, value: V) -> &mut Self
	where
		InternalErrorContextPair<K, V>: InternalErrorContextPairT, { ... }
```

```rust
pub fn add_ctx_iter<K, I: IntoIterator>(&mut self, key: K, iter: I) -> &mut Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueIter<I>>: InternalErrorContextPairT, { ... }
```

```rust
pub fn add_ctx_ser<K, S: serde::Serialize>(&mut self, key: K, serializable: S) -> &mut Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueSerialize<S>>: InternalErrorContextPairT, { ... }
```

```rust
pub fn add_ctx_fn<K, F>(&mut self, key: K, f: F) -> &mut Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueFn<F>>: InternalErrorContextPairT, { ... }
```

```rust
pub fn add_ctx_iter_fn<K, F>(&mut self, key: K, iter_f: F) -> &mut Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueIterFn<F>>: InternalErrorContextPairT, { ... }
```

```rust
pub fn add_ctx_debug<K, D>(&mut self, key: K, debug: D) -> &mut Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueDebug<D>>: InternalErrorContextPairT, { ... }
```

```rust
pub fn add_ctx_pair(&mut self, ctx_pair: impl InternalErrorContextPairT) { ... }
```

```rust
pub fn with_prefixed_contexts(mut self, prefix: &str) -> Self { ... }
```

```rust
pub fn while_trying_to(mut self, while_trying_to: &str) -> Self { ... }
```

> Add a new error with `failed to {while_trying_to}` to the beginning of the error chain.
>
> This makes the error message more clear, especially when directly displayed in the terminal.
> (This is useful for CLI applications.)
>
> Implementation-wise, this wraps the inner `anyhow::Error` with `anyhow::Error::context`

```rust
pub fn into_inner(self) -> (anyhow::Error, BTreeMap<String, serde_json::Value>) { ... }
```

```rust
pub fn report_with(
		self,
		patch_event: impl FnOnce(&mut sentry::protocol::Event),
	) -> (anyhow::Error, Option<String>) { ... }
```

```rust
pub fn report_clone_with(&self, patch_event: impl FnOnce(&mut sentry::protocol::Event)) -> Option<String> { ... }
```

```rust
pub fn report(self) -> (anyhow::Error, Option<String>) { ... }
```

```rust
pub fn report_clone(&self) -> Option<String> { ... }
```

```rust
pub fn report_request(
		self,
		protocol: Protocol,
		path: &str,
		request_content: Option<String>,
	) -> (anyhow::Error, Option<String>) { ... }
```

```rust
pub fn patch_event_on_report(
		&mut self,
		patch_event: impl Fn(&mut sentry::protocol::Event) + Send + Sync + 'static,
	) -> &mut Self { ... }
```

```rust
pub fn with_patch_event_on_report(
		mut self,
		patch_event: impl Fn(&mut sentry::protocol::Event) + Send + Sync + 'static,
	) -> Self { ... }
```

```rust
pub fn level(&mut self, level: sentry::Level) -> &mut Self { ... }
```

```rust
pub fn with_level(mut self, level: sentry::Level) -> Self { ... }
```

```rust
pub fn tag(
		&mut self,
		name: impl Borrow<str> + Send + Sync + 'static,
		value: impl Display + Send + Sync + 'static,
	) -> &mut Self { ... }
```

```rust
pub fn with_tag(
		mut self,
		name: impl Borrow<str> + Send + Sync + 'static,
		value: impl Display + Send + Sync + 'static,
	) -> Self { ... }
```

```rust
pub fn add_culprit_prefix(&mut self, prefix: impl Display + Send + Sync + 'static) -> &mut Self { ... }
```

```rust
pub fn with_culprit_prefix(mut self, prefix: impl Display + Send + Sync + 'static) -> Self { ... }
```

```rust
pub fn report_grpc<R: serde::Serialize>(self, path: &str, request: &R) -> (anyhow::Error, Option<String>) { ... }
```

```rust
pub fn report_http(self, path: &str, request_content: Option<String>) -> (anyhow::Error, Option<String>) { ... }
```

```rust
pub fn delegate_report(self) { ... }
```

```rust
pub enum Protocol { ... }
```


## `internal_error_context`

```rust
pub struct InternalErrorContext<'l> { ... }
```

> This is a structure to store a lazy representation of things that could be transformed into owned
> data for being put into an error

```rust
pub trait FromRefInternalErrorContextPairT { ... }
```

> Represents the ability for a type to turned in an owned context pair from a reference

```rust
pub fn new() -> Self { ... }
```

```rust
pub fn with_capacity(cap: usize) -> Self { ... }
```

```rust
pub fn add(&mut self, pair: impl FromRefInternalErrorContextPairT + 'l) -> &mut Self { ... }
```

```rust
pub fn add_val<K, V>(&mut self, key: K, value: V) -> &mut Self
	where
		InternalErrorContextPair<K, V>: FromRefInternalErrorContextPairT + 'l, { ... }
```

```rust
pub fn add_iter<K, I: IntoIterator>(&mut self, key: K, iter: I) -> &mut Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueIter<I>>: FromRefInternalErrorContextPairT + 'l, { ... }
```

```rust
pub fn add_ser<K, S: serde::Serialize>(&mut self, key: K, serializable: S) -> &mut Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueSerialize<S>>: FromRefInternalErrorContextPairT + 'l, { ... }
```

```rust
pub fn add_fn<K, F>(&mut self, key: K, f: F) -> &mut Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueFn<F>>: FromRefInternalErrorContextPairT + 'l, { ... }
```

```rust
pub fn add_iter_fn<K, F>(&mut self, key: K, iter_f: F) -> &mut Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueIterFn<F>>: FromRefInternalErrorContextPairT + 'l, { ... }
```

```rust
pub fn prefix_all(&mut self, prefix: impl std::fmt::Display + Clone + 'l) -> &mut Self { ... }
```

> When rendering this context, all variables that were in this context when this function was called
> will get prefixed

```rust
pub fn with(mut self, pair: impl FromRefInternalErrorContextPairT + 'l) -> Self { ... }
```

```rust
pub fn with_val<K, V>(mut self, key: K, value: V) -> Self
	where
		InternalErrorContextPair<K, V>: FromRefInternalErrorContextPairT + 'l, { ... }
```

```rust
pub fn with_iter<K, I: IntoIterator>(mut self, key: K, iter: I) -> Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueIter<I>>: FromRefInternalErrorContextPairT + 'l, { ... }
```

```rust
pub fn with_ser<K, S: serde::Serialize>(mut self, key: K, serializable: S) -> Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueSerialize<S>>: FromRefInternalErrorContextPairT + 'l, { ... }
```

```rust
pub fn with_fn<K, F>(mut self, key: K, f: F) -> Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueFn<F>>: FromRefInternalErrorContextPairT + 'l, { ... }
```

```rust
pub fn with_iter_fn<K, F>(mut self, key: K, iter_f: F) -> Self
	where
		InternalErrorContextPair<K, InternalErrorContextValueIterFn<F>>: FromRefInternalErrorContextPairT + 'l, { ... }
```

```rust
pub fn with_all_prefixed(mut self, prefix: impl std::fmt::Display + Clone + 'l) -> Self { ... }
```

> When rendering this context, all variables that were in this context when this function was called
> will get prefixed

```rust
pub fn into_owned(self) -> InternalErrorContext<'static> { ... }
```

> Converts this context into an owned version with 'static lifetime


## `iter_extensions`

```rust
pub trait InternalResultIterExtensions: Iterator + Sized { ... }
```

> Utility functions for quickly handling errors

```rust
pub trait InternalResultParIterExtensions: rayon::iter::ParallelIterator + Sized { ... }
```


## `crate`

```rust
pub use { ... }
```

```rust
pub use anyhow;
```

```rust
pub type InternalResult<T> = Result<T, InternalError>;
```

> `Result<T, InternalError>`

```rust
pub fn err_msg(msg: impl std::fmt::Display + std::fmt::Debug + Sync + Send + 'static) -> InternalError { ... }
```

> Constructs a `anyhow::Error` type from a string.
>
> This is a convenient way to turn a string into an error value that
> can be passed around, if you do not want to create a new `thiserror::Error` type for
> this use case.

```rust
pub fn try_or_report<R>(lambda: impl FnOnce() -> InternalResult<R>) { ... }
```

> Execute lambda and send error to sentry in case of error

```rust
pub use sentry_helpers::{self, default_init_sentry, sentry};
```

```rust
pub use sentry_feature::*;
```

```rust
pub use crate::sentry_helpers_stub::*;
```


## `option_extensions`

```rust
pub trait InternalResultOptionExtensions: Sized { ... }
```

> Utility functions for quickly going from an Option to an [`InternalResult`]


## `result_2`

```rust
pub trait Result2 { ... }
```

```rust
pub trait OptResult2 { ... }
```


## `result_extensions`

```rust
pub trait InternalResultResultExtensions: Sized { ... }
```

> Utility functions for adding context to result


## `sample_report`

```rust
pub struct State { ... }
```

```rust
pub const fn new() -> Self { ... }
```

```rust
pub fn push_and_maybe_report(&mut self, internal_error: InternalError) { ... }
```

```rust
pub struct StateWithoutQueue { ... }
```

```rust
pub const fn new() -> Self { ... }
```

```rust
pub fn maybe_report_with(
		&mut self,
		internal_error: InternalError,
		report_fn: impl FnOnce(InternalError) -> (anyhow::Error, Option<String>),
	) -> (anyhow::Error, Option<String>) { ... }
```


## `sentry_helpers_stub`

```rust
pub struct Span { ... }
```

> Fallback for ~Sentry span for when tracing is disabled.
>
> Can be used to link sub-threads to an existing span.

```rust
pub fn current() -> Self { ... }
```

```rust
pub fn link_current_thread(&self) -> SpanGuard { ... }
```

```rust
pub fn set_data<T: Into<serde_json::Value>>(&self, _key: &str, _value: impl FnOnce() -> T) {}

	pub fn set_request<'a, Url>(
		&self,
		_method: &str,
		_url: &Url,
		_headers: impl Iterator<Item = (&'a str, String)>,
		_body: impl FnOnce() -> Option<String>,
	) { ... }
```

```rust
pub fn transaction_name(&self) -> &str { ... }
```

> Returns the name of the current transaction, or "unknown" if not set

```rust
pub struct SpanGuard { ... }
```

```rust
pub fn exit_scope() -> Self { ... }
```
