# `validation` API Reference

**Version:** 1.0.0  
**Generated:** 2026-04-04 12:01 UTC  
**Source:** `/home/romain/Stockly/Main/lib/rust/validation/Crate/src`  

> This file is auto-generated. Verify against source before acting on any signature.


## `field_invalidity::add_invalidity_field_information`

```rust
pub trait AddInvalidityFieldInformation: Sized { ... }
```


## `field_invalidity::error`

```rust
pub struct Error<I: InvalidityExt + 'static> { ... }
```

```rust
pub fn into_err_displayed(self) -> Error<InvalidityDisplayed> { ... }
```


## `field_invalidity`

```rust
pub use {add_invalidity_field_information::*, error::Error as FieldInvalidityError, source_path::*};
```

```rust
pub type FieldInvaliditySourcePath = SourcePath<SmallVec<[SourcePathElem; 5]>>;
```

```rust
pub struct FieldInvalidity<I: InvalidityExt> { ... }
```

```rust
pub type DynFieldInvalidity<'a> = FieldInvalidity<DynInvalidity<'a>>;
```

```rust
pub fn into_inv_displayed(self) -> FieldInvalidity<InvalidityDisplayed> { ... }
```

```rust
pub fn clone_to_inv_displayed(&self) -> FieldInvalidity<InvalidityDisplayed> { ... }
```

```rust
pub fn map_inv<I2: InvalidityExt, F: FnOnce(I) -> I2>(self, op: F) -> FieldInvalidity<I2> { ... }
```


## `field_invalidity::source_path`

```rust
pub struct SourcePath<Container> { ... }
```

> It's allowed for a source path to be empty, when field information is optional

```rust
pub fn is_empty(&self) -> bool { ... }
```

```rust
pub trait IntoSourcePath { ... }
```

```rust
pub struct SourcePathElem { ... }
```

> This structure guarantees that `FieldNames` and `SourcePathElems` never contain empty arrays

```rust
pub struct CollectionShouldNotBeEmpty;
```

```rust
pub fn inner(&self) -> &SourcePathElemInner { ... }
```

```rust
pub fn index(index: usize) -> Self { ... }
```

```rust
pub fn validated(self) -> Result<SourcePathElem, CollectionShouldNotBeEmpty> { ... }
```

> Returns an error if either `FieldNames` or `SourcePathElems` variants contain an empty array

```rust
pub enum SourcePathElemInner { ... }
```

```rust
pub trait IntoInconsistency { ... }
```


## `invalidity`

```rust
pub trait Invalidity: fmt::Display + fmt::Debug + Send + Sync {}

pub trait InvalidityExt: fmt::Display + fmt::Debug + Send + Sync {}

impl<I: InvalidityExt + 'static> crate::IntoErr for I { ... }
```

> A type implementing this trait describes an invalidity, as well as any information that will be necessary for the
> user to understand why the value is invalid and how to fix it.
>
> The `Display` impl should give the following information:
> - What makes the value invalid
> - What we received (that information has to be stored in the structure/enum implementing `Invalidity`)
> - Optionally, some help on how to fix it

```rust
pub type DynInvalidity<'a> = Box<dyn Invalidity + 'a>;
```

```rust
pub struct Displayed { ... }
```

```rust
pub struct Error<I: InvalidityExt + 'static> { ... }
```


## `iter_ext`

```rust
pub struct EmptyIterator;
```

```rust
pub struct ItemNotFound;
```

```rust
pub trait IterExt: Iterator + Sized { ... }
```

```rust
pub struct ValidateIterWithoutSource<Invalidity, Validated, Iter, Validation>
where
	Invalidity: AddInvalidityFieldInformation,
	Iter: Iterator,
	Validation: FnMut(<Iter as Iterator>::Item) -> Result<Validated, Invalidity>, { ... }
```

> This struct should never be directly constructed. It's an intermediate step to force the use of
> [`AddInvalidityFieldInformation::on_field`] after the use of [`IterExt::validate`] function

```rust
pub struct ValidateIter<Invalidity, Validated, Iter, Validation>
where
	Invalidity: AddInvalidityFieldInformation,
	Iter: Iterator,
	Validation: FnMut(<Iter as Iterator>::Item) -> Result<Validated, Invalidity>, { ... }
```

> An iterator that validates elements of the inner iterator and inserts source upon first invalidity.
>
> This struct is created by the [`IterExt::validate`] method followed by
> [`on_field`](AddInvalidityFieldInformation::on_field). See its [documentation](IterExt::validate) for more.


## `crate`

```rust
pub use { ... }
```

```rust
pub use validation_derives::*;
```

```rust
pub use validations::*;
```

```rust
pub use {chrono, derive_more};
```

```rust
pub use super::{MapExt as _, SerdeJsonValueExt as _, SerdeJsonValueRefExt as _, StringExt as _};
```

```rust
pub use diesel::query_source::SizeRestrictedColumn;
```

```rust
pub use { ... }
```

```rust
pub use prelude::*;
```

```rust
pub use regex_helpers::static_lazy_tested_regex;
```

```rust
pub trait IntoCheatingOrphanRule<P, T> { ... }
```

> Essentially a duplicate of `Into<T>`, but more flexible.
>
> `P` is always `crate::CheatingOrphanRuleHelper` defined locally by the crate that needs to implement the trait for a
> given pair of types. This allows cheating the orphan rule. (see below for more details)
>
> # How it works
> Because the proto types and the target type may not be owned by the crate that needs to define the `Into`
> implementation, we cannot implement `Into` (or `From`) directly for them. (This is the orphan rule.)
>
> However, when calling a generic function, if there is a single type that satisfies the constraints of a given
> generic argument, then the compiler will infer that type.
>
> This means that as long as there is only one concrete type `P` that `IntoCheatingOrphanRule<P, T> for T2` is
> implemented for, then we can call `let t2 = t.into_cor();` and keep the ergonomics of `Into`, despite both `T` and
> `T2` being defined in separate crates.
>
> For that purpose, every crate that needs to implement such `Into`s that cheat the orphan rule defines a
> `CheatingOrphanRuleHelper` type that is unique to that crate. This type is then used as the `P` type parameter in
> `IntoCheatingOrphanRule<P, T> for T2`.

```rust
pub trait TryIntoCheatingOrphanRule<P, T> { ... }
```

```rust
pub trait IntoErr { ... }
```


## `reason`

```rust
pub enum Reason<ClassicalReason, S: Borrow<str>> { ... }
```

```rust
pub trait Other: Copy { ... }
```

```rust
pub trait DbEnum { ... }
```

```rust
pub enum ReasonInvalidity<S: Borrow<str>> { ... }
```

```rust
pub fn borrowed(&self) -> Reason<ClassicalReason, &str>
	where
		ClassicalReason: Copy, { ... }
```

```rust
pub fn db_enum(&self) -> <ClassicalReason as DbEnum>::DbEnum
	where
		ClassicalReason: DbEnum,
		<ClassicalReason as DbEnum>::DbEnum: Other, { ... }
```

```rust
pub fn into_details(self) -> Option<S> { ... }
```

```rust
pub fn details(&self) -> Option<&str> { ... }
```

> The `&str` returned is of the same lifetime as [`Self`], if you have a `Reason<C, &str>` you can use
> [`into_details`](Self::into_details) to get a `Option<&str>` with the same lifetime as the underlying `&str`.

```rust
pub fn validated<ProtoReason: TryInto<ClassicalReason, Error = ()>>(
		proto_reason: ProtoReason,
		reason_details: S,
	) -> Result<Self, ReasonInvalidity<S>> { ... }
```

```rust
pub fn validated_cor<
		CheatingOrphanRuleHelper,
		ProtoReason: TryIntoCheatingOrphanRule<CheatingOrphanRuleHelper, ClassicalReason, Error = ()>,
	>(
		proto_reason: ProtoReason,
		reason_details: S,
	) -> Result<Self, ReasonInvalidity<S>> { ... }
```

```rust
pub fn as_enum<T: Other>(&self) -> T
	where
		ClassicalReason: Into<T> + Copy, { ... }
```

```rust
pub fn as_enum_cor<CheatingOrphanRuleHelper, T: Other>(&self) -> T
	where
		ClassicalReason: IntoCheatingOrphanRule<CheatingOrphanRuleHelper, T> + Copy, { ... }
```

```rust
pub fn try_from_row(db_enum: ClassicalReason::DbEnum, details: Option<String>) -> Result<Self, &'static str>
		where
			ClassicalReason: DbEnum<DbEnum: TryInto<ClassicalReason, Error = ()>>, { ... }
```


## `result_ext`

```rust
pub trait ResultIntoErrExt { ... }
```

```rust
pub trait ResultOfFieldInvalidityExt { ... }
```

```rust
pub trait ResultOfInvalidityExt { ... }
```


## `validations::custom`

```rust
pub struct CustomInvalidity { ... }
```

```rust
pub fn new(description: impl Into<Cow<'static, str>>) -> Self { ... }
```

```rust
pub fn from_display(err: impl fmt::Display, val: impl fmt::Debug) -> Self { ... }
```


## `validations::duration`

```rust
pub struct InvalidTimeDeltaMillis { ... }
```

```rust
pub fn validated_duration_millis(millis: i64) -> Result<TimeDelta, InvalidTimeDeltaMillis> { ... }
```

```rust
pub fn validated_duration_millis_as_opt(millis: i64) -> Result<Option<TimeDelta>, InvalidTimeDeltaMillis> { ... }
```

```rust
pub struct InvalidTimeDeltaSecs { ... }
```

```rust
pub fn validated_duration_secs(secs: i64) -> Result<TimeDelta, InvalidTimeDeltaSecs> { ... }
```

```rust
pub fn validated_duration_secs_as_opt(secs: i64) -> Result<Option<TimeDelta>, InvalidTimeDeltaSecs> { ... }
```


## `validations::email`

```rust
pub enum EmailInvalidity<S: Borrow<str>> { ... }
```

```rust
pub fn validated_email<T: Borrow<str>>(email: T) -> Result<T, EmailInvalidity<T>> { ... }
```

> An email needs to be lowercase to be considered valid.

```rust
pub fn validated_email_as_opt<S: Borrow<str>>(email: S) -> Result<Option<S>, EmailInvalidity<S>> { ... }
```


## `validations::emojis`

```rust
pub struct InvalidEmoji<T: Borrow<str> + Display>(T);
```

```rust
pub fn pre_validated_emoji<T: Borrow<str> + Display>(val: T) -> Result<T, InvalidEmoji<T>> { ... }
```

```rust
pub fn pre_validated_emoji_as_opt<T: Borrow<str> + Display>(val: T) -> Result<Option<T>, InvalidEmoji<T>> { ... }
```


## `validations::exts::float_ext`

```rust
pub trait FloatExt: ::float_ext::FloatExt + 'static + fmt::Display + fmt::Debug + Send + Sync + Sized { ... }
```


## `validations::exts::i64_ext`

```rust
pub trait I64Ext { ... }
```


## `validations::exts::integer_ext`

```rust
pub trait IntegerExt: num::Integer + 'static + fmt::Display + fmt::Debug + Send + Sync + Sized { ... }
```


## `validations::exts`

```rust
pub use {float_ext::*, i64_ext::*, integer_ext::*, strings::*};
```

```rust
pub trait ValidatedWith: Sized { ... }
```

```rust
pub trait CopyExt: Sized + Copy { ... }
```


## `validations::exts::strings::borrow_str_ext`

```rust
pub trait BorrowStrExt: Borrow<str> + Sized { ... }
```


## `validations::exts::strings`

```rust
pub use {borrow_str_ext::*, str_ext::*};
```

```rust
pub use string_ext::*;
```


## `validations::exts::strings::str_ext`

```rust
pub trait StrExt<'a> { ... }
```


## `validations::exts::strings::string_ext`

```rust
pub trait StringExt { ... }
```


## `validations::floats`

```rust
pub struct IsNan {}

impl fmt::Display for IsNan { ... }
```

```rust
pub fn validated_not_nan<N: FloatExt + fmt::Debug + Send + Sync + 'static>(num: N) -> Result<N, IsNan> { ... }
```

> Validate input is not NAN.

```rust
pub fn validated_not_nan_as_opt<N: FloatExt + fmt::Debug + Send + Sync + 'static>(num: N) -> Option<N> { ... }
```

> Validate input is not NAN as an Option

```rust
pub fn validated_tolerant_pos<N: FloatExt + fmt::Debug + Send + Sync + 'static>(
	num: N,
) -> Result<N, IsStrictlyLess<N>> { ... }
```

> Validate input is positive (0 or greater), error if strictly negative.

```rust
pub fn validated_tolerant_pos_as_opt<N: FloatExt + fmt::Debug + Send + Sync + 'static>(
	num: N,
) -> Result<Option<N>, IsStrictlyLess<N>> { ... }
```

> Validate input is strictly greater than 0, none if zero.

```rust
pub struct $inv<N: FloatExt + fmt::Debug + Send + Sync + 'static> { ... }
```

```rust
pub fn $val_name<N: FloatExt + fmt::Debug + Send + Sync + 'static>(num: N, limit: N) -> Result<N, $inv<N>> { ... }
```


## `validations::integers`

```rust
pub fn validated_strictly_pos<N: Integer + fmt::Debug + Send + Sync + 'static>(num: N) -> Result<N, IsLessOrEqual<N>> { ... }
```

```rust
pub fn validated_strictly_pos_as_opt<N: Integer + fmt::Debug + Send + Sync + 'static>(
	num: N,
) -> Result<Option<N>, IsStrictlyLess<N>> { ... }
```

> Validate input is strictly greater than 0, none if zero.

```rust
pub struct $inv<N: Integer + fmt::Debug + Send + Sync + 'static> { ... }
```

```rust
pub fn $val_name<N: Integer + fmt::Debug + Send + Sync + 'static>(
			num: N,
			limit: N,
		) -> Result<N, $inv<N>> { ... }
```


## `validations`

```rust
pub use self::serde_json::*;
```

```rust
pub use { ... }
```

```rust
pub use self::url::*;
```

```rust
pub(super) use { ... }
```

```rust
pub struct ReceivedStr<'a> { ... }
```

> Helper to display a received string as "(Got: \`value\`)" and "(Got: \`truncated_val...\`)" if too long

```rust
pub fn new(value: &'a str) -> Self { ... }
```

```rust
pub struct MissingField;
```


## `validations::parse`

```rust
pub type ParseResult<V, T> = Result<T, ParseInvalidity<V, T>>;
```

```rust
pub struct ParseInvalidity<V: Borrow<str>, T: FromStr>
where
	<T as FromStr>::Err: fmt::Display + fmt::Debug, { ... }
```

```rust
pub fn with_original_value<V2: Borrow<str>>(self, original_value: V2) -> ParseInvalidity<V2, T> { ... }
```

> This functions is to used when the original value has been modified before being parsed (e.g. trimmed)

```rust
pub fn validated_parse<T: FromStr, V: Borrow<str>>(value: V) -> Result<T, ParseInvalidity<V, T>>
where
	<T as FromStr>::Err: fmt::Display + fmt::Debug, { ... }
```

```rust
pub fn validated_parse_as_opt<T: FromStr, V: Borrow<str>>(value: V) -> Result<Option<T>, ParseInvalidity<V, T>>
where
	<T as FromStr>::Err: fmt::Display + fmt::Debug, { ... }
```


## `validations::retailer_specific_id`

```rust
pub enum RetailerSpecificIdInvalidity<S: Borrow<str>> { ... }
```

```rust
pub fn validated_retailer_specific_id_as_opt<T: Borrow<str>>(
	value: T,
) -> Result<Option<T>, RetailerSpecificIdInvalidity<T>> { ... }
```

```rust
pub fn validated_retailer_specific_id<T: Borrow<str>>(value: T) -> Result<T, RetailerSpecificIdInvalidity<T>> { ... }
```


## `validations::rgx`

```rust
pub struct DoesNotRespectRegex<S: Borrow<str>> { ... }
```

```rust
pub fn validated_respects_regex<S: Borrow<str>>(s: S, rgx: &'static Regex) -> Result<S, DoesNotRespectRegex<S>> { ... }
```

```rust
pub struct RegexInvalidity(regex::Error);
```

```rust
pub fn validated_regex<S: Borrow<str>>(re: S) -> Result<Regex, RegexInvalidity> { ... }
```

> Compiles the regex

```rust
pub fn validated_regex_opt<S: Borrow<str>>(re: S) -> Result<Option<Regex>, RegexInvalidity> { ... }
```

```rust
pub struct FullMatchRegexInvalidity<S: Borrow<str>> { ... }
```

```rust
pub enum FullMatchRegexInvalidityReason { ... }
```

```rust
pub fn validated_regex_full_match<S: Borrow<str>>(rcv: S) -> Result<Regex, FullMatchRegexInvalidity<S>> { ... }
```


## `validations::serde_json::deserialization`

```rust
pub struct JsonDeserializationFailure<S: Borrow<str>> { ... }
```

```rust
pub fn into_owned(self) -> JsonDeserializationFailure<String> { ... }
```

```rust
pub fn validated_deserialized_json<'a, T: Deserialize<'a>>(
	json_str: &'a str,
) -> Result<T, JsonDeserializationFailure<&'a str>> { ... }
```

```rust
pub fn validated_deserialized_json_as_opt<'a, T: Deserialize<'a>>(
	json_str: &'a str,
) -> Result<Option<T>, JsonDeserializationFailure<&'a str>> { ... }
```

```rust
pub fn validated_deserialized_json_owned<S: Borrow<str>, T: serde::de::DeserializeOwned>(
	json_str: S,
) -> Result<T, JsonDeserializationFailure<S>> { ... }
```

```rust
pub fn validated_deserialized_json_owned_as_opt<S: Borrow<str>, T: serde::de::DeserializeOwned>(
	json_str: S,
) -> Result<Option<T>, JsonDeserializationFailure<S>> { ... }
```

```rust
pub use tera::*;
```

```rust
pub struct TeraDeserializationFailure<S: Borrow<str>> { ... }
```

```rust
pub enum TeraDeserializationFailReason { ... }
```

```rust
pub fn validated_deserialized_tera_context<S: Borrow<str>>(
		tera_context_str: S,
	) -> Result<::tera::Context, TeraDeserializationFailure<S>> { ... }
```

```rust
pub struct JsonValueDeserializationFailure<S: Borrow<serde_json::Value>> { ... }
```

```rust
pub fn validated_deserialized_json_value_owned<S: Borrow<serde_json::Value>, T: serde::de::DeserializeOwned>(
	json_value: S,
) -> Result<T, JsonValueDeserializationFailure<S>> { ... }
```

> This exists for backwards-compatibility purposes.
>
> In general, you should validate directly from the &str to the expected type.


## `validations::serde_json::map`

```rust
pub struct SerdeJsonMap { ... }
```

```rust
pub struct IsNotAnObj;
```

```rust
pub fn new(map: serde_json::Map<String, serde_json::Value>) -> Self { ... }
```

```rust
pub fn as_obj(&self) -> &serde_json::Map<String, serde_json::Value> { ... }
```

```rust
pub fn as_obj_mut(&mut self) -> &mut serde_json::Map<String, serde_json::Value> { ... }
```

```rust
pub fn as_val(&self) -> &serde_json::Value { ... }
```

```rust
pub fn validated(value: serde_json::Value) -> Result<Self, IsNotAnObj> { ... }
```

```rust
pub fn into_inner(self) -> serde_json::Value { ... }
```


## `validations::serde_json::map_ext`

```rust
pub enum GetFieldAsInvalidity<V: Borrow<Value>> { ... }
```

```rust
pub trait MapExt: Sized { ... }
```


## `validations::serde_json`

```rust
pub use { ... }
```

```rust
pub struct UnexpectedType<V: Borrow<Value>> { ... }
```


## `validations::serde_json::value`

```rust
pub trait SerdeJsonValueExt: Borrow<Value> + Sized { ... }
```

```rust
pub trait SerdeJsonValueRefExt<'v>: Borrow<Value> + Sized { ... }
```


## `validations::string_case`

```rust
pub struct HasNotIdempotentUppercaseChar<S: Borrow<str>> { ... }
```

```rust
pub fn validated_idempotent_uppercase<T: Borrow<str>>(value: T) -> Result<T, HasNotIdempotentUppercaseChar<T>> { ... }
```

```rust
pub struct [<IsNot $case_name:camel Case>]<S: Borrow<str>> { ... }
```

```rust
pub fn [<validated_ $case_name:snake _case>]<T: Borrow<str>>(value: T) -> Result<T, [<IsNot $case_name:camel Case>]<T>> { ... }
```


## `validations::string_length`

```rust
pub struct StringLengthInvalidity<S: Borrow<str>> { ... }
```

```rust
pub enum StringLengthInvalidityReason { ... }
```

> This is a temporary enum created from `StringLengthInvalidity` to manage the use case where you want to validate
> a string with the pattern:
> 1. Prepare the string (ex removing invalid characters)
> 2. Check that the resulting string is not empty
> 3. Replace within the invalidity the prepared string by the original value

```rust
pub fn reason(self) -> StringLengthInvalidityReason { ... }
```

```rust
pub fn with_received<S: Borrow<str>>(self, received: S) -> StringLengthInvalidity<S> { ... }
```

```rust
pub fn validated_len_eq<T: Borrow<str>>(value: T, size: usize) -> Result<T, StringLengthInvalidity<T>> { ... }
```

```rust
pub fn validated_len_eq_as_opt<T: Borrow<str>>(value: T, size: usize) -> Result<Option<T>, StringLengthInvalidity<T>> { ... }
```

```rust
pub fn validated_len_lte<T: Borrow<str>>(value: T, max_size: usize) -> Result<T, StringLengthInvalidity<T>> { ... }
```

```rust
pub fn validated_len_lte_as_opt<T: Borrow<str>>(
	value: T,
	max_size: usize,
) -> Result<Option<T>, StringLengthInvalidity<T>> { ... }
```

```rust
pub fn validated_non_empty<T: Borrow<str>>(value: T) -> Result<T, StringLengthInvalidity<T>> { ... }
```

```rust
pub fn validated_trimmed_non_empty<'a>(value: &'a str) -> Result<&'a str, StringLengthInvalidity<&'a str>> { ... }
```

```rust
pub fn validated_non_empty_and_len_lte<T: Borrow<str>>(
	value: T,
	max_size: usize,
) -> Result<T, StringLengthInvalidity<T>> { ... }
```

```rust
pub fn validated_len_gte<T: Borrow<str>>(value: T, min_size: usize) -> Result<T, StringLengthInvalidity<T>> { ... }
```

```rust
pub fn validated_non_empty_as_opt<T: Borrow<str>>(value: T) -> Option<T> { ... }
```

> Other functions of this module validate the absence of nul-bytes (which Postgresql does not tolerate),
> but to avoid needing for this function to return a Result, we skip that check here.


## `validations::timestamp`

```rust
pub struct InvalidTimestampMillis { ... }
```

```rust
pub fn validated_timestamp_millis(millis: i64) -> Result<DateTime<Utc>, InvalidTimestampMillis> { ... }
```

```rust
pub fn validated_timestamp_millis_as_opt(millis: i64) -> Result<Option<DateTime<Utc>>, InvalidTimestampMillis> { ... }
```

```rust
pub struct InvalidTimestampSecs { ... }
```

```rust
pub fn validated_timestamp_secs(secs: i64) -> Result<DateTime<Utc>, InvalidTimestampSecs> { ... }
```

```rust
pub fn validated_timestamp_secs_as_opt(secs: i64) -> Result<Option<DateTime<Utc>>, InvalidTimestampSecs> { ... }
```

```rust
pub enum InvalidRecentTimestampReason { ... }
```

```rust
pub struct InvalidRecentTimestampMillis { ... }
```

```rust
pub fn validated_recent_timestamp_millis(millis: i64) -> Result<DateTime<Utc>, InvalidRecentTimestampMillis> { ... }
```

```rust
pub fn validated_recent_timestamp_millis_as_opt(
	millis: i64,
) -> Result<Option<DateTime<Utc>>, InvalidRecentTimestampMillis> { ... }
```

```rust
pub struct InvalidRecentTimestampSecs { ... }
```

```rust
pub fn validated_recent_timestamp_secs(secs: i64) -> Result<DateTime<Utc>, InvalidRecentTimestampSecs> { ... }
```

```rust
pub fn validated_recent_timestamp_secs_as_opt(secs: i64) -> Result<Option<DateTime<Utc>>, InvalidRecentTimestampSecs> { ... }
```


## `validations::try_into`

```rust
pub struct ByTryIntoFailureInvalidity<V, O>
where
	V: Copy + fmt::Debug + Send + Sync + TryInto<O>,
	<V as TryInto<O>>::Error: fmt::Display + fmt::Debug + Send + Sync, { ... }
```

```rust
pub fn validated_by_try_into<O, V>(value: V) -> Result<O, ByTryIntoFailureInvalidity<V, O>>
where
	V: Copy + fmt::Debug + Send + Sync + TryInto<O>,
	<V as TryInto<O>>::Error: fmt::Display + fmt::Debug + Send + Sync, { ... }
```

> To get a nice invalidity with nice message when using `TryInto` implementations that are external to this framework
> e.g. when converting between integer types using the `TryInto` impl from the standard library.

```rust
pub struct ByTryIntoCorFailureInvalidity<H, V, O>
where
	V: Copy + fmt::Debug + Send + Sync + TryIntoCheatingOrphanRule<H, O>,
	<V as TryIntoCheatingOrphanRule<H, O>>::Error: fmt::Display + fmt::Debug + Send + Sync, { ... }
```

```rust
pub fn validated_by_try_into_cor<O, V, H>(value: V) -> Result<O, ByTryIntoCorFailureInvalidity<H, V, O>>
where
	V: Copy + fmt::Debug + Send + Sync + TryIntoCheatingOrphanRule<H, O>,
	<V as TryIntoCheatingOrphanRule<H, O>>::Error: fmt::Display + fmt::Debug + Send + Sync, { ... }
```

> To get a nice invalidity with nice message when using `TryIntoCheatingOrphanRule` implementations.


## `validations::url`

```rust
pub enum UrlInvalidity<S: Borrow<str>> { ... }
```

```rust
pub fn validated_url<S: Borrow<str>>(url: S) -> Result<Url, UrlInvalidity<S>> { ... }
```

```rust
pub fn validated_url_as_opt<S: Borrow<str>>(url: S) -> Result<Option<Url>, UrlInvalidity<S>> { ... }
```


## `validations::uuid`

```rust
pub enum InvalidBytesForUuid<'a> { ... }
```

```rust
pub fn validated_uuid_from_slice(slice: &[u8]) -> Result<Uuid, InvalidBytesForUuid<'_>> { ... }
```

```rust
pub fn validated_uuid_from_slice_as_opt(slice: &[u8]) -> Result<Option<Uuid>, InvalidBytesForUuid<'_>> { ... }
```

```rust
pub struct InvalidStrForUuid<T: Borrow<str>> { ... }
```

```rust
pub fn validated_uuid_from_str<T: Borrow<str>>(input: T) -> Result<Uuid, InvalidStrForUuid<T>> { ... }
```
