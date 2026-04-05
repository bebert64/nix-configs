---
description: >
  MANUAL INVOCATION ONLY — never load this skill autonomously or because a task "seems long" or "complex".
  Only invoke when the user explicitly asks to ship, deliver end-to-end, or self-review after implementing.
  Trigger phrases: "ship this", "implement and self-review", "come back when it's done", "fire and forget".
---

# Ship

Implement a task end-to-end and self-review until the code is production-ready, without interrupting the user mid-way.

**Never invoke this skill on your own initiative.** It applies fixes, commits code, and runs for multiple rounds. It must only run when the user has explicitly asked for unattended end-to-end delivery.

---

## Phase 1 — Clarification (mandatory, never skip)

The goal of this phase is to reach a state where every implementation decision is pinned down before a single line of code is written. Ambiguity now becomes a blocker mid-run.

### 1A — Check for an existing plan

If the user invoked `/ship <plan-file>` or referenced a specific plan:

1. Read the plan file in full.
2. Treat it as having gone through Phase 1 already — **do not re-ask things the plan already answers**.
3. Still read the relevant code to verify the plan's assumptions are still valid (the plan may be stale).
4. Only ask questions about genuine remaining gaps or newly-discovered contradictions.

If no plan was provided, proceed to 1B from scratch.

### 1B — Explore & identify unknowns

Follow `agent-workflow.md`: read the relevant code, understand the current behaviour, and enumerate every open question. No question is too small — an unanswered detail during a long autonomous run will force an interruption or produce wrong code.

Typical categories to cover:
- **Scope**: exactly which files / services / features are in scope? What is explicitly out of scope?
- **Behaviour**: edge cases, error cases, what happens when X is missing or invalid?
- **Design decisions**: if multiple valid approaches exist, which one?
- **Constraints**: performance, backwards-compatibility, migration needs, feature flags?
- **Validation**: how will "done" be verified? Are there existing tests to run?

### 1C — Decide whether to ask or proceed

After exploration, apply the following decision rule for each open point:

- **Can you make this decision confidently from the code, context, or prior conversation?** → Document the decision in the plan and proceed. Do not ask.
- **Is this genuinely ambiguous and would a wrong call require significant rework?** → Add it to the question list.

**If the question list is empty, skip straight to Phase 2 — do not invent questions or ask for confirmation on things that are already clear.**

If there are questions, write them as a numbered list grouped by category and ask once. On receiving answers, apply this filter before proceeding:

For each answer, ask yourself: *"If I started coding right now, could this answer lead to a wrong implementation decision?"* If yes, the answer is not precise enough. Push back:

- If an answer is vague ("just do whatever makes sense"), name the specific options you see and ask the user to pick one.
- If an answer contradicts something in the codebase ("we don't use X here"), surface the contradiction explicitly.
- If an answer defers a decision ("you decide"), confirm you are truly empowered to decide, then document your choice in the plan and flag it in Phase 5.

Do not start Phase 2 until every answer is actionable — but equally, do not wait for answers that were never needed.

---

## Phase 2 — Write the plan file

Before writing any code, create a plan file at `~/.claude/plans/<short-id>-ship.md` (use the ticket/branch short ID, or a slug of the task if none exists).

The plan file must contain:

```
## Branch
<current git branch>

## Short ID
<ticket code or task slug>

## Category
<qtt | review | tech-task | other>

## Status
In progress

## Goal
<one paragraph: what this implements and why>

## Steps
1. [DONE/IN PROGRESS/TODO] <step description>
   A. [DONE/IN PROGRESS/TODO] <sub-step>
   B. ...
2. ...

## Key decisions
- <decision made in Phase 1 that is non-obvious>

## Open points
- <anything that could not be resolved and was deferred>
```

Update `~/.claude/plans/_index.json` as required by the plans rules in `ai-behavior.md`.

**Keep the plan updated throughout execution.** After completing each step or sub-step, mark it `DONE` and update `Status`. This is the recovery checkpoint — if the run is interrupted, the next agent reads this file and resumes from the first non-`DONE` step.

---

## Phase 3 — Implement & verify

Follow the standard `agent-workflow.md` implementation loop. After each logical unit:

1. Run compile check.
2. Run clippy.
3. Run affected tests.
4. Fix any failures before moving on.
5. Mark the corresponding plan step `DONE`.
6. Commit with a descriptive message.

Never batch multiple logical units into one commit. Never commit code that doesn't compile.

---

## Phase 4 — Self-review

Once the verification loop is fully green, invoke `/review auto`.

The review skill runs multiple focused sub-agent rounds, applies fixes automatically, and de-escalates until no findings remain. Do not interrupt the user during this phase.

Update the plan `Status` to `Review` before starting, then `Done` when complete.

---

## Phase 5 — Report

Present a concise summary to the user:

- **What was implemented** (link to plan file for full detail)
- **Verification**: compile / clippy / tests — pass/fail
- **Review**: how many rounds ran, what categories of issues were fixed
- **Decisions made autonomously** during the run (from "you decide" answers in Phase 1)
- **Open points** that could not be auto-fixed and require a judgement call
