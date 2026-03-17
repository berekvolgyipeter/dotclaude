#!/bin/bash
# Stop hook: run `make lint` and `make test` if Edit or Write tools were used.
#
# Parses the session transcript to detect file-modifying tool usage.
# If none found, exits silently. If found, runs lint and test targets.
# Exit 2 tells Claude Code to block and continue; any other non-zero exit is a hard error.

set -euo pipefail

INPUT=$(cat)

STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active')
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path')
if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Check if Edit or Write tools were used in the session
HAS_EDITS=$(jq -s '[.[].message? // empty | select(.role == "assistant") | .content[]? | select(.type == "tool_use") | .name] | map(select(. == "Edit" or . == "Write")) | length' "$TRANSCRIPT" 2>/dev/null) || HAS_EDITS=0
[[ "$HAS_EDITS" =~ ^[0-9]+$ ]] || HAS_EDITS=0

if [ "$HAS_EDITS" -eq 0 ]; then
  exit 0
fi

# Guard: make must be available
command -v make >/dev/null 2>&1 || exit 0

# Locate Makefile by walking up from the project working directory
PROJECT_ROOT="${CWD:-$(dirname "$TRANSCRIPT")}"
while [ "$PROJECT_ROOT" != "/" ] && [ ! -f "$PROJECT_ROOT/Makefile" ] && [ ! -f "$PROJECT_ROOT/makefile" ] && [ ! -f "$PROJECT_ROOT/GNUmakefile" ]; do
  PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
done
if [ ! -f "$PROJECT_ROOT/Makefile" ] && [ ! -f "$PROJECT_ROOT/makefile" ] && [ ! -f "$PROJECT_ROOT/GNUmakefile" ]; then
  exit 0
fi
cd "$PROJECT_ROOT"

# Check which targets are available in the Makefile
HAS_LINT=0
HAS_TEST=0
make -n lint >/dev/null 2>&1 && HAS_LINT=1
make -n test >/dev/null 2>&1 && HAS_TEST=1

# Exit only if NEITHER target is available; if at least one exists, proceed
if [ "$HAS_LINT" -eq 0 ] && [ "$HAS_TEST" -eq 0 ]; then
  exit 0
fi

FAILED=0

# Each target runs independently — unavailable targets are skipped, not blocking
# Output goes to stdout so Claude receives it when exit 2 triggers a continue
if [ "$HAS_LINT" -eq 1 ]; then
  LINT_OUT=$(make lint 2>&1) || { FAILED=1; echo "$LINT_OUT" >&2; }
fi

if [ "$HAS_TEST" -eq 1 ]; then
  TEST_OUT=$(make test 2>&1) || { FAILED=1; echo "$TEST_OUT" >&2; }
fi

if [ "$FAILED" -ne 0 ]; then
  echo "Fix all errors above before finishing." >&2
  exit 2
fi
