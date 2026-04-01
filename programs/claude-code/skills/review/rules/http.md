## HTTP API Code Guidelines

- **Destructure `Json`/`Query` handler inputs**: In HTTP handler functions, destructure `Json(...)` or `Query(...)` directly in the argument pattern (e.g. `Json(MyInput { field_a, field_b }): &Json<MyInput>`), unless the value is passed as-is to another function or contains a single field.
