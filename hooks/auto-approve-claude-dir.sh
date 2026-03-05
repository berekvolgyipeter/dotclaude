#!/bin/bash
# PreToolUse hook: auto-approve operations on .claude/ subdirectories
# (mkdir, Write) that the normal permission system blocks due to
# built-in command-injection detection on the .claude/ path.

INPUT=$(cat)
TOOL=$(jq -r '.tool_name // empty' <<< "$INPUT")
CMD=$(jq -r '.tool_input.command // empty' <<< "$INPUT")
FILE=$(jq -r '.tool_input.file_path // empty' <<< "$INPUT")

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

# Auto-approve: mkdir for .claude/.code-reviews and .claude/PRPs subdirectories only
if [ "$TOOL" = "Bash" ]; then
  case "$CMD" in
    "mkdir -p .claude/.code-reviews"|"mkdir -p "*/.claude/.code-reviews) approve "Auto-approved .claude/.code-reviews/ creation" ;;
    "mkdir -p .claude/PRPs"|"mkdir -p "*/.claude/PRPs)                  approve "Auto-approved .claude/PRPs/ creation" ;;
  esac
fi

# Auto-approve: Write to .claude/.code-reviews/*.md or .claude/PRPs/*.md
if [ "$TOOL" = "Write" ]; then
  case "$FILE" in
    .claude/.code-reviews/*.md|*/.claude/.code-reviews/*.md) approve "Auto-approved .claude/.code-reviews/ write" ;;
    .claude/PRPs/*.md|*/.claude/PRPs/*.md)                  approve "Auto-approved .claude/PRPs/ write" ;;
  esac
fi

exit 0
