# Comments

- **Always document rationale for arbitrary values** (constants, timeouts, limits, etc.). Even if it's just "arbitrarily picked as a reasonable default" — future maintainers need to know whether a value was carefully calculated or just a starting point. Include trade-offs to help with tuning.

- **Comments explain WHY, never WHAT.** "What" comments bloat the file and actively decrease readability.
- Avoid over-specific comments that reference implementation details elsewhere -- they become misleading when that code changes. Keep doc comments self-contained.
- In edge-case comments, mention production examples (company names, dates, stats) to distinguish "actually happened" from "theoretical what-if".
- When refactoring, preserve comments that explain _why_ something is done (rationale).

- Documentation and examples are code — they must be equally well thought out. To justify their presence, they must be a significant improvement over simply reading the code.
