# Stockly Monorepo — Crate Architecture

> **Scope**: Stockly monorepo (`~/Stockly/Main`).

After scaffolding, register the crate in the Cargo workspace (Rust) or — for Node — no registration needed (`pnpm-workspace.yaml` auto-discovers via `**` globs).

---

## 1. Crate taxonomy

| Category | Location pattern | `stockly-package.json` type | Has `scd/` | Deployable |
|----------|-----------------|----------------------------|-----------|------------|
| **Main Service** | `<service>/Service/` | `unit` | Yes | Yes |
| **Schema** | `<service>/Schema/` | `library` | No | No |
| **Service sibling** (Core, Helpers, Cli…) | `<service>/<Name>/` | `library` | Only if deployable (e.g. HistoryFlush) | Rare |
| **Internal sub-crate** | `<service>/Service/src/<path>/<Name>/` | `library` | No | No |
| **Rust library** | `lib/rust/<Name>/` | `library` | No | No |
| **Rust library (grouped)** | `lib/rust/<group>/<Name>/` | `library` | No | No |
| **Node library** | `lib/node/<Name>/` | `library` (`typescript`) | No | No |
| **Integration deployable** (Importer, ApiConnector, Exporter) | `integrations/<retailer>/[variant/]<Type>/` | `unit` | Yes | Yes |
| **Integration library** (Sdk, Core) | `integrations/<retailer>/lib/<Name>/` | `library` | No | No |
| **Proto crate** | `<service>/Service/src/grpc/<svc>/<Name>/` | `library` | No | No |

---

## 2. Naming conventions

### Directory names

- **PascalCase** for crate directories: `Service`, `Schema`, `Core`, `DieselHelpers`, `Claims`.
- **snake_case** for grouped lib parent dirs: `grpc_helpers`, `rate_limiting`, `address_cleaning`.
- **kebab-case** for integration retailer dirs: `amazon`, `ingram-micro`, `zona-indoor`.

### Cargo package names

All snake_case. Pattern depends on category:

| Category | Pattern | Example |
|----------|---------|---------|
| Main Service | `<service>` | `operations`, `stocks`, `backoffice` |
| Schema | `<service>_schema` | `operations_schema` |
| Service sibling | `<service>_<name>` | `operations_core`, `invoices_cli` |
| Internal sub-crate | `<service>_<name>` | `operations_claims`, `stocks_answers` |
| Rust library | `<name>` | `diesel_helpers`, `axum_helpers` |
| Grouped Rust library | `<group>_<name>` | `grpc_helpers_core`, `rate_limiting_fixed_window` |
| Integration deployable | `integrations_<retailer>_<type>` | `integrations_amazon_importer` |
| Integration library | `integrations_<retailer>_<name>` | `integrations_amazon_sdk` |
| Proto crate | `<service>_proto_<name>` | `operations_proto_admin` |

### Node package names

`@stockly/<kebab-case>` (e.g. `@stockly/grpc-helpers`, `@stockly/task-tracker-sdk`).

---

## 3. Common files per crate type

### Always present (all Rust crates)

| File | Notes |
|------|-------|
| `Cargo.toml` | See §4 for template |
| `src/` | `lib.rs` for libraries, `main.rs` for binaries |
| `Makefile` | Usually just `include $(shell git rev-parse --show-toplevel)/mkFiles/packages/rust.mk` |
| `stockly-package.json` | See §5 |

### Conditionally present

| File/Dir | When |
|----------|------|
| `scd/` | Deployable crates (Services, Importers, ApiConnectors, Exporters, some standalone binaries like HistoryFlush) |
| `environment.json` | Deployable crates, plus some libraries that need env vars at test/build time |
| `environment.client.json` | Main Services that expose a client |
| `environment.http_client.json` | Services that expose an HTTP client |
| `environment.grpc_client.json` | Services that expose a gRPC client |
| `migrations/` | Schema crates (diesel migrations). Rare: directly in a Service if it owns its own schema (e.g. backoffice, Buckets) |
| `diesel.toml` | Schema crates — usually a symlink to `../../diesel.toml` (root). Custom only when multiple schemas (e.g. stocks) |
| `schema.patch` | Schema crates — post-processing for `diesel print-schema` output |
| `build.rs` | Proto crates (codegen from `.proto`), HttpToGrpc crates. Rare otherwise. |
| `post_deployment_tests/` | Some main Services (operations, stocks) |
| `tests/` | Optional for any crate |
| `README.md` | Common but not required |
| `.gitignore` | Main Services and Schema crates |

### scd/ directory contents

For main services:
- `Makefile` — always; sets `UNIT_NAME`, `PORT`, includes `mkFiles/scd/rust.mk`
- `dev.mk`, `prod.mk`, `ci.mk` — deploy-type-specific overrides
- `default_data.sql` — optional seed data

For integration importers:
- `Makefile` — sets `UNIT_NAME`, `AWS_SCHEDULE_EXPRESSION`, includes `mkFiles/scd/importers/unit.mk`
- Usually no `dev.mk`/`prod.mk`/`ci.mk`

---

## 4. Cargo.toml template

```toml
[package]
name = "<package_name>"
version = "0.1.0"
edition = "2024"
publish = false

[lints]
workspace = true

[dependencies]
# Use workspace dependencies:
# some_dep = { workspace = true }
# some_dep = { workspace = true, features = ["feature_name"] }

[dev-dependencies]
```

Key points:
- `publish = false` always.
- `[lints] workspace = true` always.
- `workspace` field: relative path to repo root (e.g. `workspace = "../.."` for `<service>/Service/`).
- Prefer `workspace = true` dependencies declared in the root `Cargo.toml`'s `[workspace.dependencies]`. Add new workspace deps there if the crate is used from multiple places.
- Proto crates have `[build-dependencies]` with `grpc_helpers_codegen`.

---

## 5. stockly-package.json template

```json
{
	"type": "<unit_or_library>",
	"language": "<rust_or_typescript>"
}
```

- `type`: `"unit"` for deployable binaries, `"library"` for everything else.
- `language`: `"rust"`, `"typescript"`, `"python"`, or `"none"`.
- Tabs for indentation.

---

## 6. Scaffolding checklist

1. **Determine the category** (§1) and correct location
2. **Create the directory** with the right casing (PascalCase for crate dirs)
3. **Create required files**: `Cargo.toml`, `src/lib.rs` or `src/main.rs`, `Makefile`, `stockly-package.json`
4. **If deployable**: create `scd/Makefile` (and optionally `scd/dev.mk`, `scd/prod.mk`, `scd/ci.mk`), `environment.json`
5. **If Schema crate**: create `migrations/`, symlink `diesel.toml -> ../../diesel.toml`, create `src/schema.rs`
6. **If proto crate**: create `build.rs` with `grpc_helpers_codegen::proto_crate(...)`, place `.proto` file in parent dir
7. **Register in workspace** (see main skill)
8. **Verify** (see main skill)
