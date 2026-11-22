#!/bin/bash
# Stop hook: run the lint and test commands check-commands.sh resolves in the git root of every
# file edited by Edit or Write; a target with no command gets a reminder to run it by hand.
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

# Resolve through the install symlink, so a newly added script works before `make install` links it.
SELF="${BASH_SOURCE[0]}"
[ -L "$SELF" ] && SELF="$(readlink "$SELF")"
CHECK_COMMANDS="$(dirname "$SELF")/../scripts/check-commands.sh"

INPUT=$(cat)
is_disabled "${DOTCLAUDE_DISABLE_AUTO_LINT:-}" && is_disabled "${DOTCLAUDE_DISABLE_AUTO_TEST:-}" && exit 0
[ "$(jq -r '.stop_hook_active // false' <<<"$INPUT")" = "true" ] && exit 0
TRANSCRIPT=$(jq -r '.transcript_path // empty' <<<"$INPUT")
[ -f "$TRANSCRIPT" ] || exit 0

# Only edits since the last real user prompt count. Tool results and injected meta entries
# (skill bodies, reminders) also carry role "user" but are not prompts.
EDITED=$(jq -rs '
  def prompt: .type == "user" and (.isMeta | not)
    and ((.message.content // []) | type == "string" or any(.[]; .type != "tool_result"));
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
MISSING=0
while IFS= read -r root; do
  [ -n "$root" ] || continue
  notes=()
  # On failure the script's own error reaches stderr, and every target falls back to the reminder.
  commands=$(bash "$CHECK_COMMANDS" "$root") \
    || echo "stop hook — $root: could not resolve the lint and test commands (error above)" >&2
  for target in lint test; do
    [ "$target" = lint ] && is_disabled "${DOTCLAUDE_DISABLE_AUTO_LINT:-}" && continue
    [ "$target" = test ] && is_disabled "${DOTCLAUDE_DISABLE_AUTO_TEST:-}" && continue
    cmd=$(sed -n "s/^$target: //p" <<<"$commands")
    if [ -z "$cmd" ] || [ "$cmd" = none ]; then
      notes+=("no $target target")
      MISSING=1
      continue
    fi
    read -ra argv <<<"$cmd"
    # Runner output goes to stderr so on a block Claude sees the failing log without re-running it.
    if (cd "$root" && "${argv[@]}" >&2 </dev/null); then
      notes+=("$cmd PASSED")
    else
      notes+=("$cmd FAILED")
      FAILED=1
    fi
  done
  [ ${#notes[@]} -gt 0 ] && echo "stop hook — $root: ${notes[*]}" >&2
done <<<"$ROOTS"

if [ "$FAILED" -ne 0 ]; then
  echo "Fix the FAILED targets above before finishing." >&2
fi
if [ "$MISSING" -ne 0 ]; then
  echo "For each missing target, run the project's own lint or test command; if it has none, say so." >&2
fi
if [ "$FAILED" -ne 0 ] || [ "$MISSING" -ne 0 ]; then
  exit 2
fi
exit 0
