# Claude Docs Index

Reference material for Claude agents. Read this index first, then load relevant docs.

## Stockly Runbooks

- `~/code/nix-configs/programs/claude-code/docs/stockly/runbooks/database-access.md` — How to obtain Stockly database URIs via SOPS
- `~/code/nix-configs/programs/claude-code/docs/stockly/runbooks/local-dev.md` — Stockly CLI, makefile introspection, compilation, PR workflow

## Auto-generated API References

Updated weekly by `~/.claude/scripts/update_rust_docs.sh`. Always includes a generation timestamp — verify against source if in doubt.

| File | Contents |
|---|---|
| [don_error.md](don_error.md) | `don_error` crate — error type, result alias, context helpers, option/result extensions |
| [stockly/internal_error.md](stockly/internal_error.md) | `internal_error` crate — Stockly's equivalent of `don_error`, with Sentry integration |
| [stockly/validation.md](stockly/validation.md) | `validation` crate — `FieldInvalidity`, `PreValidated`, validated constructors for IDs/URLs/UUIDs |
