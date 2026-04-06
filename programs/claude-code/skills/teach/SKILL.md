---
description: Teach the AI something new -- creates or updates a rule, skill, doc, or explains why it already knows
---

The user wants to teach the AI a new convention, preference, workflow, or pattern. Your job is to figure out **what kind** of artifact to create (or update), and **where** it should live.

## Step 1: Understand the intent

Listen to what the user describes. If anything is unclear, ask questions.

Check if this knowledge already exists by searching:

- Global rules: `~/.claude/rules/global/`
- Stockly rules: `~/.claude/rules/stockly/`
- Skills: `~/.claude/skills/`
- Docs: `~/.claude/docs/`

If a matching artifact already exists:

- If the user input is already covered, explain where it lives and do nothing.
- If the user input amends or extends it, edit the existing file and explain what changed.

## Step 2: Decide the artifact type

| What the user describes                                                           | Artifact                          |
| --------------------------------------------------------------------------------- | --------------------------------- |
| A coding convention necessary for **code correctness** — wrong patterns cause bugs, compile errors, or structural issues | **Rule** (`.md` in `rules/`) |
| A style, naming, or formatting convention that can be caught and fixed in a **review round** | **Review skill file** (`~/.claude/skills/review/`) |
| A reusable multi-step procedure, workflow, or complex task                        | **Skill** (`SKILL.md`)            |
| Domain knowledge, architectural context, service behavior, "how X works", gotchas | **Doc** (`.md` in `docs/`)        |

**Rule vs review file — the key question**: *Would getting this wrong prevent the code from compiling or cause a correctness bug?* If yes → rule. If it's something a reviewer could spot and fix after the fact (naming, comment style, import ordering, destructuring style, etc.) → review file.

If the choice is not obvious, briefly explain the trade-off and ask the user.

**Heuristic**: if the content would exceed ~30 lines as a rule, suggest making it a doc instead. Rules should stay concise; longer reference material belongs in docs.

### Review skill file format

Review conventions live as additional files in `~/.claude/skills/review/`. To find the right file:

1. **Determine scope**: decide whether the convention is Stockly-specific or global. This is required — do not skip it.
2. List all files in `~/.claude/skills/review/` (excluding `SKILL.md`). Filter to stockly files (filename contains `stockly`) or global files depending on the scope decided in step 1.
3. Read the candidates and pick the one whose existing content is the closest match in topic.
4. If none fits well, create a new file. Stockly-specific files must include `stockly` in their filename; global files must not.

Append the new convention under a clear heading. Do not restructure the existing file.

### Rule format

Rules live in `~/.claude/rules/` (global or stockly subdirectory).

```markdown
---
paths: # optional -- only include if the rule applies to specific file types
  - "**/*.rs"
---

Rule content here. Keep it concise (under 50 lines ideally).
Use concrete examples of good/bad patterns when helpful.
```

- No `paths:` frontmatter = always loaded in every conversation.
- With `paths:` = only loaded when working on matching files.

### Skill format

Skills live in `~/.claude/skills/<skill-name>/SKILL.md`.

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

### Doc format

Docs live in `~/.claude/docs/`. Source of truth: `nix-configs/programs/claude-code/docs/`.

Plain markdown files organized by topic:

- `patterns/` for coding patterns and gotchas
- `runbooks/` for procedures (database access, local dev)
- `architecture/` for system maps
- `services/` for per-service guides

When creating or updating a doc, also update the `README.md` index if the doc is new.

## Step 3: Decide the location

- **Global** (`rules/global/`, `docs/global/`): for rules/docs useful across all projects.
- **Stockly-specific** (`rules/stockly/`, `docs/stockly/`): for artifacts tied to Stockly codebase, tooling, or conventions.

**How to decide:**

1. If the user specifies the scope, follow their instruction.
2. Otherwise, infer from the content:
   - Stockly infra, tooling, proto patterns, DB conventions -> Stockly-specific.
   - Personal preferences, Rust idioms, general workflows -> global.
3. If there is any doubt, ask the user.
4. If you decide autonomously, tell the user where you placed it and why.

## Step 4: Create or update

1. Create the file following the appropriate format above.
2. Give the user a brief summary: what was created/updated, where, and why that type/location was chosen.
