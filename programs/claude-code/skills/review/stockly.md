# Additional Stockly Rust style checks

- **Prefer `sort_helpers::Sorted`** trait over `sort`/`sort_unstable` on mutable variables.

- **`intl!` message wording**: Sentry aggregates events by title — variable parts (IDs, counts, etc.) break aggregation. Put variable details in parentheses, which are excluded from aggregation. E.g. `"Email has too many attachments ({count}, limit is {max})"` aggregates on "Email has too many attachments" while keeping details visible.
