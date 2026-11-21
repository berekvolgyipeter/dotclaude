#!/usr/bin/env bash
# Behavior tests for hooks/retro-reminder.sh (the SessionStart retro reminder).
# Each case gives the hook a throwaway HOME with a retros folder, pipes SessionStart JSON to it, and checks whether
# it reminds.

set -uo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/hooks/retro-reminder.sh"
FAILS=0

# new_case [first line of next-due] — a throwaway HOME whose retros folder holds that next-due file, if given
new_case() {
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/retro-reminder.XXXXXX")" || exit 1
  mkdir -p "$WORK/.claude/retros"
  [ $# -ge 1 ] && printf '%s\nsnoozed: 0\n' "$1" >"$WORK/.claude/retros/next-due"
}

# run_hook <source> — sets OUT and STATUS
run_hook() {
  OUT="$(jq -cn --arg s "$1" '{hook_event_name: "SessionStart", source: $s}' | HOME="$WORK" bash "$HOOK")"
  STATUS=$?
}

# check <name> <reminds|silent>
check() {
  local is_ok=0
  if [ "$STATUS" = 0 ]; then
    case "$2" in
      reminds) jq -e '.hookSpecificOutput.hookEventName == "SessionStart"
        and (.hookSpecificOutput.additionalContext | contains("/retro full") and contains("/retro snooze"))
        and (.systemMessage | contains("/retro full"))' <<<"$OUT" >/dev/null 2>&1 && is_ok=1 ;;
      silent) [ -z "$OUT" ] && is_ok=1 ;;
    esac
  fi
  if [ "$is_ok" = 1 ]; then
    echo "ok   - $1"
  else
    echo "FAIL - $1"
    echo "       exit: $STATUS  stdout: $OUT"
    FAILS=$((FAILS + 1))
  fi
  rm -rf "${WORK:?}"
}

# --- behaviors ---

new_case 2000-01-01
run_hook startup
check "a fresh start after the due date reminds" reminds

new_case "$(date +%F)"
run_hook startup
check "a fresh start on the due date reminds" reminds

new_case
run_hook startup
check "a fresh start with no due date yet reminds" reminds

new_case "next-due: 2999-01-01"
run_hook startup
check "a fresh start with a malformed due date reminds" reminds

new_case 2999-01-01
run_hook startup
check "a fresh start before the due date is silent" silent

for source in resume clear compact; do
  new_case 2000-01-01
  run_hook "$source"
  check "a $source start is silent even when due" silent
done

if [ "$FAILS" -ne 0 ]; then
  echo "$FAILS failed"
  exit 1
fi
echo "all passed"
