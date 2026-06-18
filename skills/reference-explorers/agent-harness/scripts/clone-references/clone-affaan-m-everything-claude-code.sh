#!/usr/bin/env bash
# Clones affaan-m/everything-claude-code into ~/.claude/skills-references/agent-harness/affaan-m-everything-claude-code/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/agent-harness/affaan-m-everything-claude-code"
REPO_URL="https://github.com/affaan-m/everything-claude-code.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating affaan-m/everything-claude-code..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning affaan-m/everything-claude-code..."
    git clone --quiet "$REPO_URL" "$DEST"
fi

echo "Done — affaan-m/everything-claude-code repo available at $DEST"
