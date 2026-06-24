#!/usr/bin/env bash
# Command helper — injects a markdown local change overview as context
# Outputs metadata only (stats, file list). Full diffs are NOT included —
# consumers should read per-file diffs on demand via git diff HEAD -- <file>

set -euo pipefail

STAT=$(git diff --stat HEAD)
UNTRACKED=$(git ls-files --others --exclude-standard)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

printf '## Local Change Overview\n\n'
printf 'DIFF_BASE: HEAD\n\n'
printf 'CURRENT_BRANCH: %s\n\n' "$BRANCH"

printf '### Changed Files\n\n%s\n\n' "${STAT:-(none)}"
printf '### Untracked Files\n\n%s\n\n' "${UNTRACKED:-(none)}"
