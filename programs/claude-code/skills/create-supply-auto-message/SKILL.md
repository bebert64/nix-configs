---
name: create-supply-auto-message
description: >-
  Drafts a new supply-side (supplier) auto-message template (English only)
  for the operations service. Use when the user asks to create, draft, or write
  a new automated message template for supply / suppliers / purchases. Requires
  the ContextualData struct definition and a brief description of the message's
  purpose.
---

# Create Supply Auto-Message Template

Draft an English message template body (and subject) for a new supply-side
(supplier-facing) automated message in the operations service, using Tera syntax.

## Required inputs

Before starting, ensure you have **both** of the following. If either is
missing, ask the user before proceeding:

1. **Brief description** of what the message is about (e.g. "notify the
   supplier that a delivery dispute has been opened for one of their purchases").
2. **ContextualData** — the Rust struct (or macro keyword) that defines the
   trigger-specific data available in the template. The user should paste it
   directly.

## Workflow

### 1. Gather context: existing messages

Query the operations database for the **10 most recent active English
supply-side message templates** to use as style / tone reference:

```sql
SELECT DISTINCT mt.id, mt.designation,
       mtlv.id AS version_id, mtlv.subject, mtlv.body
FROM templated_supplier_messages tsm
JOIN message_template_language_versions mtlv
  ON mtlv.id = tsm.message_template_language_version_id
JOIN message_templates mt
  ON mt.id = mtlv.message_template_id
WHERE mtlv.language_alpha2 = 'EN'
  AND mtlv.deactivated_at IS NULL
ORDER BY mtlv.id DESC
LIMIT 10;
```

Read through these examples to understand the current tone, structure, common
patterns (greetings, sign-offs, variable usage), and formatting conventions.

### 2. Gather context: available template variables

Every supply message template has access to two categories of data:

#### A. Always-injected data (Supplier)

These variables are inserted into the Tera context for **every** supply message,
regardless of trigger. The base context is built in:

> **`operations/Service/src/supply/messages/templates/mod.rs`**

The `Supplier` struct (defined in `operations/Service/src/supply/messages/mod.rs`)
is inserted at root level. Available top-level Tera variables:

- `supplier.id` — the supplier's retailer ID (`SupplierId`)
- `supplier.username` — the supplier's username (`String`)
- `supplier.email` — the supplier's email (`Option<String>`)
- `template_language` — the language code (e.g. `"EN"`)

**Self-healing note:** If the `Supplier` struct or `build_base_context` has moved
or been renamed, search the codebase for `fn build_base_context` in the supply
messages module to find the current location, then **update this skill file**
with the correct path so future invocations don't waste time searching.

#### B. Trigger-specific data (contextual_data)

Accessed in templates as `contextual_data.<field>`. The structure depends on
what the user provides (see [Required inputs](#required-inputs)).

#### C. Registered Tera functions (from `base_tera/mod.rs`)

Defined in `operations/Service/src/supply/messages/templates/base_tera/mod.rs`.

Available in templates via `{{ function_name(args) }}`:

- `purchase_identification(lang, purchase)` — formats a human-readable purchase
  identification string. The `purchase` argument must be a serialized
  `PurchaseDataForSupplier` object (typically iterated from
  `contextual_data.purchases_data_for_supplier`). Handles submission/shipping
  IDs, titles, EAN, and internal reference. Supports all languages.

#### D. Registered includable templates

- `purchases_identification` — iterates over
  `contextual_data.purchases_data_for_supplier` and renders each purchase using
  `purchase_identification()`. Use with `{% include "purchases_identification" %}`
  when the message needs to list affected purchases.

### 3. Draft the message

Write an English template body (and subject line) using Tera syntax that:

- **Matches the tone and style** of the existing messages from step 1.
- **Uses only variables that actually exist** in the base context (step 2A)
  and the contextual data (step 2B). Cross-check every `{{ }}` and `{% %}`
  expression against the available data.
- **Uses `{% include "purchases_identification" %}`** when the message needs to
  reference specific purchases (most supply messages do).
- Keeps the subject concise (max ~80 chars) and informative.
- Uses proper Tera control flow (`{% if %}`, `{% for %}`) for optional or
  list-based data.
- Note: supply messages are **supplier-facing** (B2B tone), not consumer-facing.
  There is no `consumer_introduction` equivalent — address the supplier directly.

### 4. Validate

Before presenting the draft:

1. **Syntax check** — verify all `{{ }}`, `{% %}` blocks are properly balanced.
   All `{% if %}` have `{% endif %}`, all `{% for %}` have `{% endfor %}`.
2. **Variable check** — every variable path used in the template must exist in
   either the always-injected data or the contextual data. Flag any that don't.
3. **Function check** — any Tera function calls must use registered functions
   from step 2C with correct argument names.

### 5. Present the draft

Show the user:

- The **subject** and **body** of the English template.
- A summary of which contextual_data fields were used.
- Any assumptions made.
- Any fields from contextual_data that were **not** used, with a note on
  whether they could be useful.
