---
description: Crate architecture and scaffolding patterns for monorepos. Use when creating a new crate, library, or package, or when asked about crate layout or where to place new code.
---

# Crate Architecture

When creating a new crate, follow the patterns below.

**Ask when in doubt.** Deciding the right category and location can be ambiguous — standalone vs sub-crate, library vs deployable, etc. If it's not clear-cut from context, ask rather than guess.

## Context detection

Check `git remote get-url origin` or the current working directory to determine which repo you're in, then read the appropriate reference file for repo-specific patterns:
- Stockly monorepo (`~/Stockly/`): read `${CLAUDE_SKILL_DIR}/stockly.md`
- Personal monorepo (`~/code/Main`): read `${CLAUDE_SKILL_DIR}/personal.md`

## Workspace registration (Rust)

Add the crate path to the `members` array in the root `Cargo.toml`:

```toml
members = [
    # ...existing members...
    "path/to/NewCrate",
]
```

If the crate should be available as a workspace dependency, also add it to `[workspace.dependencies]`:

```toml
[workspace.dependencies]
new_crate = { path = "path/to/NewCrate" }
```

## Verification

After scaffolding: `cargo check -p <package_name>`
