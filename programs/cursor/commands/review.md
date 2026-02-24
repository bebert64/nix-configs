---
description: Review the current PR's changes
---

The user wants a code review of ALL changes introduced by the current PR branch (not just uncommitted changes).

1. Determine the base branch (usually `main` or `master`) and diff the full PR: `git diff <base>...HEAD` plus any uncommitted changes.
2. Review the changes and provide feedback on:
   - Correctness and potential bugs
   - Idiomatic style (proper error handling with the project's error library, use of iterators, avoid unnecessary clones)
   - Missing or incorrect error handling
   - Performance concerns
   - Any TODO/FIXME left behind
3. Be concise. Group feedback by file. Highlight the most important issues first.
