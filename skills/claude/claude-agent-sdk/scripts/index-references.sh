#!/bin/sh
# Indexes all claude-agent-sdk reference repos via the claude-context MCP server.

exec python3 "$HOME/.claude/scripts/index_codebase.py" "$HOME/.claude/skills-references/claude-agent-sdk"
