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
asana-cli sections list nix-and-code
```

Parse the JSON output to build a **name → GID** map. Required sections:
- **Input:** `Need plan`, `Ready to implement`
- **Output:** `Review plan`, `Review code`, `To fix`

**Auto-create missing output sections:**

```bash
asana-cli sections create nix-and-code "Review plan"
asana-cli sections create nix-and-code "Review code"
asana-cli sections create nix-and-code "To fix"
```

If an input section is missing, warn and skip it (no tasks to process).

---

## Step 2 — Fetch tasks from input sections

```bash
asana-cli tasks list nix-and-code --section "Need plan"
asana-cli tasks list nix-and-code --section "Ready to implement"
```

The list output includes each task's **GID and name** — that is all the main agent needs. Do NOT fetch full task details here; sub-agents handle that.

Collect GIDs into two lists: `plan_tasks` and `ship_tasks`.

---

## Step 3 — Dispatch sub-agents

Launch up to **4 sub-agents concurrently** (mix of plan and ship tasks).

Each sub-agent is responsible for fetching its own task details and determining the target repo. The main agent only passes the **task GID** and **task name**.

- **"Need plan" tasks** → use the prompt template in [`plan-agent.md`](plan-agent.md)
- **"Ready to implement" tasks** → use the prompt template in [`ship-agent.md`](ship-agent.md)

If a sub-agent returns `"AMBIGUOUS_REPO"`, treat it as a repo-resolution failure (see Step 4).

---

## Step 4 — Move tasks on completion

Moving a task = **create** in target section + **delete** original.

```bash
# Create in target section (preserving name and description)
asana-cli tasks create nix-and-code "<task_name>" --section "<target_section>" --description "<original_description>"

# Delete original
asana-cli tasks delete <original_task_gid>
```

**Mapping:**

| Source section | On success | On ambiguous repo | On failure |
|---|---|---|---|
| Need plan | → Review plan | → To fix | Stay in place |
| Ready to implement | → Review code | → To fix | Stay in place |

**On `AMBIGUOUS_REPO` result:** Move the task to "To fix". Append the sub-agent's ambiguity explanation to the task description (do not overwrite). Log: `"Task '<name>' — ambiguous target repo, moved to To fix"`.

**On sub-agent failure:** do NOT move the task. Leave it in its current section so it can be retried.

---

## Step 5 — Report

As each sub-agent completes, immediately report:
- Task name
- Outcome: success or failure (with error summary if failed)
- Section moved to (or "not moved" if failed)

After all sub-agents finish, display a summary table:

| # | Task | Source | Outcome | Moved to |
|---|------|--------|---------|----------|

---

## Error handling

- **`asana-cli` not found:** Fail immediately with `"asana-cli not installed — install it and retry"`.
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
