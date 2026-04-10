# Naming

- **Encode type information in names when the type system can't**: If a value has important semantic meaning not captured by its type, include it in the name. Examples: `_json` suffix for JSON strings, `_eur` or `_currency` suffix for money amounts, `_alpha3` for country codes stored as strings. **Conversely**: when the type system DOES encode the constraint (e.g., `Alpha3`, `EuroableCurrency`), don't repeat it in the name.
- Always keep names semantically accurate and non-misleading (variables, functions, structs, fields). This applies to both newly introduced names and names in existing code being modified.

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
- **Full concept names over abbreviations**: Prefer full concept names in identifiers (struct fields, DB columns, RPC names), even when longer. Abbreviations are acceptable only when universally understood in context (e.g., `id`, `url`, `db`). Exception: DB identifiers near PostgreSQL's 63-char limit — abbreviate and add a `COMMENT ON` with the full name.
