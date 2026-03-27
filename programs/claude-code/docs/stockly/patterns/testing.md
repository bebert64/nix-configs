# Testing Patterns

How tests are structured in the Stockly monorepo.

## Test Types

| Type | Location | Harness | Purpose |
|------|----------|---------|---------|
| Unit tests | `#[cfg(test)] mod tests` in `src/`, or `src/**/tests.rs` | `#[test]` / `cargo test` | Fast, isolated logic tests |
| Integration tests | `tests/*.rs` at crate root | `#[test]` / `cargo test` | Public API tests (separate compilation unit) |
| `tintes` binaries | `tintes/main.rs` + `[[bin]]` in `Cargo.toml` | `cargo run --bin <name>_tintes` | Env-backed smoke tests (not `#[test]` harness) |
| Post-deployment tests | `post_deployment_tests/` | `cargo test` | Run after deploy against live service |
| PostgreSQL function tests | `tunit_`-prefixed PL/pgSQL functions | `smake reset-database` | pgTAP assertions in DB |

## Unit Test Conventions

Tests live either inline or in a sibling `tests.rs`:

```rust
// In mod.rs:
#[cfg(test)]
mod tests;

// In tests.rs:
#[test]
fn test_single_purchases_shipping_for_action() {
    let bound_submissions = [(
        PurchasesSubmissionId::assume_exists(1),
        // ...
    )].into_iter().collect();

    assert_eq!(
        MessageBindings { /* ... */ }
            .ensured_coherent()
            .single_purchases_shipping_for_action()
            .map(|res| res.map(|pship| pship.id)),
        Ok(Some(PurchasesShippingId::assume_exists(11)))
    );
}
```

Inline `mod tests` is used for short test modules (<20 lines) or when tests need private access:

```rust
#[cfg(test)]
mod tests {
    use {super::*, crate::items::register::CompetitorPrice};

    mod check_min_history {
        use super::*;

        #[test]
        fn does_not_record_when_disabled() {
            // ...
            assert!(tracker.history_lines.is_empty());
        }
    }
}
```

## Naming

- **Descriptive snake_case**, scenario-oriented: `from_supplier_to_osa_no_ti`, `does_not_record_when_disabled`.
- Some tests use `test_` prefix (e.g., `test_single_purchases_shipping_for_action`) — the style rule says not to, but existing code is mixed. New tests should NOT use the `test_` prefix.

## Test Helpers

No single shared test utility crate. Patterns in use:

- **Per-module `mock_*` / `make_*` functions** in `tests.rs` for building test data:

```rust
fn mock_submissions(
    submissions: &BTreeMap<PurchasesSubmissionId, BTreeMap<PurchasesShippingId, BTreeSet<PurchaseId>>>,
) -> BTreeMap<PurchasesSubmissionId, PurchasesSubmission> {
    submissions.into_iter().map(|(submission_id, shippings)| {
        (*submission_id, PurchasesSubmission { id: *submission_id, /* ... */ })
    }).collect()
}
```

- **`test_helpers` feature flags** for exposing test-only APIs from production crates (e.g., `operations_location = { workspace = true, features = ["test_helpers"] }`)

- **Shared helpers** in library crates: `SerdeHelpers::test_helpers::assert_json_eq`, `pretty_assertions::assert_eq` re-exported in test prelude

- **`insta`** for snapshot testing (dev-dependency on several crates)

## `tintes` (Integration Smoke Tests)

Binary targets for manual or environment-backed testing. Not `#[test]` — they're standalone programs:

```toml
[[bin]]
doc = false
name = "deepl_sdk_tintes"
path = "tintes/main.rs"
```

```rust
fn main() {
    let client = Client::from_env().unwrap();
    println!("{:#?}", client.usage().unwrap());
    // ...
}
```

Some crates gate `tintes` behind a feature: `required-features = ["tintes"]`.

## Running Tests

```bash
cargo test --quiet -p <crate>        # Single crate
cargo test --quiet                    # All Rust tests (from repo root)
make tunits                           # All tests sequential (JS + Rust)
make ptunits                          # All tests parallel
```

Post-deployment tests run separately after deploy, not as part of regular `cargo test`.
