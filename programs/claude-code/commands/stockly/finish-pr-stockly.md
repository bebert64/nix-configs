---
description: Run final checks and prepare PR for merge
---

The user is ready to finalize a PR. Run validation and draft the merge description.

## 1. Identify modified crates

1. Run `git branch --show-current` to get the current branch.
2. Run `git diff --name-only master...HEAD` to list all files changed in this PR.
3. From the changed file paths, determine which workspace crates have been modified (map paths to crate directories listed in the root `Cargo.toml` `[workspace] members`).

## 2. Run checks on each modified crate

For each modified crate, run the following commands **sequentially**. Stop at the first failure.

1. `cargo machete -p <crate_name>` — check for unused dependencies
2. `cargo clippy -p <crate_name>` — lints
3. `cargo test -p <crate_name>` — unit tests

## 3. Run autofix and verify

1. `make autofix` — formatting
2. Verify no files changed after autofix (`git diff --name-only`). If files changed, formatting was not correct before — report which files were modified.

## 4. Whole-workspace checks

Run on the whole workspace (use a long timeout, e.g. ~15 minutes; full-repo checks are slow):
1. `cargo check`
2. `cargo check --tests`

If any command fails, **stop immediately**, report which crate and which check failed, and show the relevant error output. Do not continue to the next steps.

## 5. Draft PR description

1. Run `git log --oneline master..HEAD` to see all commits in the PR.
2. Review the full diff (`git diff master...HEAD`) for context.
3. Generate the PR description using the template at `.github/pull_request_template.md`: fill in everything you can (especially "What it does", inferred from branch name, modified files, and context); only leave placeholders for what you truly don't know (e.g. ticket URL, commit SHA).
4. Present the description to the user for review/editing.

## 6. Look for learnable patterns

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
