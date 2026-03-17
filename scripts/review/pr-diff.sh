#!/usr/bin/env bash
# Command helper — injects a markdown branch change overview as context
# Outputs metadata only (stats, file list, commits). Full diffs are NOT
# included — consumers should read per-file diffs on demand via
# git diff <DIFF_BASE> -- <file>

set -euo pipefail

if [[ $# -gt 0 ]]; then
  TARGET_BRANCH="$1"
else
  TARGET_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
fi

git fetch origin "$TARGET_BRANCH" >/dev/null

DIFF_BASE=$(git merge-base HEAD "origin/$TARGET_BRANCH")
STAT=$(git diff --stat "$DIFF_BASE")
UNTRACKED=$(git ls-files --others --exclude-standard)
COMMITS=$(git log "$DIFF_BASE..HEAD" --oneline)

printf '## Branch Change Overview\n\n'
printf 'DIFF_BASE: %s\n\n' "$DIFF_BASE"

printf '### Changed Files\n\n%s\n\n' "${STAT:-(none)}"
printf '### Untracked Files\n\n%s\n\n' "${UNTRACKED:-(none)}"
printf '### Commits\n\n%s\n\n' "${COMMITS:-(none)}"
