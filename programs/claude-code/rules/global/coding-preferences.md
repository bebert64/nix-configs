## Comments

- **Comments explain WHY, never WHAT.** Only add a comment when it explains _why_ the code does something. Never comment _what_ the code does — reading the code itself should always be sufficient. "What" comments bloat the file and actively decrease readability.

## Naming

- Always keep names semantically accurate and non-misleading (variables, functions, structs, fields). This applies to both newly introduced names and names in existing code being modified. Misleading names cause bugs, waste time, and make refactoring dangerous.
- **Encode type information in names when the type system can't**: If a value has important semantic meaning not captured by its type, include it in the name. Examples: `_json` suffix for JSON strings, `_eur` or `_currency` suffix for money amounts, `_alpha3` for country codes stored as strings. **Conversely**: when the type system DOES encode the constraint (e.g., `Alpha3`, `EuroableCurrency`), don't repeat it in the name.

## Code organization

- **Separation of Concerns**: Each function should have a single responsibility. E.g., `build_context` is responsible for the full shape of the context — callers shouldn't need to mutate it after.

## Design

- Avoid overkill genericity — use concrete types when a function is only used with one type.
- **Always document rationale for arbitrary values** (constants, timeouts, limits, etc.). Even if it's just "arbitrarily picked as a reasonable default" — future maintainers need to know whether a value was carefully calculated or just a starting point. Include trade-offs to help with tuning.
- **YAGNI (You Ain't Gonna Need It)** — don't build features "just in case". Ship simple, add complexity only when there's a real need. Avoids wasted effort, maintenance burden, and unnecessary complexity.

## Rust-specific

- Always favor `to_owned()` over `to_string()` to get a String from an `&str` or `&String`. For `Cow<str> -> String`, use `into_owned()` instead.
