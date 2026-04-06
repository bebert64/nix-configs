## Diesel nullable left joins

When building a nullable struct from a left join, at least one selected column must come from the right table and be nullable (e.g. its primary key). Otherwise, expressions like `is_not_null()` or non-optional columns can make the tuple non-optional and the struct always `Some`, even when there is no matching row.

Include a column from the right table that is NULL when the row is missing (e.g. the right table `id`).
