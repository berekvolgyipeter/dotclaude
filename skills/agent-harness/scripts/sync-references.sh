#!/bin/sh
# Clones or updates all agent-harness reference repos listed in the catalog.

exec python3 "$HOME/.claude/scripts/skill_references.py" sync "$HOME/.claude/skills/agent-harness"
