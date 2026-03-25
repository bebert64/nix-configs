# Stockly Docs

Reference documentation for Stockly development. Read the relevant doc before diving into a service or pattern.

## Architecture

- `architecture/overview.md` — System map, service boundaries, tech stack (TODO: bootstrap from repo)
- `architecture/service-map.md` — Which service does what, how they communicate (TODO: bootstrap from repo)

## Services

Service-specific docs with key modules, entry points, patterns, and gotchas. Add incrementally as you work on each service.

- `services/operations.md` — (TODO)
- `services/stocks.md` — (TODO)
- `services/integrations.md` — (TODO)

## Patterns

- `patterns/error-handling.md` — Fail vs Error with real Stockly examples (TODO: extract from rules + code)
- `patterns/proto-design.md` — Three-layer pattern, additionals, validated() (TODO: extract from rules + code)
- `patterns/testing.md` — How to write/run tests, fixtures, integration setup (TODO)

## Runbooks

- `runbooks/database-access.md` — How to obtain Stockly database URIs via SOPS
- `runbooks/local-dev.md` — Stockly CLI, makefile introspection, compilation, PR workflow
