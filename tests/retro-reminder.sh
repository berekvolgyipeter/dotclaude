#!/usr/bin/env bash
# Behavior tests for hooks/retro-reminder.sh (the SessionStart retro reminder).
# Each case gives the hook a throwaway HOME with a retros folder, pipes SessionStart JSON to it, and checks whether
# it reminds.

set -uo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/hooks/retro-reminder.sh"
FAILS=0

# new_case — a throwaway HOME with an empty retros folder
new_case() {
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/retro-reminder.XXXXXX")" || exit 1
  RETROS="$WORK/.claude/retros"
  mkdir -p "$RETROS"
}

# days_ago <n> — the date n days before today, as YYYY-MM-DD (BSD date, else GNU date)
days_ago() {
  date -v-"$1"d +%F 2>/dev/null || date -d "-$1 days" +%F
}

# report_file <file name> — an empty report in the retros folder
report_file() {
  : >"$RETROS/$1"
}

# run_hook <source> [interval] — sets OUT and STATUS; a given interval is set in DOTCLAUDE_RETRO_REMINDER_DAYS
run_hook() {
  local input
  input="$(jq -cn --arg s "$1" '{hook_event_name: "SessionStart", source: $s}')"
  if [ $# -ge 2 ]; then
    OUT="$(DOTCLAUDE_RETRO_REMINDER_DAYS="$2" HOME="$WORK" bash "$HOOK" <<<"$input")"
  else
    OUT="$(env -u DOTCLAUDE_RETRO_REMINDER_DAYS HOME="$WORK" bash "$HOOK" <<<"$input")"
  fi
  STATUS=$?
}

# check <name> <reminds|silent>
check() {
  local is_ok=0
  if [ "$STATUS" = 0 ]; then
    case "$2" in
      reminds) jq -e '.hookSpecificOutput.hookEventName == "SessionStart"
        and (.hookSpecificOutput.additionalContext | contains("/retro full") and (contains("snooze") | not))
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

new_case
run_hook startup
check "a fresh start with no full report yet reminds" reminds

new_case
report_file "$(date +%F)-full.md"
run_hook startup
check "a fresh start the day of a full report is silent" silent

new_case
report_file "$(days_ago 6)-full-2.md"
run_hook startup
check "a full report within the last 7 days silences the reminder, numbered reports included" silent

new_case
report_file "$(days_ago 7)-full.md"
run_hook startup
check "a full report 7 days old reminds" reminds

new_case
report_file "$(date +%F)-session.md"
report_file "$(date +%F)-change.md"
report_file "unapplied-learnings.md"
run_hook startup
check "only files that are not full reports still remind" reminds

new_case
report_file "$(days_ago 10)-full.md"
run_hook startup 30
check "a longer interval keeps a 10-day-old full report silent" silent

new_case
report_file "$(days_ago 10)-full.md"
run_hook startup 99999999999
check "an interval too large for a date keeps any full report silent" silent

new_case
report_file "$(days_ago 3)-full.md"
run_hook startup 2
check "a shorter interval reminds about a 3-day-old full report" reminds

new_case
run_hook startup 0
check "an interval of 0 turns the reminder off" silent

for interval in abc -3 "7 days"; do
  new_case
  report_file "$(date +%F)-full.md"
  run_hook startup "$interval"
  check "a malformed interval ($interval) reminds" reminds
done

for source in resume clear compact; do
  new_case
  run_hook "$source"
  check "a $source start is silent even when due" silent
done

if [ "$FAILS" -ne 0 ]; then
  echo "$FAILS failed"
  exit 1
fi
echo "all passed"
