## Imports

- **Import ordering**: 4 sections separated by blank lines: (1) sub-modules, (2) relative (`super::`), (3) crate (`crate::`), (4) external (including other Stockly crates). Also applies to re-exports (`pub use`).

- **Imports grouped with `use { ... }` syntax**: All imports from the same crate/path must be grouped with braces. `use` and `pub use` from the same group must not be separated by a newline.

- **Wildcard import for `internal_error` or `don_error`**: Always `use internal_error::*;` or `use don_error::*;` — never import specific items individually.
