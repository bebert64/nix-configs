---
description: Teach the AI something new — creates or updates a rule, skill, or explains why it already knows
---

The user wants to teach the AI a new convention, preference, workflow, or pattern. Your job is to figure out **what kind** of artifact to create (or update), and **where** it should live.

## Step 1: Understand the intent

Listen to what the user describes. If anything is unclear, ask questions — don't guess.

Check if this knowledge already exists by searching:
- Global rules: `/home/romain/.cursor/rules/`
- Stockly rules: `/home/romain/Stockly/.cursor/rules/`
- Repo-local rules: `<workspace_root>/.cursor/rules/`
- Global skills: `/home/romain/.cursor/skills/`
- Repo-local skills: `<workspace_root>/.cursor/skills/`

If a matching rule or skill already exists:
- If the user's input is already covered, explain where it lives and do nothing.
- If the user's input amends or extends it, edit the existing file, open it in the editor with `cursor <path>`, and explain what changed.

## Step 2: Decide the artifact type

| What the user describes | Artifact |
|---|---|
| A coding convention, style preference, or constraint that should be passively applied | **Rule** (`.mdc` file) |
| File-pattern-specific guidance (e.g., "when editing Rust files...") | **Rule** with `globs` |
| A reusable multi-step procedure, workflow, or complex task | **Skill** (`SKILL.md`) |

If the choice isn't obvious, briefly explain the trade-off and ask the user.

### Rule format

```
.cursor/rules/rule-name.mdc
```

```markdown
---
description: Brief description
globs: **/*.rs  (omit if alwaysApply is true)
alwaysApply: false
---

Rule content here. Keep it concise (under 50 lines ideally).
Use concrete examples of good/bad patterns when helpful.
```

- `alwaysApply: true` → universal, applies to every conversation.
- `globs` → only activates when matching files are open.
- Ask the user about scope if not obvious.

### Skill format

```
~/.cursor/skills/skill-name/SKILL.md   (global)
.cursor/skills/skill-name/SKILL.md     (repo-local)
```

```markdown
---
name: skill-name
description: What it does and when to use it (third person, include trigger terms)
---

# Skill Name

Step-by-step instructions for the agent.
```

- Keep SKILL.md under 500 lines; use separate reference files for detailed docs.
- Name: lowercase, hyphens only, max 64 chars.

## Step 3: Decide the location

There are three scopes:

- **Global** (`/home/romain/.cursor/`): for rules/skills useful across all projects — personal preferences, general workflows, editor conventions, language-level patterns.
- **Stockly-specific** (`/home/romain/Stockly/.cursor/`): for rules/skills tied to Stockly's codebase, tooling, or conventions. Only applies when working on Stockly projects.
- **Repo-local** (`<workspace_root>/.cursor/`): for rules/skills tied to a specific project's tech stack, codebase conventions, or repo-specific workflows.

**How to decide:**
1. If the user specifies the scope, follow their instruction.
2. Otherwise, infer from the content:
   - Stockly infra, tooling, proto patterns, DB conventions → Stockly-specific.
   - Personal preferences, Rust idioms, general workflows → global.
   - Tied to the current repo's structure or libraries → repo-local.
3. **If there is any doubt, ask the user.**
4. If you decide autonomously, tell the user where you placed it and why.

## Step 4: Create or update

1. Create the file following the appropriate format above.
2. Open it in the editor with `cursor <path>`.
3. Give the user a brief summary: what was created/updated, where, and why that type/location was chosen.
