---
description: >
  MANUAL INVOCATION ONLY — never load this skill autonomously or because a task "seems long" or "complex".
  Only invoke when the user explicitly asks to ship, deliver end-to-end, or self-review after implementing.
  Trigger phrases: "ship this", "implement and self-review", "come back when it's done", "fire and forget".
---

# Ship

Implement a task end-to-end and self-review until the code is production-ready, without interrupting the user mid-way.

**Never invoke this skill on your own initiative.** It applies fixes, commits code, and runs for multiple rounds. It must only run when the user has explicitly asked for unattended end-to-end delivery.

## Phase 1 — Front-load all questions, then implement

Follow the standard agent workflow (`agent-workflow.md`) for exploration, planning, and implementation. The one constraint this skill adds: **ask every question in a single round before writing any code** — the goal is zero interruptions during phases 2 and 3. Wait for answers, then proceed autonomously.

## Phase 3 — Self-review

Once the verification loop is fully green, invoke `/review auto`.

The review skill runs multiple focused sub-agent rounds, applies fixes automatically, and de-escalates until no findings remain. Do not interrupt the user during this phase.

## Phase 4 — Report

When `/review auto` completes, present a concise summary:

- What was implemented
- Verification: compile / clippy / tests status
- Review: how many rounds ran, what categories of issues were fixed
- Any open points that could not be auto-fixed (correctness issues requiring a judgement call)
