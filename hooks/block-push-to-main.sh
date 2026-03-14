#!/bin/bash
# PreToolUse hook (Bash): block direct git push to main/master.
#
# Exits with code 2 (blocking) when the command looks like
# `git push ... main` or `git push ... master`.

CMD=$(jq -r '.tool_input.command')

if echo "$CMD" | grep -qE 'git[[:space:]]+push.*\b(main|master|develop)\b'; then
  echo 'BLOCKED: Use feature branches, not direct push to main/master/develop' >&2
  exit 2
fi
