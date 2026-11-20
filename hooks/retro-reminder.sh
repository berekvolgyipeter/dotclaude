#!/bin/bash
# SessionStart: on a fresh start, once the next full retro is due, have Claude open its first reply with the reminder.

set -euo pipefail

[ "$(jq -r '.source // empty')" = "startup" ] || exit 0

# Only a well-formed future date silences it, so a slip in the file brings the reminder back instead of hiding it.
due="$(head -n 1 "$HOME/.claude/retros/next-due" 2>/dev/null || true)"
if [[ "$due" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ "$due" > "$(date +%F)" ]]; then
  exit 0
fi

REMINDER="A harness retro is due: /retro full · /retro schedule · /retro snooze 3d · /retro dismiss"
jq -cn --arg reminder "$REMINDER" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: ("Open your first reply with this line, as is, then answer as usual: " + $reminder)
  },
  systemMessage: $reminder
}'
