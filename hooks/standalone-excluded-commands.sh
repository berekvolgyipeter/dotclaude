#!/bin/bash
# PreToolUse (Bash): deny calls mixing a sandbox.excludedCommands entry with other commands — those run sandboxed.

CMD=$(jq -r '.tool_input.command // empty')
SETTINGS="$(dirname "$(readlink -f "$0")")/../settings.json"

# Drop heredoc bodies, quoted strings and 2>&1-style fd duplications, then exit if it's a single plain command
S=$(perl -0pe "s/<<-?\s*['\"]?(\w+)['\"]?(.*?)\n.*?\n\s*\1(?=\n|\$)/<<\2/gs; s/'[^']*'//g; s/\"[^\"]*\"//g; s/[0-9]*>&[0-9-]+//g" <<< "$CMD")
grep -qE '[|;&<>`]|\$\(|(^|[[:space:]])cd[[:space:]]' <<< "$S" || [[ "$S" == *$'\n'* ]] || exit 0

jq -r '.sandbox.excludedCommands[]' "$SETTINGS" | while read -r p; do
  p="${p% \*}"
  # Escape regex metacharacters; a `*` inside an entry (e.g. `git -C * fetch`) matches one argument
  if grep -qE "(^|[|;&(\`]|\\\$\\()[[:space:]]*$(sed -E 's/[][\.^$+?(){}|/]/\\&/g; s/\*/[^[:space:]]*/g' <<< "$p")([[:space:]]|$)" <<< "$S"; then
    jq -n --arg p "$p" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
      permissionDecisionReason: ("`" + $p + "` must be the ONLY command in its Bash call — no |, &&, ||, ;, cd, $() or redirects. Run it alone.")}}'
    break
  fi
done
