# Before Working on a Service

1. Read the root `AGENTS.md` at the monorepo root for general project context
2. Read the service's own `AGENTS.md` if it exists (e.g., `operations/Service/AGENTS.md`)
3. Check `~/.claude/docs/` for relevant service or pattern docs

# Before Implementing a Task

1. Always start by identifying relevant or similar code and read it
2. Before implementing any change, make a recap of the current behavior
3. If required to consider other changes made in the current Pull Request (PR), check diff using `git diff origin/master...HEAD`
4. Reword what is expected
5. Create a detailed plan of what you need to do
6. Ask the user questions on key technical decisions and all unclear points (front-load all questions in phase 1)

# Rust Verification Loop

After modifying Rust code, verify in this order:

1. **Compile check** (after each file change):
   ```bash
   cargo check --quiet -p <crate>
   ```

2. **Clippy** (after each logical unit):
   ```bash
   CLIPPY_CONF_DIR="$STOCKLY_WORKTREE_ROOT/.cargo/workspace/clippy.toml" cargo clippy --quiet -p <crate>
   ```

3. **Tests** (after each logical unit):
   ```bash
   cargo test --quiet -p <crate>
   ```

4. **Formatting** (before committing):
   ```bash
   cargo fmt -- --config "comment_width=120,condense_wildcard_suffixes=false,format_code_in_doc_comments=true,format_macro_bodies=true,hex_literal_case=Upper,imports_granularity=One,normalize_doc_attributes=true,wrap_comments=true"
   ```

5. **Unused dependencies** (before committing):
   ```bash
   cargo machete
   ```

On failure: read the error → fix → re-run → loop until green. Only escalate to the user if stuck after 2-3 attempts.

## Development Setup

When running any `cargo` command, ALWAYS use `--quiet`. Try the command directly first — do NOT preemptively run direnv. Only if it fails with `cargo: command not found`, run:
```bash
direnv allow && eval "$(direnv export zsh)"
```

# Task Planning & Delegation

- **Break plans into subagent-delegable blocks**: When planning work, always decompose the plan into independent units that can be executed by subagents (Task tool). Whatever can be delegated to a subagent should be delegated.
- Launch independent subagents concurrently (up to 4 at a time) to maximize throughput.
- Only keep sequential what truly depends on prior steps' output. Everything else runs in parallel.
- Each delegated block should have a clear, self-contained description with all context the subagent needs (it doesn't share your conversation history).
- Reserve the main agent for orchestration, decisions requiring user input, and stitching results together.
