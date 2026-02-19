# final-test

run this sequence on all modified crates:

1. `cargo machete` - check for unused dependencies
2. `cargo clippy` - lints
3. `make autofix` - formatting
4. `cargo test` - unit tests
5. Then on the whole workspace: `cargo check` and `cargo check --tests` (use a long timeout, e.g. ~15 minutes; full-repo checks are slow)

- Verify no files changed after autofix (formatting was already correct)
- Generate PR title/description from template at the end: fill in everything you can (especially "What it does", inferred from branch name, modified files, and context); only leave placeholders for what you truly don't know (e.g. ticket URL, commit SHA)

