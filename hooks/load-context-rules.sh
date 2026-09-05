#!/bin/bash
# PreToolUse hook: load contextual rule files on first Edit/Write per session
#
# When Claude edits or writes a file, this hook checks the file path against
# predefined patterns. If matched and the rule hasn't been loaded yet in this
# session, it injects the rule file content into context via additionalContext.
#
# Deduplication: each injected rule is tagged with a marker comment
# (<!-- rule:NAME -->). Before loading, the hook greps the session transcript
# for that marker — if found, the rule is skipped. No temp files needed.
#
# Opt-out: set DOTCLAUDE_DISABLE_CONTEXT_RULES_HOOK=1 (or true) to skip this hook.

case "${DOTCLAUDE_DISABLE_CONTEXT_RULES_HOOK:-}" in
  1|true|True|TRUE|yes|YES) exit 0 ;;
esac

# --- Rules: parallel arrays mapping rule names to glob patterns (pipe-delimited)
RULE_NAMES=(
  "py-code"
  "py-test"
  "ts-code"
  "docs"
)
RULE_PATHS=(
  "*.py"
  "*/test/*.py|test/*.py|*/tests/*.py|tests/*.py|*/test_*.py|test_*.py|*_test.py"
  "*.ts|*.tsx|*.mts|*.cts"
  "*.md"
)

# --- Parse hook input
INPUT=$(cat)
FILE=$(jq -r '.tool_input.file_path // empty' <<< "$INPUT")
[ -z "$FILE" ] && exit 0
TRANSCRIPT=$(jq -r '.transcript_path // empty' <<< "$INPUT")

# Match file against pipe-delimited patterns
matches_any() {
  local file="$1" patterns="$2"
  IFS='|' read -ra pattern_list <<< "$patterns"
  for pattern in "${pattern_list[@]}"; do
    # shellcheck disable=SC2254 # intentional glob matching
    case "$file" in $pattern) return 0 ;; esac
  done
  return 1
}

# Fast-path: exit early if no rule pattern matches the file at all,
# avoiding the transcript grep and file reads in the main loop.
match_found=false
for patterns in "${RULE_PATHS[@]}"; do
  matches_any "$FILE" "$patterns" && { match_found=true; break; }
done
[ "$match_found" = true ] || exit 0

# Resolve dotclaude repo path (works even when invoked via ~/.claude/ symlink)
DOTCLAUDE_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd "$(pwd -P)/.." && pwd -P)"

# Format the dedup marker for a given rule name
rule_marker() {
  echo "<!-- rule:$1 -->"
}

# Check whether a rule marker already appears in the session transcript
is_rule_loaded() {
  local marker
  marker=$(rule_marker "$1")
  [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ] && grep -qF "$marker" "$TRANSCRIPT" 2>/dev/null
}

# Collect rule content for matching, not-yet-loaded rules
CONTENT=""

for i in "${!RULE_NAMES[@]}"; do
  rule="${RULE_NAMES[$i]}"
  matches_any "$FILE" "${RULE_PATHS[$i]}" || continue
  is_rule_loaded "$rule" && continue

  RULE_FILE="$DOTCLAUDE_REPO/context-rules/${rule}.md"
  [ ! -f "$RULE_FILE" ] && continue

  # Tag with marker for dedup, then append rule content
  CONTENT+="$(rule_marker "$rule")"$'\n'
  CONTENT+="$(cat "$RULE_FILE")"$'\n'
done

# Exit if all matched rules were already loaded
[ -z "$CONTENT" ] && exit 0

# Inject rule content as additional context (no permission decision)
jq -n --arg ctx "$CONTENT" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: $ctx
  }
}'
