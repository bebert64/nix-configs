# open-plans

1. Run `git branch --show-current` to get the current branch name.
2. List all plan files in /home/user/.cursor/plans.
3. For each plan, check if it contains a `## Branch` section whose value matches the current branch.
4. Open all matching plans in the editor by running `cursor <path>` via the Shell tool for each matching file.
5. For each matching plan, read it and provide:
   - A 2-3 line synthesis of what the plan is about
   - Its current status: are all action items completed, or are there still pending/in-progress steps? List any remaining items briefly.
6. If no plans match, say so.
