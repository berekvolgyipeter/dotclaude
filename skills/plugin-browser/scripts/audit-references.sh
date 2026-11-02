#!/bin/sh
# Reports upstream layout changes in the plugin-browser reference repos against their sparse patterns.

exec python3 "$HOME/.claude/scripts/skill_references.py" audit "$HOME/.claude/skills/plugin-browser"
