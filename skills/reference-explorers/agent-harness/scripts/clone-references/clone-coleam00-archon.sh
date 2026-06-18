#!/usr/bin/env bash
# Clones coleam00/archon into ~/.claude/skills-references/agent-harness/coleam00-archon/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/agent-harness/coleam00-archon"
REPO_URL="https://github.com/coleam00/archon.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating coleam00/archon..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning coleam00/archon..."
    git clone --quiet "$REPO_URL" "$DEST"
fi

echo "Done — coleam00/archon repo available at $DEST"
