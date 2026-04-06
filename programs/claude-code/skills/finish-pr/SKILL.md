---
description: Run final checks and prepare PR for merge
---

The user is ready to finalize a PR. Run validation and draft the merge description.

## 1. Identify context

1. Run `git branch --show-current` to get the current branch.
2. Run `git rev-parse --abbrev-ref origin/HEAD | sed 's|origin/||'` to detect the default branch (e.g. `main` or `master`). Use this as `<base>` in all subsequent git commands.
3. Run `git diff --name-only <base>...HEAD` to list all files changed in this PR.
4. From the changed file list, determine which language-specific checks apply:
   - **Rust**: a root `Cargo.toml` exists → follow `rust.md`
   - **Nix**: any changed file has a `.nix` extension → follow `nix.md`
   - Both may apply.

## 2. Run language-specific checks

Follow the instructions in `rust.md` and/or `nix.md` as determined above.

If any check fails, **stop immediately**, report which check failed, and show the relevant error output. Do not continue to the next steps.

## 3. Draft PR description

1. Run `git log --oneline <base>..HEAD` to see all commits in the PR.
2. Review the full diff (`git diff <base>...HEAD`) for context.
3. Check whether `.github/pull_request_template.md` exists:
   - **If it exists**: fill in the template (especially "What it does", inferred from branch name, modified files, and context); only leave placeholders for what you truly don't know (e.g. ticket URL, commit SHA).
   - **If it doesn't exist**: write a concise freeform description that lists the main points that changed, grouped logically if there are multiple concerns.
4. Present the description to the user for review/editing.

## 4. Look for learnable patterns

After drafting the PR description, review the full PR diff one more time with a "learning" lens. Look for:

- New coding conventions or patterns that aren't yet captured in any existing rule or skill (e.g., error handling style, module structure, naming conventions, API design patterns).
- Deviations from existing rules that seem intentional and worth updating the rule for.
- Recurring patterns across the PR that suggest a convention the team is settling on.

**Important constraints:**

- **Never create or modify rules/skills automatically.** Only suggest them.
- If you identify something worth learning, present it to the user as a proposal: describe the pattern, suggest whether it should be a new rule or an amendment to an existing one, and quote the relevant code.
- If you'd amend an existing rule, show the current rule content and the proposed change side by side.
- Wait for the user's explicit approval before making any changes.
- If nothing noteworthy is found, simply say so and move on — don't force it.
