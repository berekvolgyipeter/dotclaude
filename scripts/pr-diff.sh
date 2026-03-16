#!/usr/bin/env bash
# Command helper — injects a markdown branch diff overview as context

set -euo pipefail

if [[ $# -gt 0 ]]; then
  TARGET_BRANCH="$1"
else
  TARGET_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
fi

git fetch origin "$TARGET_BRANCH" >/dev/null

MERGE_BASE=$(git merge-base HEAD "origin/$TARGET_BRANCH")
STAT=$(git diff --stat "$MERGE_BASE")
UNTRACKED=$(git ls-files --others --exclude-standard)
COMMITS=$(git log "$MERGE_BASE..HEAD" --oneline)
DIFF=$(git diff "$MERGE_BASE")

printf '## Branch Change Overview\n\n'
printf 'MERGE_BASE: %s\n\n' "$MERGE_BASE"

printf '### Changed Files\n\n%s\n\n' "${STAT:-(none)}"
printf '### Untracked Files\n\n%s\n\n' "${UNTRACKED:-(none)}"
printf '### Commits\n\n%s\n\n' "${COMMITS:-(none)}"
printf '### Diff\n\n%s\n\n' "${DIFF:-(none)}"

if [[ -n "$UNTRACKED" ]]; then
  printf '### Untracked File Contents\n\n'
  while IFS= read -r file; do
    printf '#### %s\n\n' "$file"
    cat "$file"
    printf '\n\n'
  done <<< "$UNTRACKED"
fi
