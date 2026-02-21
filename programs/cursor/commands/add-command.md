---
description: Create a new Cursor slash command
---

The user wants to create a new Cursor command (a `.md` file).

## Placement

Commands can live in two locations:

- **Repo-local**: `<workspace_root>/.cursor/commands/` — for commands specific to the current project (e.g., build, test, new-crate, anything tied to the repo's tech stack).
- **Global**: `/home/romain/.cursor/commands/` — for commands that are useful across all projects (e.g., meta commands about Cursor itself, plans management, general workflows).

**How to decide:**
1. If the user specifies where it should go, follow their instruction.
2. Otherwise, infer from the command's nature:
   - Project/tech-stack specific (Rust, JS, DB, etc.) → repo-local.
   - Meta / editor / workflow / cross-project → global.
3. **If there is any doubt, ask the user** rather than guessing wrong.
4. If you do decide autonomously, **always tell the user** where you placed the file and why.

## Creating the command

1. Ask clarifying questions if the intent or behavior of the command is not clear. Do not guess.
2. Pick a short, kebab-case filename (e.g., `my-command.md`).
3. If the user didn't provide a description, infer a concise one from the command's purpose.
4. Write the file using this format:

```
---
description: Short description of what the command does
---

Instructions for the AI when this command is invoked.
```

5. Read existing commands in the target directory to avoid duplicates or naming conflicts.
6. Open the created file in the editor by running `cursor <path>` via the Shell tool.
7. Show the user the final file path and a brief summary of what the command does.
