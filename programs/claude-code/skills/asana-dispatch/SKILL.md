---
description: >
  Fetch tasks from Asana and dispatch sub-agents to plan or ship them.
  Trigger: /asana-dispatch or recurring cron schedule.
---

# Asana Dispatch

Fetch tasks from Asana board sections and dispatch sub-agents to either produce implementation plans or ship end-to-end. Move completed tasks to review sections.

---

## Section mapping

| Input section | Workflow | Output section (success) |
|---|---|---|
| Need plan | Planning sub-agent | Review plan |
| Ready to implement | `/ship` sub-agent | Review code |

Tasks missing a target repo → moved to **To fix**.

---

## Step 1 — Discover and ensure sections

List all sections for the project:

```bash
asana sections list nix-and-code
```

Parse the JSON output to build a **name → GID** map. Required sections:
- **Input:** `Need plan`, `Ready to implement`
- **Output:** `Review plan`, `Review code`, `To fix`

**Auto-create missing output sections:**

```bash
asana sections create nix-and-code "Review plan"
asana sections create nix-and-code "Review code"
asana sections create nix-and-code "To fix"
```

If an input section is missing, warn and skip it (no tasks to process).

---

## Step 2 — Fetch tasks from input sections

```bash
asana tasks list nix-and-code --section "Need plan"
asana tasks list nix-and-code --section "Ready to implement"
```

For each task in either section, fetch full details:

```bash
asana tasks get <task_gid>
```

This returns the task name, description, subtasks, and completed status as JSON.

Collect all tasks into two lists: `plan_tasks` and `ship_tasks`.

---

## Step 3 — Validate target repo

For each task, parse its **description** for an explicit repo mention.

Recognized values:
- `nix-configs` or `nix_configs` → `/home/romain/code/nix-configs`
- `Main` → `/home/romain/code/Main`

**Case-insensitive match.** Look for these as standalone words or path components in the description text.

If no repo is found:
1. Move the task to "To fix" (see Step 5)
2. Log: `"Task '<name>' has no target repo in description — moved to To fix"`
3. Skip to next task

---

## Step 4 — Dispatch sub-agents

Launch up to **4 sub-agents concurrently** (mix of plan and ship tasks).

### For "Need plan" tasks

Launch a sub-agent per task with this prompt:

> You are a planning agent. Your job is to produce a complete, detailed, implementation-ready plan. Do NOT write any code. Do NOT create branches.
>
> **Task from Asana:**
> - Title: `<task_name>`
> - Description: `<task_description>`
> - Subtasks: `<subtask_list>` (use these as chunking hints)
>
> **Target repo:** `<repo_path>`
>
> **Instructions:**
> 1. `cd <repo_path>`
> 2. Read `AGENTS.md` at the repo root if it exists.
> 3. Read `~/.claude/docs/README.md` and any relevant docs.
> 4. Read ALL relevant source files — existing behavior, data structures, API surfaces, tests.
> 5. Write a detailed implementation plan at `~/.claude/plans/<slug>.md` following the standard format:
>    - `## Branch`, `## Short ID`, `## Category` headers
>    - Numbered top-level steps (1., 2., 3.) with lettered sub-points (A, B, C)
>    - A `## Chunks` section grouping work into independently-shippable units sized for a single sub-agent (1–3 files each), with an explicit dependency graph
> 6. Update `~/.claude/plans/_index.json`.
> 7. Return: the plan file path and a summary of what was planned.
>
> Make the plan as detailed as possible. Every chunk should specify exact file paths to create/modify, the logic to implement, and how to verify.

### For "Ready to implement" tasks

Launch a sub-agent per task with this prompt:

> You have a task to implement end-to-end.
>
> **Task from Asana:**
> - Title: `<task_name>`
> - Description: `<task_description>`
> - Subtasks: `<subtask_list>`
>
> **Target repo:** `<repo_path>`
>
> **Instructions:**
> 1. `cd <repo_path>`
> 2. Invoke `/ship` with the following task description:
>
> `<task_name>: <task_description>`
>
> The ship workflow handles everything: planning, implementation, testing, and self-review.
>
> 3. Return: summary of what was implemented, commit hashes, and any open points.

---

## Step 5 — Move tasks on completion

Moving a task = **create** in target section + **delete** original.

```bash
# Create in target section (preserving name and description)
asana tasks create nix-and-code "<task_name>" --section "<target_section>" --description "<original_description>"

# Delete original
asana tasks delete <original_task_gid>
```

**Mapping:**

| Source section | On success | On missing repo |
|---|---|---|
| Need plan | → Review plan | → To fix |
| Ready to implement | → Review code | → To fix |

**On sub-agent failure:** do NOT move the task. Leave it in its current section so it can be retried.

---

## Step 6 — Report

As each sub-agent completes, immediately report:
- Task name
- Outcome: success or failure (with error summary if failed)
- Section moved to (or "not moved" if failed)

After all sub-agents finish, display a summary table:

| # | Task | Source | Outcome | Moved to |
|---|------|--------|---------|----------|

---

## Error handling

- **`asana` CLI not found:** Fail immediately with `"asana CLI not installed — install it and retry"`.
- **Sub-agent failure:** Do not move the task. Report the error. Continue with remaining tasks.
- **Empty input sections:** Report "No tasks in <section>" and finish cleanly.
- **Asana API error:** Report the error from the CLI stderr and skip the affected task.

---

## Cron setup

To run this skill automatically on weekday mornings:

```
CronCreate with cron: "17 9 * * 1-5", prompt: "/asana-dispatch", recurring: true
```

Note: cron jobs are session-scoped and auto-expire after 7 days. Re-create on new sessions as needed.
