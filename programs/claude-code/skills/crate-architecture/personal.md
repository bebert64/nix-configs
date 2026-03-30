# Personal Monorepo — Crate Architecture

> **Scope**: Personal monorepo (`~/code/Main`).

---

## 1. Crate taxonomy

| Category            | Location pattern           | Type                              | Example                                            |
| ------------------- | -------------------------- | --------------------------------- | -------------------------------------------------- |
| **Standalone app**  | `<AppName>/`               | bin                               | `Backup`, `VideoManager`, `Shortcuts`              |
| **Tauri app**       | `<project>/{Front,Tauri}/` | lib (Leptos) + cdylib+bin (Tauri) | `escapucina/Front`, `escapucina/Tauri`             |
| **Shared library**  | `libs/<Name>/`             | lib                               | `ConfigHelpers`, `DieselHelpers`, `CommandHelpers` |
| **Grouped library** | `libs/<name>/<SubCrate>/`  | lib                               | `libs/don_error/Crate`, `libs/don_error/Derive`    |
| **SDK**             | `sdks/<Name>Sdk/`          | lib                               | `JellyfinSdk`, `StashSdk`, `RadioFranceSdk`        |

> **Deprecated pattern**: `comics`, `photo_dedup`, `set` use separate `Back/`+`Front/`+`Core/` sub-crates (Yew-era). Don't reproduce — Leptos handles front and back in one crate. The only reason to split into sub-crates is Tauri (which needs its own shell crate).

---

## 2. Naming conventions

### Directory names

- **PascalCase** for crate directories: `VideoManager`, `DieselHelpers`, `JellyfinSdk`.
- **snake_case** for grouped lib parent dirs and Tauri project dirs: `don_error`, `escapucina`.
- Sub-crate dirs within a Tauri project: `Front`, `Tauri`.

### Cargo package names

**All package names use kebab-case** — this is the Linux standard for package/binary names. Cargo auto-converts hyphens to underscores for Rust imports (`use my_crate`).

| Category       | Convention | Examples                                        |
| -------------- | ---------- | ----------------------------------------------- |
| Standalone app | kebab-case | `guitar-tutorials`, `video-manager`, `backup`   |
| Tauri project  | kebab-case | `escapucina`, `escapucina-tauri`                |
| Library        | snake_case | `config_helpers`, `diesel_helpers`, `don_error` |
| SDK            | snake_case | `jellyfin_sdk`, `stash_sdk`, `radio_france_sdk` |

---

## 3. Common files per crate type

### Always present

| File         | Notes                                          |
| ------------ | ---------------------------------------------- |
| `Cargo.toml` | See §4 for structure                           |
| `src/`       | `main.rs` for binaries, `lib.rs` for libraries |

### Conditionally present

| File/Dir                       | When                                                                                                              |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `<app-name>.nix`               | Standalone apps that are deployed/installed via Nix (e.g. `backup.nix`, `shortcuts.nix`). Not all apps have one. |
| `migrations/`                  | Crates using diesel with their own database (`DeezerDl`, `Shortcuts`)                                             |
| `Makefile`                     | Frontends and Tauri apps. Includes from `mkFiles/` (e.g. `trunk.mk`, `postgres.mk`, `tauri.mk`)                   |
| `.vscode/settings.json`        | Always. Generate by running `cargo run` from `dev_tools/SetupRustAnalyzerOnlyCompileCrate/`                       |
| `index.html`                   | Frontend crates (Leptos with Trunk)                                                                               |
| `assets/`                      | Frontend crates — static assets                                                                                   |
| `graphql/` or `schema.graphql` | SDKs that use GraphQL (`StashSdk`, `RadioFranceSdk`)                                                              |
| `build.rs`                     | Tauri crates (Tauri codegen)                                                                                      |

---

## 4. Cargo.toml template

```toml
[package]
name = "my-app"
version = "0.1.0"
edition = "2024"

[dependencies]
# Use workspace dependencies:
# some_dep = { workspace = true }
# some_dep = { workspace = true, features = ["feature_name"] }
```

Key points:

- `edition = "2024"` (current standard).
- Binary crates use kebab-case names; library crates use snake_case.
- Use `workspace = true` dependencies where available — declared in root `Cargo.toml`'s `[workspace.dependencies]`.

---

## 5. Scaffolding checklist

1. **Determine the category** (§1) and correct location
2. **Create the directory** in PascalCase
3. **Create required files**: `Cargo.toml`, `src/main.rs` or `src/lib.rs`
4. **If it uses diesel**: create `migrations/` and add diesel deps
5. **If it's a Leptos frontend**: create `index.html`, `assets/`, `Makefile` (include appropriate `mkFiles/*.mk`)
6. **If it's a Tauri app**: create `Front/` (Leptos) and `Tauri/` sub-crates, with `build.rs` in `Tauri/`
7. **If it's a Nix-deployed app**: create `<app-name>.nix`
8. **Register in workspace** (see main skill)
9. **Generate `.vscode/settings.json`**: `cd dev_tools/SetupRustAnalyzerOnlyCompileCrate && cargo run`
10. **Verify** (see main skill)
