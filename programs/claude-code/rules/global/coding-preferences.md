## Code organization

- **Separation of Concerns**: Each function should have a single responsibility. E.g., `build_context` is responsible for the full shape of the context — callers shouldn't need to mutate it after.

## Design

- Avoid overkill genericity — use concrete types when a function is only used with one type.
- **YAGNI (You Ain't Gonna Need It)** — don't build features "just in case". Ship simple, add complexity only when there's a real need. Avoids wasted effort, maintenance burden, and unnecessary complexity.
