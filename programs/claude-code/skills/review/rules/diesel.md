## Diesel nullable left joins

When building a nullable struct from a left join, at least one selected column must come from the right table and be nullable (e.g. its primary key). Otherwise, expressions like `is_not_null()` or non-optional columns can make the tuple non-optional and the struct always `Some`, even when there is no matching row.

Include a column from the right table that is NULL when the row is missing (e.g. the right table `id`).

## Diesel alias for "latest row per group"

When you need "only the most recent row per group" without a window function, prefer `diesel::alias!` with a `NOT EXISTS (newer row)` subquery over filtering on a nullable status column (e.g. `closed_at IS NULL`):

```rust
diesel::alias!(schema::my_table as my_table_alias: MyTableAlias);

my_table::table
    .filter(dsl::not(dsl::exists(
        my_table_alias
            .filter(my_table_alias.field(my_table::group_key).eq(my_table::group_key))
            .filter(my_table_alias.field(my_table::created_at).gt(my_table::created_at)),
    )))
```

## Batch updates via `INSERT ... ON CONFLICT ... DO UPDATE`

When updating multiple rows with per-row values, use a single `insert_into(...).values(vec).on_conflict(...).do_update().set(...)` instead of looping individual `diesel::update` calls. This issues one SQL statement instead of N. Use `diesel::pg::upsert::excluded(column)` to reference the would-be-inserted value in the SET clause.

Postgres checks NOT NULL constraints _before_ reaching the `ON CONFLICT` clause, so all NOT NULL columns need a value in `.values(...)` even if the row already exists and the upsert will only update a subset. Use literal stubs with a comment:

```rust
diesel::insert_into(schema::my_table::table)
    .values(
        inputs.iter().map(|input| (
            schema::my_table::id.eq(input.id),
            schema::my_table::real_column.eq(input.real_value),
            // Stub: postgres checks NOT NULL before reaching ON CONFLICT
            schema::my_table::other_not_null_col.eq(1),
        )).collect::<Vec<_>>(),
    )
    .on_conflict(schema::my_table::id)
    .do_update()
    .set(schema::my_table::real_column.eq(excluded(schema::my_table::real_column)))
    .execute(conn)?;
```

## Prefer `load_iter` over `get_results().into_iter()`

When iterating over query results to collect into a `HashMap`, filter, or transform, use `.load_iter::<T, DefaultLoadingMode>(db)?.process_results(|iter| ...)` instead of `.get_results(db)?.into_iter()`. `load_iter` streams rows without allocating an intermediate `Vec`. `process_results` (from `itertools::Itertools`) unwraps the `Result` layer so you can work with a plain iterator inside the closure.

**Good:**

```rust
schema::my_table::table
    .select((MyId::as_select(), MyData::as_select()))
    .load_iter::<(MyId, MyData), DefaultLoadingMode>(db)?
    .process_results(|iter| iter.map(|(id, data)| (id, data)).collect::<HashMap<_, _>>())?
```

**Bad:**

```rust
schema::my_table::table
    .select((MyId::as_select(), MyData::as_select()))
    .get_results(db)?
    .into_iter()
    .map(|(id, data)| (id, data))
    .collect::<HashMap<_, _>>()
```

## Inline `Queryable`/`Selectable` structs for single-use queries

When a query result shape is used in exactly one function, define the `#[derive(Queryable, Selectable)]` struct inside the function body rather than at module scope:

```rust
fn load_data(conn: &mut PgConnection) -> InternalResult<Vec<...>> {
    #[derive(Queryable, Selectable)]
    #[diesel(table_name = my_table)]
    struct Row {
        id: MyId,
        name: String,
    }

    my_table::table
        .select(Row::as_select())
        .load::<Row>(conn)
}
```
