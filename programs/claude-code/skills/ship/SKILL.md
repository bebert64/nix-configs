---
description: >
  MANUAL INVOCATION ONLY — never load this skill autonomously or because a task "seems long" or "complex".
  Only invoke when the user explicitly asks to ship, deliver end-to-end, or self-review after implementing.
  Trigger phrases: "ship this", "implement and self-review", "come back when it's done", "fire and forget".
---

# Ship

Implement a task end-to-end and self-review until production-ready, without interrupting the user.

**Never invoke this skill on your own initiative.** It commits code and runs for multiple rounds. It must only run when the user explicitly asks for unattended end-to-end delivery.

---

## Orchestrator model

Ship runs as a **pure orchestrator**. All heavy work is delegated to sub-agents:

- A **planning sub-agent** (Phase 1) explores the codebase, creates or verifies the plan, and surfaces questions.
- **Implementation sub-agents**, one per chunk (Phase 3), run in parallel and each own their full implement → verify → commit loop.
- The **review skill** (Phase 4) handles self-review with its own sub-agents.

The orchestrator never reads source files, never writes code, and keeps its context lean. Its only jobs are: dispatching agents, forwarding questions to the user, tracking the chunk dependency graph, and reporting at the end.

---

## Phase 0 — Gate check (only when no plan is referenced)

If the user provided a **textual description** rather than a plan file path:

Before launching any sub-agent, produce a brief recap directly in the conversation (hard cap: **15 lines**):

- What will be built — features, components, services, scope **in**
- What will **not** be built — explicit exclusions, deferred work, out-of-scope
- Any apparent ambiguity phrased as a direct question (max 3)

**Wait for the user to confirm or correct this recap before continuing.**

This is the only mandatory human gate in the workflow. Its purpose is to catch scope misreadings (wrong architecture, missing half of the task) before any code is written. Keep it tight — this is a checkpoint, not a design review.

If a plan file was referenced, skip Phase 0 entirely.

---

## Phase 1 — Planning sub-agent

Dispatch a single **Plan-type sub-agent** with the following instructions:

> You are the planning agent for a ship workflow. Your job is to produce a complete, implementation-ready plan. Do NOT write any code.
>
> **If a plan file already exists for this branch** (check `~/.claude/plans/_index.json` using the branch short ID):
> 1. Read the plan in full.
> 2. Read the relevant source files to verify its assumptions are still valid.
> 3. Identify any remaining gaps, stale steps, or contradictions.
> 4. Return the (possibly updated) plan path and a list of open questions (may be empty).
>
> **If no plan exists**:
> 1. Read `AGENTS.md` at the repo root, then the relevant service's `AGENTS.md` if it exists.
> 2. Read `~/.claude/docs/README.md` and relevant docs.
> 3. Read ALL relevant source files (existing behaviour, data structures, API surface, tests).
> 4. Identify every open question, covering at minimum these categories:
>    - **Scope**: exactly which files / services / features are in? What is explicitly out?
>    - **Behaviour**: edge cases, error cases, what happens when X is missing or invalid?
>    - **Design decisions**: if multiple valid approaches exist, which one?
>    - **Constraints**: performance, backwards-compatibility, migration needs, feature flags?
>    - **Validation**: how will "done" be verified? Are there existing tests to run?
> 5. Write a plan file at `~/.claude/plans/<short-id>-ship.md` following the format in the plans rules.
> 6. The plan **must** include a `## Chunks` section that groups implementation steps into independently-shippable units, each sized for a single sub-agent pass (1–3 files, clear inputs/outputs), with an explicit dependency graph.
> 7. Update `~/.claude/plans/_index.json`.
> 8. Return the plan file path and a list of open questions (may be empty).
>
> **Question discipline**: only surface questions where a wrong call would require significant rework. Omit anything answerable from the code or prior conversation.

Once the planning sub-agent returns:

- If there are **no questions**: proceed immediately to Phase 2.
- If there are **questions**: ask them to the user as a single numbered list grouped by category. On receiving answers, apply this filter to each answer before passing anything to the planning sub-agent:

  > *"If I started coding right now, could this answer lead to a wrong implementation decision?"*

  If yes, the answer is not precise enough. Push back before proceeding:

  - **Vague answer** ("just do whatever makes sense") → name the specific options you see and ask the user to pick one.
  - **Answer contradicts the codebase** ("we don't use X here") → surface the contradiction explicitly.
  - **Deferred decision** ("you decide") → confirm you are truly empowered to decide, then document your choice in the plan and flag it in Phase 5.

  Do not forward answers to the planning sub-agent until every answer is actionable. Then pass all answers in one shot — do not loop back to the user a second time unless a genuinely new contradiction is discovered.

---

## Phase 2 — Execution plan

Read the `## Chunks` section of the plan. Build a dependency graph. Identify the first wave (chunks with no unmet dependencies).

Do not dispatch any implementation agents yet — just confirm the execution order in your own reasoning.

---

## Phase 3 — Implementation (parallel sub-agents)

Dispatch implementation sub-agents wave by wave, respecting the dependency graph. Run up to **4 agents concurrently** per wave.

Each sub-agent receives:
- The full plan text (so it has context on the overall goal and all prior decisions)
- Its specific chunk: which steps to implement, which files to create/modify, which prior steps' outputs it depends on
- Standard instructions:

> 1. `git pull` first.
> 2. Read all files you will modify before touching them.
> 3. Implement the chunk as described.
> 4. After each file change: `cargo check --quiet -p <crate>` (or equivalent for non-Rust).
> 5. After the full chunk: run clippy and affected tests.
> 6. Fix all failures before committing.
> 7. Commit each logical unit separately — never batch unrelated changes into one commit. Never commit code that doesn't compile. Then `git push`.
> 8. Report: commit hash, any deviations from the plan, any decisions made.
>
> Use `isolation: worktree` so parallel agents don't conflict.

After each wave completes, read the sub-agent reports, update the plan step statuses to `DONE` in the plan file, then dispatch the next wave. **The plan file is the recovery checkpoint** — if the run is interrupted, a future agent reads it and resumes from the first non-`DONE` step.

If a sub-agent reports a failure it cannot resolve, pause and surface it to the user before continuing.

---

## Phase 4 — Self-review

Once all chunks are committed and pushed, update the plan `Status` to `Review`, then invoke:

```
/review auto
```

The review skill dispatches its own sub-agents per file batch and theme, applies all fixable findings automatically, and runs until no findings remain. Do not interrupt the user during this phase.

Update plan `Status` to `Done` when the review is clean.

---

## Phase 5 — Report

Present a concise summary to the user:

- **What was implemented** (link to plan file for full detail)
- **Verification**: compile / clippy / tests — pass or fail
- **Review**: categories of issues found and fixed
- **Decisions made autonomously** during the run (non-obvious calls not covered by the user's answers)
- **Open points** that could not be auto-fixed and need a judgement call
