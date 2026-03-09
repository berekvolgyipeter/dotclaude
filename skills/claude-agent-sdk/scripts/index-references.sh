#!/bin/sh
# Indexes all claude-agent-sdk reference repos via the claude-context MCP server.

exec "$HOME/.claude/scripts/index-codebase.sh" "$HOME/.claude/skills-references/claude-agent-sdk"
