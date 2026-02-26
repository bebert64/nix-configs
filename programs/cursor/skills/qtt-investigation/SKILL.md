---
name: qtt-investigation
description: Investigates a Quality Tech ticket (Notion). Use when the user asks to investigate a QTT, a Quality Tech ticket, a Notion ticket URL, or when following up on a ticket from the start-qtt-investigations workflow. Produces one of three outcomes: action plan (code), next steps (easy), or ready-to-paste prompt for another agent.
---

# Quality Tech Ticket investigation

Investigate the ticket from the given Notion page URL (or from context). Do not guess when information is missing; report what is missing and ask clarifying questions.

## Before choosing an outcome

### 0. Obtain and read Notion content (mandatory first step)

**You must attempt to read the ticket page and all comments before doing any other investigation.** Do not infer the ticket from code or Sentry alone.

- **How:** Use whatever works: Notion MCP (retrieve page + comments), browser, or ask the user to paste the ticket body and comments if you have no access.
- **If you cannot access Notion:** Say so explicitly at the start of your response and ask the user to paste the ticket content and comments (or key human diagnostic). Do not proceed to outcome A/B/C as if you had read them; either get the content or output clarifying questions.
- **In your output:** State whether you read the comments, and if a human left a diagnostic, quote or summarize it and say how your conclusion follows from or differs from it. If you skipped comments (e.g. no access and user didn’t paste), say so clearly.

### Then: use human diagnostic as the lead

**If there is a human diagnostic in the comments:** Treat it as the default lead. Evaluate whether they seem confident or are guessing; either way, investigate that lead first. Only suggest a different solution if you are absolutely sure the human diagnostic is wrong. Your plan or next steps must explicitly reference the human diagnostic (e.g. “As suggested in the comments, …” or “The comment suggested X; we confirm / we diverge because …”).

After investigating, choose exactly one of the three outcomes below and produce the corresponding output.

## 1. Code will be needed

When the fix or feature requires any amount of code (backend, frontend, config, script), however small:

- Write an action plan and prepare for a branch.
- Create the plan file at ~/.cursor/plans/SHORTID-SLUG.md (e.g. ~/.cursor/plans/ABCDE-fix-login.md). Use the ticket 5-character Short ID and a short slug.
- Plan content must include a line "## Short ID" and on the next line the 5-character Notion ticket code (e.g. ABCDE). open-plans matches when the current branch contains that Short ID or equals a "## Branch" value in the plan.
- Suggest a branch name if useful. After writing the plan, open it in the editor or show the path clearly.
- **Inform and continue:** In your reply, briefly report progress (e.g. plan path, root cause, what you’re doing next). Do not stop and wait for the user — immediately create the environment and start coding on the new branch. Only stop and return to the user (outcome A + plan path) if key information is missing or a blocking decision is needed.

1. **Prepare the environment:** Run `cd /home/romain/Stockly/Main && s wk <notion_url> -w=b`. This creates a git branch, a PR, and a git worktree at `/home/romain/Stockly/Main_<ShortId>`, where ShortId is the 5-character code from the ticket URL/name.
2. **Move to the worktree** and get the nix shell: `cd /home/romain/Stockly/Main_<ShortId> && direnv allow`.
3. **Implement** the solution in that worktree.
4. **Commit as you go:** Commit after each part of the solution is implemented and compiles. No single big commit at the end, unless the whole change is very small.

## 2. Easy (no code)

When resolution is clear and does not require writing code (e.g. config change, manual step, known runbook, close as duplicate):

- Do not create a plan file.
- Summarize precisely the next steps as a short, ordered list of concrete actions the user can take.
- Return to caller: Indicate outcome B and the ordered list of next steps.

## 3. Else (not easy, not code-related)

When the ticket is not straightforward and is not primarily a code change (e.g. product decision, cross-team process, or needs a dedicated conversation with another agent):

- Do not create a plan file.
- Prepare a ready-to-paste prompt for another Agent chat: context, goal, and what is already known.
- Return to caller: Indicate outcome C and the ready-to-paste prompt.

## If you need more info first

If the ticket is unclear or key information is missing, output clarifying questions instead of picking an outcome. Do not guess.