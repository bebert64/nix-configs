---
paths:
  - "**/*.sql"
  - "**/migrations/**"
---

## Naming

- Timestamps must always be stored as `timestamptz` in UTC.
- Month columns must be truncated to a date format.
- Do not use acronyms if the column name is under 64 characters. If it exceeds 64 characters, abbreviate and add a `COMMENT ON` statement with the full unabbreviated name.

## Joins

- Always explicit: `INNER JOIN`, `LEFT JOIN`, etc. Never use implicit joins. Never bare `JOIN` (it defaults to `INNER` but isn't explicit).

## WHERE

- Filter with `WHERE` before `HAVING`.
- Avoid functions on columns in `WHERE` clauses — they prevent index usage.
- Prefer `EXISTS` over `IN` (and `NOT EXISTS` over `NOT IN`).

## Comparisons

- For nullable values: prefer `IS DISTINCT FROM` over `!=`, because `NULL` trumps anything with `=`/`!=`.
- In triggers comparing `OLD` to `NEW`: always use `IS DISTINCT FROM` — columns may become nullable in the future.
- The underscore `_` in `LIKE` matches any single character. To match a literal underscore, escape as `\_`.

## Functions

- For every new function `my_function`, add a unit test function `tunit_my_function` using pgTAP `IS(computed, expected, description)` assertions.
- Use `plpgsql` language over `sql` (even though the syntax is more verbose) for consistency and better error handling.
- Prefer explicit date functions over `date_part` over `EXTRACT`.

## Indexes

- Add an index on columns containing a foreign key to another table or used for filtering/joining rows.

## History/cache pattern

When working on a table representing a set where you need to track changes, create two separate tables:

- **Cache table**: for efficient querying of current set members.
- **History table**: for auditing — records historical values, who changed it, when, and why.

The history table should always include: the set member identifier, a reason field, the change value (e.g., `is_banned`), `created_by`, and `created_at`. PostgreSQL triggers keep the cache consistent when rows are inserted into the history table. Any failed trigger should cancel the transaction and revert all changes.
