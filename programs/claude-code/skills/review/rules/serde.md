## Serde conventions

- **Enums over correlated optional fields**: Deserialize correlated fields into an enum rather than separate optional fields. For `#[serde(untagged)]` enums, ensure payloads cannot accidentally match another variant.
- **`Vec<T>` with default** over `Option<Vec<T>>`: Use `#[serde(default)]` on `Vec<T>` unless the API explicitly distinguishes null/absent from empty.
