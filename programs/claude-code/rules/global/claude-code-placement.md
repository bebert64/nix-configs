All shared Claude Code artifacts live in the **nix-configs** repo (`programs/claude-code/`):

- **Global rules**: `programs/claude-code/rules/global/` -> symlinked to `~/.claude/rules/global`
- **Stockly-specific rules**: `programs/claude-code/rules/stockly/` -> symlinked to `~/.claude/rules/stockly` (monsters only)
- **Global skills**: `programs/claude-code/skills/global/` -> individual skill dirs symlinked to `~/.claude/skills/`
- **Stockly-specific skills**: `programs/claude-code/skills/stockly/` -> individual skill dirs symlinked to `~/.claude/skills/` (monsters only)
- **Perso skills**: `programs/claude-code/skills/perso/` -> individual skill dirs symlinked to `~/.claude/skills/` (workstation only)
- **Global commands**: `programs/claude-code/commands/global/` -> individual .md files symlinked to `~/.claude/commands/`
- **Stockly-specific commands**: `programs/claude-code/commands/stockly/` -> individual .md files symlinked to `~/.claude/commands/` (monsters only)
- **Global docs**: `programs/claude-code/docs/global/` -> contents symlinked into `~/.claude/docs/`
- **Stockly docs**: `programs/claude-code/docs/stockly/` -> contents symlinked into `~/.claude/docs/` (monsters only)

Use repo-local (`.claude/` in a workspace) only for artifacts that are specific to that repo's tech stack or structure, not for general conventions.
