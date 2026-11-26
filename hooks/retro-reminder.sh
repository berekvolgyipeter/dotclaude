#!/bin/bash
# SessionStart: on a fresh start, once no full retro report is dated within the reminder interval, have Claude open
# its first reply with the reminder.
# DOTCLAUDE_RETRO_REMINDER_DAYS sets the interval (default 7); 0 turns the reminder off.

set -euo pipefail

[ "$(jq -r '.source // empty')" = "startup" ] || exit 0

# Only a well-formed interval can silence it, so a slip in the setting brings the reminder back instead of hiding it.
days="${DOTCLAUDE_RETRO_REMINDER_DAYS:-7}"
if [[ "$days" =~ ^[0-9]+$ ]]; then
  ((10#$days == 0)) && exit 0
  # An interval too large for date reaches back before any report, so every report counts as recent.
  cutoff="$(date -v-"${days}"d +%F 2>/dev/null || date -d "-${days} days" +%F 2>/dev/null || echo 0000-00-00)"
  for report in "$HOME"/.claude/retros/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-full{,-*}.md; do
    [ -e "$report" ] || continue
    name="$(basename "$report")"
    [[ "${name:0:10}" > "$cutoff" ]] && exit 0
  done
fi

REMINDER="A harness retro is due: /retro full"
jq -cn --arg reminder "$REMINDER" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: ("Open your first reply with this line, as is, then answer as usual: " + $reminder)
  },
  systemMessage: $reminder
}'
