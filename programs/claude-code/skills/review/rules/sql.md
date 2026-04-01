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
