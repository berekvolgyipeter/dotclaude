#!/bin/bash
# SessionStart: list sandbox.excludedCommands and how to call them so they stay unsandboxed.

SETTINGS="$(dirname "$(readlink -f "$0")")/../settings.json"

printf '%s\n' \
  "IMPORTANT: run each excluded command below as the ONLY command in its Bash call." \
  "No |, &&, ||, ;, cd, \$(), backticks (even escaped ones) or redirects; otherwise it is sandboxed and fails." \
  "Put text that contains backticks in a file and pass the file (e.g. glab api -F description=@file)." \
  "Excluded commands: $(jq -r '.sandbox.excludedCommands | join(", ")' "$SETTINGS")"
