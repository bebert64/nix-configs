# Authoring rules, skills, and docs — resolve concrete values at authoring time

When writing a rule, skill, doc, or any other instruction artifact that will be re-invoked many times: if the content references a **concrete value** — an MCP tool name, a parameter shape, a project slug/id, a URL, a command flag, a config path, a proto field list, an env var name, etc. — look it up and bake the **exact resolved value** into the file at authoring time. Do **not** leave instructions like *"find the slug at runtime via MCP"* or *"discover the tool name"* when the value can be resolved once.

**Why:** The artifact runs many times; the lookup cost is paid on every invocation. Resolving once at authoring time trades a few minutes now for repeated savings (tokens, latency) and removes an opportunity for the lookup to fail, drift, or be mis-interpreted.

**How to apply when writing:**

- Before committing the file, audit every phrase like "find X", "look up X", "discover X", "check how to X" — if X is resolvable now, resolve it and replace the phrase with the actual value (plus a short note of when/how it was resolved if it's likely to drift).
- Useful lookup techniques when no live tool is available: grep past session logs under `~/.claude/projects/<project>/*.jsonl` for prior tool calls (tool name, input shape), grep the codebase for config files, read existing similar skills/rules.

**How to apply when reading an existing artifact:** If you encounter a rule/skill/doc that tells the reader to "look up X" rather than giving X directly, resolve X once yourself, then **suggest** to the user that the file be updated with the exact resolved value. Do not silently edit — propose the edit so the user can confirm.

**Exceptions:** values that genuinely change between invocations (today's date, current branch, the ticket id the user just passed in). Those must stay dynamic.
