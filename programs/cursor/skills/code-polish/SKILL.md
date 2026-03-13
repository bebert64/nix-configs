---
name: code-polish
description: Post-implementation review for naming, comments, and code organization. Use when the user asks to polish, review naming, review style, or check code conventions on recently changed files.
---

# Code Polish — Style & Naming Conventions

## Comments

- Avoid over-specific comments that reference implementation details elsewhere in the codebase — they become misleading when that code changes. Keep doc comments self-contained or general.
- When refactoring, preserve comments that explain _why_ something is done (rationale). Important context should survive refactoring.
- In comments about edge cases, mention production examples (company names, dates, stats) to distinguish "actually happened" from "theoretical what-if". This enables reproduction and gives future maintainers confidence.

## Naming — general

- **Proactively flag naming issues** — naming is worth fighting for. Discuss naming choices together, don't wait to be asked.
- It's rare (~1%) that you should introduce new concepts when writing code. Code should use descriptive names that refer to already-existing concepts, making it readable without memorizing arbitrary definitions.
- **Avoid redundant module-name prefixes** — enum, struct, and function names should not repeat the module name (e.g., `save::Recap` not `save::SaveRecap`).

## 4-step naming method

1. Start with the full English **descriptive sentence** (e.g., `list_of_documents_that_we_will_ask_demand_to_send_us`).
2. **Remove** information already carried by the type and the path (modules, current function name). If nothing is left, the function should probably be named `perform`.
3. **Simplify** wording (e.g., `documents_to_ask_for`).
4. **Cross-check**: re-translate to English and confirm the name plus its surrounding context still convey the original meaning.

## Variable naming

Two ways to name a variable: by _how it was computed_ (what it contains) or by _what it will be used for_. Both can be correct, but one usually makes the code clearer depending on context. **Default to "how it was computed"** — when the computation changes, renaming propagation forces reviewing every usage site for correctness.

## Function naming

- Functions that take action: **active voice** (`cancel_purchase`, `register_purchase_cancellation`).
- Functions that query or compute: name reflects exactly **how the value is obtained** (`first_parcel_item_of_purchase`).
- Avoid functions that are only called once — inline them unless extraction meaningfully improves readability.
- **Do not prefix test functions** with `test_` — the `#[test]` attribute and module path already convey it.
- **Do not prefix getters** with `get`. **Do prefix setters** with `set`.

## Struct naming

- The fully qualified name (path + struct name) conveys what object the struct represents. Its fields convey properties of that object.
- Naming should force review when the struct widens (fields removed or semantics broadened) — renaming everywhere catches places depending on the old guarantees.
- Don't introduce a new concept unless naming the set of properties directly would be unreasonably long. When you do, document the concept clearly.

## Code ordering

- Order code blocks from most relevant to least relevant (top to bottom). Local helpers should be at the bottom. Unlike C, we're free from declaration-before-use constraints.

---

## Standalone invocation

When this skill is invoked directly (not as part of another command), follow this procedure:

1. Determine which files to review: run `git diff --name-only $(git merge-base HEAD master)...HEAD` to get files changed on the current branch. Also include uncommitted changes via `git diff --name-only`. Merge both lists, deduplicate, and filter to code files only (e.g. `.rs`, `.sql`, `.ts`, `.py` — skip generated files, lockfiles, etc.).
2. Read each file (or the relevant diff hunks).
3. Apply the conventions above and produce a list of **concrete suggestions**, grouped by file:
   - File path and line number (or range)
   - Current name / comment / ordering issue
   - Proposed change
   - Which convention it violates (reference the section name)
4. **Do NOT auto-apply changes.** Present the suggestions for the user to accept or reject.
5. If a file has no issues, skip it silently.
