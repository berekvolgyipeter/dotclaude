#!/bin/bash
# PreToolUse hook: auto-approve operations on .claude/ subdirectories
# that the normal permission system blocks due to built-in
# command-injection detection on the .claude/ path.
#
# Claude Code treats any tool invocation touching ".claude/" as potentially
# dangerous and prompts for manual approval. This hook whitelists specific
# safe directories and commands so that skills like code-review and PRP
# generation can work without repeated user confirmations.
#
# How it works:
#   1. Reads the JSON tool-call payload from stdin.
#   2. Extracts the tool name and relevant inputs (command, file_path, etc.).
#   3. Checks the invocation against the whitelist:
#      - ALLOWED_READ_SEARCH_DIRS — global ~/.claude/ dirs for Read/Grep/Glob
#   4. If a match is found, emits a JSON "allow" decision and exits.
#      Otherwise falls through with exit 0 (no opinion — default behaviour).

# --- Parse the incoming tool-call JSON from stdin ---
INPUT=$(cat)
TOOL=$(jq -r '.tool_name // empty' <<< "$INPUT")
FILE=$(jq -r '.tool_input.file_path // empty' <<< "$INPUT")

# --- Helper: emit an "allow" decision and exit immediately ---
approve() {
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: $reason
    }
  }' --arg reason "$1"
  exit 0
}

# --- Whitelists ---

# Resolve the real repo path even when invoked via ~/.claude/hooks/ symlink,
# so paths match regardless of whether Claude uses the symlink or repo path.
DOTCLAUDE_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd "$(pwd -P)/.." && pwd -P)"

# Global ~/.claude/ directories that Read, Grep, and Glob may access.
# These house the shared config managed by the dotclaude repo.
ALLOWED_READ_SEARCH_DIRS=(
  "$HOME/.claude/skills-references"
  "$HOME/.claude/skills"
  "$HOME/.claude/commands"
  "$HOME/.claude/rules"
  "$HOME/.claude/context-rules"
  "$HOME/.claude/agents"
  "$HOME/.claude/templates"
  "$HOME/.claude/hooks"
  "$HOME/.claude/shared"
  "$DOTCLAUDE_REPO/skills"
  "$DOTCLAUDE_REPO/commands"
  "$DOTCLAUDE_REPO/rules"
  "$DOTCLAUDE_REPO/context-rules"
  "$DOTCLAUDE_REPO/agents"
  "$DOTCLAUDE_REPO/templates"
  "$DOTCLAUDE_REPO/hooks"
  "$DOTCLAUDE_REPO/shared"
)

# --- Matching helpers ---

# Check if a path falls under one of the global ALLOWED_READ_SEARCH_DIRS.
# Matches the directory itself or any descendant path.
match_read_search() {
  local path="$1"
  for dir in "${ALLOWED_READ_SEARCH_DIRS[@]}"; do
    case "$path" in
      "$dir"|"$dir"/*) return 0 ;;
    esac
  done
  return 1
}

# --- Per-tool approval logic ---

if [ "$TOOL" = "Read" ]; then
  match_read_search "$FILE" && approve "Auto-approved ~/.claude/ read"
fi

if [ "$TOOL" = "Grep" ]; then
  PATH_ARG=$(jq -r '.tool_input.path // empty' <<< "$INPUT")
  match_read_search "$PATH_ARG" && approve "Auto-approved ~/.claude/ grep"
fi

if [ "$TOOL" = "Glob" ]; then
  PATH_ARG=$(jq -r '.tool_input.path // empty' <<< "$INPUT")
  PATTERN=$(jq -r '.tool_input.pattern // empty' <<< "$INPUT")
  match_read_search "$PATH_ARG" && approve "Auto-approved ~/.claude/ glob"
  match_read_search "$PATTERN" && approve "Auto-approved ~/.claude/ glob pattern"
fi

# No match — exit without a decision (default permission behaviour applies).
exit 0
