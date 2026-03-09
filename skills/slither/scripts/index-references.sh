#!/bin/sh
# Indexes all slither reference repos via the claude-context MCP server.

exec "$HOME/.claude/scripts/index-codebase.sh" "$HOME/.claude/skills-references/slither"
