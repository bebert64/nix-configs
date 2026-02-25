# open-plans

1. Run `git branch --show-current` to get the current branch name.
2. List all plan files in `~/.cursor/plans` (or the user's Cursor plans directory).
3. A plan **matches** the current branch if **either**:
   - It contains a `## Branch` section whose value **equals** the current branch name, **or**
   - The current branch name **contains** the plan's Short ID: get the Short ID from the plan filename (segment before the first `-` in `<short-id>-<slug>.md`) or from a `## Short ID` line in the plan content (5-letter/digit Notion ticket code, e.g. `Q2PS8`). If the branch name contains that string, the plan matches. (Branch names are created by Stockly tooling and always include the Short ID; the plan cannot set the exact branch name.)
4. Open all matching plans in the editor by running `cursor <path>` via the Shell tool for each matching file.
5. For each matching plan, read it and provide:
   - A 2-3 line synthesis of what the plan is about
   - Its current status: are all action items completed, or are there still pending/in-progress steps? List any remaining items briefly.
6. If no plans match, say so.
