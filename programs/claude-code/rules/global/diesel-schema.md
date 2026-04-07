# Diesel Schema Reference

When writing, modifying, or reviewing SQL queries, **always read `src/schema.rs`** (it can be either under Schema or Service) first to verify:

- Table and column names exist and are spelled correctly
- Column types match the values being inserted/updated/filtered
- Join relationships use valid foreign key columns

Do NOT guess table or column names — always confirm against the schema file.

The schema does not include:

- Postgresql functions
- Triggers and checks
- Cardinality of tables

To check them or estimate them you should query the database.

## Selectable Macro

Prefer using the Diesel `Selectable` derive macro with `.select(MyStruct::as_select())` instead of manually listing columns in `.select((...))` tuples. This keeps queries in sync with the struct definition and avoids mismatches when fields are added or reordered.

**Good** — using `Selectable`:

```rust
#[derive(Queryable, Selectable)]
#[diesel(table_name = users)]
struct User {
	id: i32,
	name: String,
	email: String,
}

users::table
	.select(User::as_select())
	.load::<User>(conn)
```

**Bad** — manually listing columns:

```rust
users::table
	.select((users::id, users::name, users::email))
	.load::<(i32, String, String)>(conn)
```

## Migrations

When creating diesel migrations, do **NOT** generate `down.sql` files. Only create the `up.sql` file. Down migrations are not used in this project.

## ON CONFLICT upserts and NOT NULL stubs

Postgres checks NOT NULL constraints _before_ reaching the `ON CONFLICT` clause, so all NOT NULL columns need a value in the `.values(...)` even if the row already exists and the upsert will only update a subset. Use literal stubs with a comment:

```rust
diesel::insert_into(schema::my_table::table)
    .values((
        schema::my_table::id.eq(target_id),
        schema::my_table::real_column.eq(real_value),
        // Stub: postgres checks NOT NULL before reaching ON CONFLICT
        schema::my_table::other_not_null_col.eq(1),
    ))
    .on_conflict(schema::my_table::id)
    .do_update()
    .set(schema::my_table::real_column.eq(real_value))
    .execute(conn)?;
```
