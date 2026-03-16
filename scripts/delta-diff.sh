#!/usr/bin/env bash
# Command helper — injects a markdown local diff overview as context

set -euo pipefail

STAT=$(git diff --stat HEAD)
UNTRACKED=$(git ls-files --others --exclude-standard)
DIFF=$(git diff HEAD)

printf '## Local Change Overview\n\n'

printf '### Changed Files\n\n%s\n\n' "${STAT:-(none)}"
printf '### Untracked Files\n\n%s\n\n' "${UNTRACKED:-(none)}"
printf '### Diff\n\n%s\n\n' "${DIFF:-(none)}"

if [[ -n "$UNTRACKED" ]]; then
  printf '### Untracked File Contents\n\n'
  while IFS= read -r file; do
    printf '#### %s\n\n' "$file"
    cat "$file"
    printf '\n\n'
  done <<< "$UNTRACKED"
fi
