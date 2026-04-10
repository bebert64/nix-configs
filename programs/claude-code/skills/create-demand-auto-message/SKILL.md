---
name: create-demand-auto-message
description: >-
  Drafts a new demand-side (order/consumer) auto-message template (English only)
  for the operations service. Use when the user asks to create, draft, or write
  a new automated message template for demand / orders / consumers. Requires the
  ContextualData struct definition and a brief description of the message's
  purpose.
---

# Create Demand Auto-Message Template

Draft an English message template body (and subject) for a new demand-side
(order/consumer) automated message in the operations service, using Tera syntax.

## Required inputs

Before starting, ensure you have **both** of the following. If either is
missing, ask the user before proceeding:

1. **Brief description** of what the message is about (e.g. "inform the
   consumer that their incomplete delivery claim has been accepted and a refund
   is on the way").
2. **ContextualData** — the Rust struct (or macro keyword) that defines the
   trigger-specific data available in the template. The user should paste it
   directly.

## Workflow

### 1. Gather context: existing messages

Query the operations database for the **10 most recent active English
demand-side message templates** to use as style / tone reference:

```sql
SELECT DISTINCT mt.id, mt.designation,
       mtlv.id AS version_id, mtlv.subject, mtlv.body
FROM templated_order_messages tom
JOIN message_template_language_versions mtlv
  ON mtlv.id = tom.message_template_language_version_id
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

Every message template has access to two categories of data:

#### A. Always-injected data (RenderingContext)

These variables are inserted into the Tera context for **every** demand message,
regardless of trigger. Read the `RenderingContext` struct and all its nested
types (Demander, RetailerGroup, OrderOwner, Order, OrderShipping, etc.) in:

> **`operations/Service/src/demand/messages/templates/structs.rs`**

The top-level Tera variables match the fields of `RenderingContext`, plus
`template_language` (the language code, e.g. `"EN"`).

**Self-healing note:** If `structs.rs` has moved or `RenderingContext` has been
renamed, search the codebase for `struct RenderingContext` to find the current
location, then **update this skill file** with the correct path so future
invocations don't waste time searching.

#### B. Trigger-specific data (contextual_data)

Accessed in templates as `contextual_data.<field>`. The structure depends on
what the user provides (see [Required inputs](#required-inputs)).

#### C. Registered Tera functions (from `base_tera.rs`)

Available in templates via `{{ function_name(args) }}`:

- `order_line_by_id(order_line_id, order)` — returns a single order line object
- `order_line_by_cancellation_id(order_line_cancellation_id, order)` — returns a single order line by its cancellation id
- `list_order_lines_by_ids(order_line_ids, order, lang?)` — returns `[{title, count}]`

#### D. Registered includable templates

- `consumer_introduction` (and language-suffixed variants like `consumer_introduction_fr`) — renders a greeting using `person_greetings()`

### 3. Draft the message

Write an English template body (and subject line) using Tera syntax that:

- **Matches the tone and style** of the existing messages from step 1.
- **Uses only variables that actually exist** in the rendering context (step 2A)
  and the contextual data (step 2B). Cross-check every `{{ }}` and `{% %}`
  expression against the available data.
- **Uses `{% include "consumer_introduction" %}`** at the top for the greeting
  when this is a consumer-facing message.
- Keeps the subject concise (max ~80 chars) and informative.
- Uses proper Tera control flow (`{% if %}`, `{% for %}`) for optional or
  list-based data.

#### Writing rules

- **Answer first**: if the message contains any requests or questions, place them at the very top.
- **Be concise but precise**: say exactly what's needed, nothing more.
- **Avoid direct instructions**: don't tell the consumer what to do in imperative form.
- **Frame rights as solutions, not constraints**: instead of "You have 14 days to notify us", say "If you have an issue, you can notify us until xx/xx (12 days)".
- **Show empathy**: acknowledge the consumer's situation where relevant.
- **Product references**: if the order has only 1 article, do not mention article names, product names, or EAN — refer to it as "Your order" only.
- **Use emojis instead of bullet points** for lists.
- **Add at most 2 emojis** to the message to make it warmer — not more.
- **Tracking URL**: when sharing a link to track the order:
  - Non-problematic case (e.g. standard shipping update): share the **consumer backoffice URL**.
  - Problematic case (e.g. delivery issue, complaint): share the **tracking URL** directly.

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
- Any assumptions made (e.g. "assumed this is consumer-facing so I used
  `consumer_introduction`").
- Any fields from contextual_data that were **not** used, with a note on
  whether they could be useful.
