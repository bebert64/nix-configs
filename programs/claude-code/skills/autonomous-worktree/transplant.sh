#!/usr/bin/env bash
set -euo pipefail

source_worktree="${1:?[transplant] Usage: transplant.sh <source_worktree_path> <target_worktree_path>}"
target_worktree="${2:?[transplant] Usage: transplant.sh <source_worktree_path> <target_worktree_path>}"

# --- Validate paths exist and are git worktrees ---
for path in "$source_worktree" "$target_worktree"; do
    if [[ ! -d "$path" ]]; then
        echo "[transplant] Error: path does not exist: $path" >&2
        exit 1
    fi
    if ! git -C "$path" rev-parse --is-inside-work-tree &>/dev/null; then
        echo "[transplant] Error: not a git worktree: $path" >&2
        exit 1
    fi
done

# --- Check source has no uncommitted changes ---
if [[ -n "$(git -C "$source_worktree" status --porcelain)" ]]; then
    echo "[transplant] Error: source worktree has uncommitted changes: $source_worktree" >&2
    exit 1
fi

# --- Get source branch name (fail on detached HEAD) ---
source_branch="$(git -C "$source_worktree" branch --show-current)"
if [[ -z "$source_branch" ]]; then
    echo "[transplant] Error: source worktree is in detached HEAD state" >&2
    exit 1
fi

# --- Detect main branch name ---
main_branch=""
if ref="$(git -C "$source_worktree" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null)"; then
    main_branch="${ref##refs/remotes/origin/}"
fi
if [[ -z "$main_branch" ]]; then
    if git -C "$source_worktree" rev-parse --verify origin/main &>/dev/null; then
        main_branch="main"
    elif git -C "$source_worktree" rev-parse --verify origin/master &>/dev/null; then
        main_branch="master"
    else
        echo "[transplant] Error: cannot detect main branch (tried origin/main and origin/master)" >&2
        exit 1
    fi
fi

# --- Compute merge base ---
merge_base="$(git -C "$source_worktree" merge-base "origin/$main_branch" HEAD)"

# --- Get commit list ---
mapfile -t commits < <(git -C "$source_worktree" rev-list --reverse "$merge_base..HEAD")
commit_count="${#commits[@]}"

# --- Cherry-pick onto target ---
if [[ "$commit_count" -eq 0 ]]; then
    echo "[transplant] No commits to transplant."
else
    echo "[transplant] Transplanting $commit_count commit(s) onto target..."
    if ! git -C "$target_worktree" cherry-pick "${commits[@]}" 2>&1; then
        echo "[transplant] Error: cherry-pick failed due to conflict. Aborting cherry-pick." >&2
        git -C "$target_worktree" cherry-pick --abort 2>/dev/null || true
        exit 1
    fi
fi

# --- Cleanup: remove source worktree and its branch ---
echo "[transplant] Removing source worktree: $source_worktree"
git -C "$target_worktree" worktree remove "$source_worktree"
echo "[transplant] Deleting source branch: $source_branch"
git -C "$target_worktree" branch -D "$source_branch"

# --- Summary ---
target_branch="$(git -C "$target_worktree" branch --show-current)"
echo "[transplant] Done. $commit_count commit(s) transplanted onto branch: $target_branch"
