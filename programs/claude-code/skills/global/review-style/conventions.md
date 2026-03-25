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

## Serde conventions (Rust)

- **Enums over correlated optional fields**: Deserialize correlated fields into an enum rather than separate optional fields. For `#[serde(untagged)]` enums, ensure payloads cannot accidentally match another variant.
- **`Vec<T>` with default** over `Option<Vec<T>>`: Use `#[serde(default)]` on `Vec<T>` unless the API explicitly distinguishes null/absent from empty.
