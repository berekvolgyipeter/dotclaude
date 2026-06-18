#!/bin/sh
# Indexes all plugin-browser reference repos via the claude-context MCP server.

exec python3 "$HOME/.claude/scripts/index_codebase.py" "$HOME/.claude/skills-references/plugin-browser"
