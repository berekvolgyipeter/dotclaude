#!/bin/sh
# Indexes all plugin-browser reference repos via the claude-context MCP server.

exec "$HOME/.claude/scripts/index-codebase.sh" "$HOME/.claude/skills-references/plugin-browser"
