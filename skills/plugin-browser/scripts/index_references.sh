#!/bin/sh
# Indexes all plugin-browser reference repos via the claude-context MCP server.
# Run this after clone_references.sh.

exec "$HOME/.claude/scripts/index-codebase.sh" "$HOME/.claude/skills-references/plugin-browser"
