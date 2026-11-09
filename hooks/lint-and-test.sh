#!/bin/bash
# Stop hook: run `make lint` / `make test` in the git root of every file edited by Edit or Write.
# Exit 2 tells Claude Code to block and continue; any other non-zero exit is a hard error.

# 🤘 Hooks in you, hooks in me, hooks in the ceiling
#    For that well hung feeling
#    No big deal, no big sin, strung up on love
#    I got the hooks screwed in
#                              — Iron Maiden, Hooks in You

set -uo pipefail

# Opt-out: set DOTCLAUDE_DISABLE_AUTO_LINT / DOTCLAUDE_DISABLE_AUTO_TEST to 1 (or true) to skip lint
# / test respectively.
is_disabled() {
  case "${1:-}" in
    1|true|True|TRUE|yes|YES) return 0 ;;
  esac
  return 1
}

INPUT=$(cat)
[ "$(jq -r '.stop_hook_active // false' <<<"$INPUT")" = "true" ] && exit 0
TRANSCRIPT=$(jq -r '.transcript_path // empty' <<<"$INPUT")
[ -f "$TRANSCRIPT" ] || exit 0
command -v make >/dev/null 2>&1 || exit 0

# Only edits since the last real user prompt count. Tool results and injected meta entries
# (skill bodies, reminders) also carry role "user" but are not prompts.
EDITED=$(jq -rs '
  def prompt: .type == "user" and (.isMeta | not)
    and (.message.content | type == "string" or any(.[]; .type != "tool_result"));
  (map(prompt) | rindex(true) // -1) as $last
  | .[$last + 1:][] | select(.message.role? == "assistant") | .message.content[]?
  | select(.type == "tool_use" and (.name == "Edit" or .name == "Write")) | .input.file_path // empty' \
  "$TRANSCRIPT" 2>/dev/null)

ROOTS=$(while IFS= read -r file; do
  [ -n "$file" ] || continue
  dir=$(dirname "$file")
  git -C "$dir" check-ignore -q "$file" 2>/dev/null && continue
  git -C "$dir" rev-parse --show-toplevel 2>/dev/null
done <<<"$EDITED" | sort -u)

FAILED=0
while IFS= read -r root; do
  [ -n "$root" ] || continue
  notes=()
  for target in lint test; do
    [ "$target" = lint ] && is_disabled "${DOTCLAUDE_DISABLE_AUTO_LINT:-}" && continue
    [ "$target" = test ] && is_disabled "${DOTCLAUDE_DISABLE_AUTO_TEST:-}" && continue
    (cd "$root" && make -n "$target" >/dev/null 2>&1) || continue
    # make output goes to stderr so on a block Claude sees the failing log without re-running it.
    if (cd "$root" && make "$target" >&2); then
      notes+=("$target PASSED")
    else
      notes+=("$target FAILED")
      FAILED=1
    fi
  done
  [ ${#notes[@]} -gt 0 ] && echo "stop hook — $root: ${notes[*]}" >&2
done <<<"$ROOTS"

if [ "$FAILED" -ne 0 ]; then
  echo "Fix the FAILED targets above before finishing." >&2
  exit 2
fi
exit 0
