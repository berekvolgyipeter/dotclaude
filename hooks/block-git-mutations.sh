#!/bin/bash
# PreToolUse hook (Bash): block state-mutating git commands.

CMD=$(jq -r '.tool_input.command')

MUTATING='add|rm|mv|restore|checkout|switch|reset|stash|commit|merge|rebase|cherry-pick|revert|apply|am|clean|push'

if echo "$CMD" | grep -qE "(^|[^[:alnum:]_-])git[[:space:]]+($MUTATING)([[:space:]]|$)"; then
  echo 'BLOCKED: State-mutating git commands are not allowed' >&2
  exit 2
fi
