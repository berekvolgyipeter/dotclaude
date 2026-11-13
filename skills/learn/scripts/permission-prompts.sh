#!/usr/bin/env bash
# Lists the tool calls the user answered a permission prompt for: "<source>\t<tool> <command or input>".
# Usage: permission-prompts.sh [transcript.jsonl]  (default: the newest session transcript)
set -euo pipefail

# shellcheck disable=SC2012  # transcript names are UUIDs; ls -t is the simplest newest-first
f="${1:-$(ls -t ~/.claude/projects/*/*.jsonl | head -1)}"

jq -s -r '
  (map(select(.type == "assistant") | .message.content[]? | select(.type == "tool_use")
       | {key: .id, value: (.name + " " + (.input.command // .input.file_path // .input | tostring))})
   | from_entries) as $calls
  | .[] | select(.permissionDecision.source | tostring | startswith("user_"))
  | .permissionDecision.source as $s
  | .message.content[]? | select(.type == "tool_result") | "\($s)\t\($calls[.tool_use_id] // "?")"' "$f"
