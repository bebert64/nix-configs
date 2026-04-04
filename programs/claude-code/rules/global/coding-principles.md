## No silent fail

Never silently drop errors or skip items. Always report/propagate errors — never `filter_map` away missing required data. If something is expected to be present, treat its absence as an error, not a filter condition.

## Compiler errors

When the compiler highlights an error, first understand _why_ the type/value is what it is, then choose the _correct_ fix. Never make an arbitrary change just to make it compile.

## Make invalid states unrepresentable

- Use enums instead of correlated optional fields.
- Map to a more fitting representation as soon as you load data from an external source (DB, API, proto).

## Performance

- **Batch queries** instead of looping with individual calls.
- **Filter closest to the data source** — SQL `WHERE` clauses are cheaper than application-side filtering.
