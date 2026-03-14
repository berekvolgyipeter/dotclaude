#!/bin/bash
# PreToolUse hook (Bash): block recursive force-delete commands.
#
# Exits with code 2 (blocking) when the command matches all three conditions:
#   1. Contains an `rm` invocation (possibly chained with ; && || |)
#   2. Has a recursive flag  (-r / -R / --recursive)
#   3. Has a force flag      (-f / -F / --force)
#
# Combination flags like `-rf` and `-fr` are caught by conditions 2 & 3.

CMD=$(jq -r '.tool_input.command')

has_rm()        { echo "$CMD" | grep -qiE '(^|;[[:space:]]*|&&[[:space:]]*|[|][|][[:space:]]*|[|][[:space:]]*)rm[[:space:]]'; }
has_recursive() { echo "$CMD" | grep -qiE '(^|[[:space:]])-[a-zA-Z]*[rR]|--recursive'; }
has_force()     { echo "$CMD" | grep -qiE '(^|[[:space:]])-[a-zA-Z]*[fF]|--force'; }

if has_rm && has_recursive && has_force; then
  echo 'BLOCKED: Use trash instead of rm -rf' >&2
  exit 2
fi
