---
description: >
  Set up an autonomous worktree workflow when implementing on main/master. Launches a sub-agent in an
  isolated worktree, then transplants commits to a properly-named branch with PR. Invoked automatically
  by the branch-guard rule when the agent detects it is on main or master.
---

# Autonomous Worktree

Implement a task in an isolated worktree, then transplant the commits onto a properly-named branch created by the project's CLI tooling.

The agent never manually creates branches, worktrees, PRs, or initial commits -- the CLI tools handle all of that.

---

## Phase 1 -- Work

Launch an Agent sub-agent with `isolation: "worktree"`. Give it the full implementation task. The agent works freely in the isolated worktree with no naming constraints. It implements, tests, and self-reviews.

On completion, the sub-agent returns:
- The **worktree path**
- The **branch name**

This is the `source_worktree_path` for Phase 3.

---

## Phase 2 -- Set up real worktree

Determine which CLI tool to use based on the repo context.

### Stockly (main repo)

Detect Stockly context by checking if `dev_tools/StocklyCli` exists in the repo root.

```bash
s wk <ticket_identifier>
```

Where `ticket_identifier` can be a Notion URL, short_id, or UUID. If a ticket/short_id already exists for the current task, use its identifier.

### Personal repos

```bash
db-cli wk "descriptive title"
```

Where the title describes the task.

### Parsing the worktree path from CLI output

Both tools print to stderr a line in the format:

```
Worktree created. To switch to it, run:
  cd <path> && direnv allow
```

Extract `<path>` from this output. This is the `target_worktree_path` for Phase 3.

---

## Phase 3 -- Transplant

Run the transplant script to cherry-pick commits from the isolated worktree onto the properly-named branch:

```bash
bash "$CLAUDE_SKILL_DIR/transplant.sh" <source_worktree_path> <target_worktree_path>
```

The script:
1. Cherry-picks all commits from the source worktree onto the target worktree
2. Removes the source worktree and deletes its branch (automatic cleanup)

If the transplant fails due to cherry-pick conflicts, investigate and resolve manually in the target worktree, then continue.

---

## Phase 4 -- Push

```bash
git -C <target_worktree_path> push
```

---

## Error handling

- **Cherry-pick conflicts**: If the transplant script exits with an error, the cherry-pick has been aborted. Investigate the conflict in the target worktree, apply the changes manually, commit, and push.
- **CLI tool failure**: If `s wk` or `db-cli wk` fails, report the error to the user rather than attempting to create branches manually.
