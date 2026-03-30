# Style Conventions Checklist

## Naming

**4-step naming method:**
1. Start with the full English descriptive sentence (e.g., `list_of_documents_that_we_will_ask_demand_to_send_us`)
2. Remove information already carried by the type and the path (modules, current function name). If nothing is left, the function should probably be named `perform`.
3. Simplify wording (e.g., `documents_to_ask_for`)
4. Cross-check: re-translate to English and confirm the name plus its surrounding context still convey the original meaning

- **No redundant module-name prefixes** -- enum, struct, and function names should not repeat the module name (e.g., `save::Recap` not `save::SaveRecap`). Exception: Ids should use the full concept name (e.g., `OrderLineCancellationId`) because they are often re-exported.
- **Do NOT prefix test functions** with `test_` -- the `#[test]` attribute and module path already convey it.
- **Do NOT prefix getters** with `get`. **Do prefix setters** with `set`.
- **Prefix boolean values** with `is_`, `has_`, etc.
- **Variable naming**: two ways -- by _how it was computed_ or by _what it will be used for_. Default to "how it was computed" -- when the computation changes, renaming propagation forces reviewing every usage site.
- **Function naming**: active voice for actions (`cancel_purchase`, `register_purchase_cancellation`). Computation-based for queries (`first_parcel_item_of_purchase`).
- **Struct naming**: the fully qualified name (path + struct name) conveys what object it represents. Fields convey properties. Do not introduce new concepts unless naming the set of properties directly would be unreasonably long.
- It is rare (~1%) that you should introduce new concepts when writing code. Use descriptive names referring to already-existing concepts.

## Comments

- **Comments explain WHY, never WHAT.** "What" comments bloat the file and actively decrease readability.
- Avoid over-specific comments that reference implementation details elsewhere -- they become misleading when that code changes. Keep doc comments self-contained.
- In edge-case comments, mention production examples (company names, dates, stats) to distinguish "actually happened" from "theoretical what-if".
- When refactoring, preserve comments that explain _why_ something is done (rationale).

## Code structure (Rust)

- **Inline single-use variables**: Do not introduce a variable used only once. Inline the expression at its usage site. Exception: keep if inlining would break the code. Applies to ALL code including tests.
- **Inline single-use functions**: Do not extract a private function called from exactly one place. Exception: genuinely reusable logic or trait implementations.
- **Module declaration**: No inline modules (except short tests <20 lines). Place all modules in separate files. `mod` declarations grouped together, alphabetically sorted, at the top.
- **Items ordering**: Mirror top-down reading order -- outermost to innermost. Input/Recap/Fail structs above the public function they serve, private helpers at the bottom ordered by first reference. All item definitions ordered by first reference, outermost first.
- **Code ordering**: Most relevant to least relevant (top to bottom). Local helpers at the bottom.
- **Prefer `match`** over `if let ... else` when both branches of an Option/Result are handled. `if let` without `else` is fine.

## Coding Preferences

### Naming

- **Encode type information in names when the type system can't**: If a value has important semantic meaning not captured by its type, include it in the name. Examples: `_json` suffix for JSON strings, `_eur` or `_currency` suffix for money amounts, `_alpha3` for country codes stored as strings. **Conversely**: when the type system DOES encode the constraint (e.g., `Alpha3`, `EuroableCurrency`), don't repeat it in the name.
- Always keep names semantically accurate and non-misleading (variables, functions, structs, fields). This applies to both newly introduced names and names in existing code being modified.

### Comments

- **Always document rationale for arbitrary values** (constants, timeouts, limits, etc.). Even if it's just "arbitrarily picked as a reasonable default" — future maintainers need to know whether a value was carefully calculated or just a starting point. Include trade-offs to help with tuning.

### Rust

- Always favor `to_owned()` over `to_string()` to get a `String` from an `&str` or `&String`. For `Cow<str> -> String`, use `into_owned()` instead.

## Coding Principles

### Performance

- **Optimize for the happy path** — the common case should be fast; edge cases can be slower.

### Tests

- First tests **must** cover primary use cases, not edge cases. Tests serve as documentation for how the code is intended to be used.
- Documentation and examples are code — they must be equally well thought out. To justify their presence, they must be a significant improvement over simply reading the code.

## Serde conventions (Rust)

- **Enums over correlated optional fields**: Deserialize correlated fields into an enum rather than separate optional fields. For `#[serde(untagged)]` enums, ensure payloads cannot accidentally match another variant.
- **`Vec<T>` with default** over `Option<Vec<T>>`: Use `#[serde(default)]` on `Vec<T>` unless the API explicitly distinguishes null/absent from empty.

## Rust Patterns

- **Imports grouped with `use { ... }` syntax**: All imports from the same crate/path must be grouped with braces. `use` and `pub use` from the same group must not be separated by a newline.
- **`don_error` wildcard import**: Always `use don_error::*;` — do not import specific items individually.
- **`Cargo.toml` `[package]` field ordering**: Fields must be alphabetically ordered: `authors`, `default-run` (if multiple bins), `edition` (currently `"2024"`), `name`, `publish` (`false`), `version` (`"1.0.0"`), `workspace`.
- **`Cargo.toml` `[features]`**: Entries must be alphabetically sorted and `snake_case` named.

## SQL Conventions

### Naming

- Field names, enum/type names, and variant names: `snake_case`.
- Boolean fields start with `has_`, `is_`, or `does_`.
- Timestamps end with `_at`. Dates end with `_date`. Months end with `_month`.
- Avoid bare `date`, `month`, `type`, `id`, `name` as column names — always prefix with what they identify (e.g., `deal_closed_at`, `order_type`), or access through a table alias.
- Cross-service FK columns: prefix with the service name.
- When migrating to a new field that replaces an old one, give the new field its intended final name and suffix the old field.
- History tables: name as `${table_name}_${column_name}_history`.

### Aliasing

- Table alias: first letter of each word (e.g., `ol` for `order_lines`, `dd` for `delivery_disputes`).

### Formatting

- Each selected column on its own row. Exception: `SELECT *` may be on one row.
- `DISTINCT` on the same row as `SELECT`.
- Fields listed before aggregates/window functions; grouping fields first.
- Standard SQL keywords and function names: `CAPITALIZED`. Custom function names: `snake_case`.
- Lines max 100 characters.
- Prefer `--` comments over `/* */`.

### Joins

- Join condition: `JOIN` table first, `FROM` table second in the `ON` clause.

### Comparisons

- Prefer `!=` over `<>` — more common across languages and reads as "not equal".

### Functions

- Simplify repetitive `CASE` statements where possible.
- Indent `CASE` statements: align `CASE` with `END`, and `WHEN` with `WHEN` and `ELSE`.

### Creating tables

- `id` should be the first column when present.
- Column declaration order: `"name" type nullability check`.
- Keep related columns close to each other.
