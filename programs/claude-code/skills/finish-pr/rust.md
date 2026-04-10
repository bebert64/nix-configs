## Rust checks

### Per-crate checks

Check whether a root `Cargo.toml` exists. If it doesn't, skip this section entirely.

If it does, this is a Rust workspace — from the changed file paths, determine which workspace crates have been modified by cross-referencing with the `[workspace] members` list. Only crates present there are subject to Cargo checks; ignore other changed files (e.g. TypeScript, config).

For each modified Rust crate, run the following commands **sequentially**. Stop at the first failure.

1. `cargo machete -p <crate_name>` — check for unused dependencies
2. `cargo clippy -p <crate_name>` — lints
3. `cargo test -p <crate_name>` — unit tests

### Autofix and verify

1. `make autofix` — formatting
2. Verify no files changed after autofix (`git diff --name-only`). If files changed, formatting was not correct before — report which files were modified.

### Whole-workspace checks

Run on the whole workspace (use a long timeout, e.g. ~15 minutes; full-repo checks are slow):

1. `cargo check`
2. `cargo check --tests`
