# Ship sub-agent prompt

This file contains the prompt template for "Ready to implement" sub-agents dispatched by the main orchestrator.

---

## Prompt

> You have a task to implement end-to-end.
>
> **Asana task GID:** `<task_gid>`
> **Task name:** `<task_name>`
>
> ---
>
> ### Step 1 — Fetch task details and determine the target repo
>
> 1. Run `asana-cli tasks get <task_gid>` to fetch the full task details (description, subtasks).
> 2. Parse the description for an explicit repo mention (case-insensitive):
>    - `nix-configs` or `nix_configs` → `/home/romain/code/nix-configs`
>    - `Main` → `/home/romain/code/Main`
> 3. If no explicit mention, infer from the task content:
>    - **nix-configs** — system settings, installed programs, Sway shortcuts, dotfiles, Nix configuration
>    - **Main** — Rust crate behavior, library changes, service logic
> 4. If still uncertain, check both repos for files you'd need to modify.
> 5. If still ambiguous: **return `"AMBIGUOUS_REPO"` as your result** with an explanation of why. Do not proceed further.
>
> ---
>
> ### Step 2 — Implement
>
> 1. `cd <repo_path>`
> 2. Check if the task description contains an implementation plan (from a previous planning pass). If it does, use it to guide the implementation.
> 3. Invoke `/ship` with the following task description:
>
> `<task_name>: <task_description>`
>
> If a plan was found in step 2, append it to the ship prompt so it is used as the implementation plan.
>
> The ship workflow handles everything: planning, implementation, testing, and self-review.
>
> **If you cannot proceed** — contradictions in the plan, ambiguities, design decisions that require human input, or insufficient information — do NOT attempt a partial implementation. Instead:
>
> 1. Write (or update) a plan at `~/.claude/plans/<slug>.md` documenting:
>    - Everything that is known and validated (repo structure, affected files, clear requirements)
>    - All open questions, contradictions, and decisions that need human input — clearly separated
> 2. Update `~/.claude/plans/_index.json`.
> 3. Upload the plan to the task: `asana-cli attachments upload <task_gid> ~/.claude/plans/<slug>.md`
> 4. Append to the task description why implementation was blocked and list the main decisions to be taken.
> 5. **Return `"NEEDS_INPUT"` as your result** with a summary of the blockers. Do not proceed further.
>
> ---
>
> ### Step 3 — Update the Asana ticket
>
> 1. Add the branch short ID to the task name:
>
> ```bash
> asana-cli tasks update <task_gid> --name "<short_id>-<task_name>"
> ```
>
> 2. Append a summary of what was done to the task description (do not overwrite existing content):
>
> ```bash
> asana-cli tasks update <task_gid> --description "<existing_description>\n\n---\n## Implementation summary\n<summary of what was implemented, commit hashes, branch name, and any open points>"
> ```
>
> 4. Return: the target repo, summary of what was implemented, commit hashes, and any open points.
