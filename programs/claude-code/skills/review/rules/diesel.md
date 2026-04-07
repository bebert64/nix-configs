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
