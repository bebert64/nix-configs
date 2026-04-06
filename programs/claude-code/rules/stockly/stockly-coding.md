---
paths:
  - "**/*.rs"
---

## `intl!` macro

- `intl!` takes the same args as `format!`, so never wrap `format!()` inside `intl!()` — use `intl!("...", args)` directly.

## Float comparisons

- **Always use `FloatExt` for float comparisons** (`lib/rust/FloatExt`). Never use `==` on floats directly — use `tolerant_eq`, `tolerant_ne`, `tolerant_gt`, `tolerant_lt`, etc. Floating point precision issues are real and cause subtle bugs.
- For `Option<f64>` comparisons, handle `(Some, Some)`, `(None, None)`, and mismatched cases explicitly.

## Strong typing for JSON

- For JSON object fields in proto (represented as `string`), use `validation::SerdeJsonMap` in clean Rust structs.
- Validation and parsing happens in the `TryFrom` conversion.

## API/RPC design

- When designing RPC responses, prefer a response object with fields for different outcomes over relying on status codes. This makes it easier to modify and extend in the future.
- Don't use `oneof` in protobuf messages — use optional fields with validation in the handler instead.
