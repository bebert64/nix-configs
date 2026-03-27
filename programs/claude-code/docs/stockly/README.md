# Stockly Docs

Reference documentation for Stockly development. Read the relevant doc before diving into a service or pattern.

## Architecture

- `architecture/overview.md` — System map, service boundaries, tech stack, monorepo layout
- `architecture/service-map.md` — Which service does what, how they communicate, data flow

## Services

Service-specific docs with key modules, entry points, patterns, and gotchas. Add incrementally as you work on each service.

- `services/operations.md` — Crate structure, module layout, gRPC services, database overview

## Patterns

- `patterns/error-handling.md` — Error vs Fail two-level Result, `try_or_wrap!`, exhaustive matching, real examples
- `patterns/proto-design.md` — Three-layer pattern, additionals, `validated()`, PreValidated, RPC design
- `patterns/testing.md` — Unit tests, integration tests, tintes, test helpers, naming

## Runbooks

- `runbooks/database-access.md` — How to obtain Stockly database URIs via SOPS
- `runbooks/local-dev.md` — Stockly CLI, makefile introspection, compilation, PR workflow
