---
description: Bootstrap a PR review using a Notion ticket and the PR
---

You're helping the user get started on reviewing a PR. Follow these steps.

**ShortId (Stockly):** a 5-character code (letters or digits) that identifies a ticket and appears in the name of all related artifacts: Notion ticket title, branch name, worktree directory, PR title, etc. When this command refers to "shortId", it means this Stockly concept.

**Review tickets:** If the ticket title indicates it is a review ticket (e.g. "FNGAG: Review @EN4QK: BO Messages sent to supplier aren't linked to thread"), the ticket references a **source** ticket (here, EN4QK). The **main shortId** for the rest of the workflow is that source ticket's shortId (EN4QK)—i.e. the one being reviewed. The PR and branch names will contain the main shortId, not the review ticket's own shortId (FNGAG).

**Assumptions about the reviewer:** (1) They have a good idea of how the codebase usually works, but may need a reminder of the specific area this PR touches. (2) They have no prior context about this PR. Throughout the analysis, briefly remind them of the relevant part of the codebase when it matters, and explain the PR and its changes from scratch—do not assume they have already read the ticket, the PR, or any comments.

## 1. Get the Notion ticket URL

- Use the Notion ticket URL the user provides. If they didn't provide one, ask for it.

## 2. Notion ticket: read and summarize

- From the Notion ticket **URL**, extract the page ID (the UUID at the end of the URL, with or without dashes).
- Use the Notion MCP server:
  - **API-retrieve-a-page** with that `page_id` to get the page (title, properties).
  - **API-get-block-children** with `block_id` = that same page ID to get the page body (blocks).
  - **API-retrieve-a-comment** with `block_id` = that page ID to get comments on the page (paginate with `start_cursor` if needed).
- **If the ticket title indicates it is a review ticket** (e.g. "FNGAG: Review @EN4QK: ..."), identify the **source ticket's shortId** (e.g. EN4QK) from the title, then **also read the source ticket**: find that ticket (e.g. via Notion search or relation from the review ticket), retrieve its page, block children, and comments. The **main shortId** for steps 3–5 is this source ticket's shortId. Most of the time the review ticket has 0 comments and no added value (empty or template-only body); in those cases **do not mention the review ticket in the summary**—summarize only the source ticket.
- From the ticket content (or the source ticket's content when it's a review ticket), **find the GitHub PR URL** (link in the body, or in a "PR" / "GitHub" / "Link" property). You will need it for the next steps.
- Summarize for the user:
  - **Ticket title and goal**: what the ticket asks for (for review tickets with no added value: only the source ticket's title and goal).
  - **Key context**: requirements, acceptance criteria, constraints, links.
  - **Notion comments**: main points from Notion comments (on the source ticket when it's a review ticket; on both only if the review ticket has comments or meaningful content).

## 3. ShortId check (mandatory)

- Determine the **main shortId**: for a review ticket (e.g. "FNGAG: Review @EN4QK: ..."), it is the **source** ticket's shortId (EN4QK); otherwise it is the shortId of the ticket itself.
- Extract the **shortId** in three places (normalize for comparison, e.g. same casing, strip prefixes like "branch-"):
  - **Notion (main shortId)**: from the source ticket's title if it's a review ticket, or from the ticket title / ShortId property / PR link label otherwise.
  - **GitHub PR**: from the PR title or the head branch name (e.g. `gh pr view --json title,headRefName`). Must contain the **main** shortId.
- If the GitHub PR URL was not found on the Notion ticket (or source ticket), or if **any two of these shortIds differ**,**stop and ask the user for instructions**. Do not proceed with the rest of the review. Clearly report which shortIds you found (Notion main shortId, PR) and where they differ.

## 4. PR: read and summarize (including GitHub comments)

- Use the PR from the Notion ticket link (or the current branch: `gh pr view` in the repo). Fetch full PR data and **all comments** using the GitHub CLI:
  - `gh pr view` (or `gh pr view <number>` if you have the PR number) for description and metadata.
  - `gh api repos/:owner/:repo/issues/:issue_number/comments` for issue-level comments.
  - `gh api repos/:owner/:repo/pulls/:pull_number/comments` for review comments (on lines of code). Use the PR number from `gh pr view --json number`.
- Summarize (explain from scratch; the reviewer has no prior knowledge of this PR):
  - **Intent**: what the PR is trying to do in a few clear sentences.
  - **Main changes**: which parts of the codebase are touched (e.g. service, module, API, UI); briefly remind how that area usually works if it helps, then how this PR changes it and how that relates to the ticket.
  - **GitHub PR comments**: main points from both issue and review comments (questions, requested changes, resolutions).

## 5. Alignment and conclusion

- Compare the PR to the ticket (for review tickets: to the **source** ticket) and to **both** Notion and GitHub comments:
  - Does the PR address what the ticket (or source ticket) asks for?
  - Are important Notion comments or decisions reflected?
  - Are GitHub review/issue comments addressed or still open?
- Give a short **conclusion**: does it globally seem to solve the problem or not, and why (2–4 sentences). Call out obvious gaps or mismatches if any.

## 6. Save the investigation

Persist the review so it can be found later. (1) Ensure `~/.cursor/saved-investigations/` exists (create the directory if it does not). (2) Write one `.md` file there with filename `{short_id}-{date}T{time}.md` (e.g. `EN4QK-2025-02-27T143052.md`; use ISO date and time without colons). File content: a header with `# {ticket title}`, `Short ID: {short_id}`, `Notion: {notion_url}`, `Notion page ID: {id}` (the page ID from the ticket URL), `Investigation date: {iso-date}`; then `## Resume` and a short summary of the review (ticket goal, PR intent, conclusion); then `## Full investigation` and the full content from steps 2–5 (ticket summary, PR summary, alignment, conclusion). The filename prefix `{short_id}-` lets **review-saved-investigations** list it and allows **open-plans** (if extended to consider `~/.cursor/saved-investigations/` with the same branch/short-id matching as for plans) to pick it up when run on the branch with the short-id.

## 7. One-liners to open the PR branch

Offer these two one-liners (replace `<notion_url>` with the ticket URL from step 1; replace `<branch_name>` with the PR branch name, e.g. `EN4QK-BoMessagesSentToSupplierArenTLinkedToThread`, which matches the worktree directory name after running the Cerberus one-liner):

- **On Cerberus** (cd to Main repo, pull, then create worktree and switch to PR branch):
  1. `cdm`
  2. `git pull`
  3. `s wk <notion_url> -w=b`
- **On your machine** (open the worktree on Cerberus via Remote-SSH, detached from the terminal; worktrees are under `/home/romain/Stockly/` and named `Main_<branch_name>`):
  ```bash
  cursor --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/Stockly/Main_<branch_name> & disown
  ```

Keep the whole answer scannable (clear headings, short bullets). If something is missing (e.g. Notion inaccessible, `gh` not available), say what you used and what you could not use.
