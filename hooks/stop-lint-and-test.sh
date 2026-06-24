#!/bin/bash
# Stop hook: run `make lint` and `make test` if Edit or Write tools were used.
#
# Parses the session transcript to detect file-modifying tool usage.
# If none found, exits silently. If found, runs lint and test targets.
# Exit 2 tells Claude Code to block and continue; any other non-zero exit is a hard error.

# 🤘 Hooks in you, hooks in me, hooks in the ceiling
#    For that well hung feeling
#    No big deal, no big sin, strung up on love
#    I got the hooks screwed in
#                              — Iron Maiden, Hooks in You

set -euo pipefail

# Opt-out: set DOTCLAUDE_DISABLE_AUTO_LINT / DOTCLAUDE_DISABLE_AUTO_TEST to 1 (or true) to skip lint
# / test respectively.
is_disabled() {
  case "${1:-}" in
    1|true|True|TRUE|yes|YES) return 0 ;;
  esac
  return 1
}

# Exit early if both targets are opted out — nothing to run, so skip the
# transcript parsing and Makefile discovery below.
if is_disabled "${DOTCLAUDE_DISABLE_AUTO_LINT:-}" && is_disabled "${DOTCLAUDE_DISABLE_AUTO_TEST:-}"; then
  exit 0
fi

INPUT=$(cat)

STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // empty')
[ "${STOP_HOOK_ACTIVE:-false}" = "true" ] && exit 0

TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path')
if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Check if Edit or Write tools were used in the session (excluding gitignored files)
EDITED_FILES=$(jq -rs '[.[].message? // empty | select(.role == "assistant") | .content[]? | select(.type == "tool_use") | select(.name == "Edit" or .name == "Write") | .input.file_path // empty] | unique | .[]' "$TRANSCRIPT" 2>/dev/null) || EDITED_FILES=""

HAS_EDITS=0
if [ -n "$EDITED_FILES" ]; then
  # When CWD is absent, git check-ignore will likely fail (not a git repo);
  # in that case all files are treated as non-ignored (fail-safe: run lint).
  GIT_ROOT="${CWD:-$(dirname "$TRANSCRIPT")}"
  while IFS= read -r file; do
    if ! git -C "$GIT_ROOT" check-ignore -q "$file" 2>/dev/null; then
      HAS_EDITS=1
      break
    fi
  done <<< "$EDITED_FILES"
fi

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

# Honor per-target opt-outs
is_disabled "${DOTCLAUDE_DISABLE_AUTO_LINT:-}" && HAS_LINT=0
is_disabled "${DOTCLAUDE_DISABLE_AUTO_TEST:-}" && HAS_TEST=0

# Exit only if NEITHER target is available; if at least one exists, proceed
if [ "$HAS_LINT" -eq 0 ] && [ "$HAS_TEST" -eq 0 ]; then
  exit 0
fi

FAILED=0

# Each target runs independently — unavailable targets are skipped, not blocking
# Output goes directly to stderr so make's streaming output is not buffered
if [ "$HAS_LINT" -eq 1 ]; then
  make lint 2>&1 || FAILED=1
fi

if [ "$HAS_TEST" -eq 1 ]; then
  make test 2>&1 || FAILED=1
fi

if [ "$FAILED" -ne 0 ]; then
  echo "Fix all errors above before finishing." >&2
  exit 2
fi
