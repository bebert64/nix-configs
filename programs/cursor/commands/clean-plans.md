# clean-plans

List all plans located at /home/romain/.cursor/plans and give a brief summary of each (a few lines max).

For each plan, assign a number (1, 2, 3...) so the user can easily reference them in follow-up messages.

If two plans are very similar, highlight which is the most recent one and describe the key differences between them.

For each plan that contains a `## Branch` section, check whether the branch still exists by running `git branch --list <branch_name>` and `git branch -r --list 'origin/<branch_name>'`. If the branch no longer exists (neither locally nor on remote), prefix the plan entry with **[STALE - branch deleted]** and note that it is very likely no longer useful and should probably be deleted.

Then ask the user which plans to delete (by number).
