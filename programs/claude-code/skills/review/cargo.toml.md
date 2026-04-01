## Cargo.toml conventions

- **`Cargo.toml` `[package]` field ordering**: Fields must be alphabetically ordered: `authors`, `default-run` (if multiple bins), `edition` (currently `"2024"`), `name`, `publish` (`false`), `version` (`"1.0.0"`), `workspace`.
- **`Cargo.toml` `[features]`**: Entries must be alphabetically sorted and `snake_case` named.
