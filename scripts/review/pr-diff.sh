#!/usr/bin/env bash
# Command helper — injects a markdown branch change overview as context
# Outputs metadata only (stats, file list, commits). Full diffs are NOT
# included — consumers should read per-file diffs on demand via
# git diff <DIFF_BASE> -- <file>

set -euo pipefail

if [[ $# -gt 0 ]]; then
  TARGET_BRANCH="$1"
else
  TARGET_BRANCH=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@') || true
  if [ -z "$TARGET_BRANCH" ]; then
    for candidate in main master; do
      if git show-ref --verify --quiet "refs/remotes/origin/$candidate"; then
        TARGET_BRANCH="$candidate"
        break
      fi
    done
  fi
  if [ -z "$TARGET_BRANCH" ]; then
    echo "Error: could not detect default branch. Pass it as an argument: pr-diff.sh <branch>" >&2
    exit 1
  fi
fi

if [[ ! "$TARGET_BRANCH" =~ ^[a-zA-Z0-9_./-]+$ ]]; then
  echo "Error: invalid branch name: $TARGET_BRANCH" >&2
  exit 1
fi

git fetch origin "$TARGET_BRANCH" >/dev/null 2>&1 || {
  echo "Warning: could not fetch origin/${TARGET_BRANCH}; using local refs." >&2
}

DIFF_BASE=$(git merge-base HEAD "origin/$TARGET_BRANCH")
STAT=$(git diff --stat "$DIFF_BASE")
UNTRACKED=$(git ls-files --others --exclude-standard)
COMMITS=$(git log "$DIFF_BASE..HEAD" --oneline)

printf '## Branch Change Overview\n\n'
printf 'DIFF_BASE: %s\n\n' "$DIFF_BASE"

printf '### Changed Files\n\n%s\n\n' "${STAT:-(none)}"
printf '### Untracked Files\n\n%s\n\n' "${UNTRACKED:-(none)}"
printf '### Commits\n\n%s\n\n' "${COMMITS:-(none)}"
