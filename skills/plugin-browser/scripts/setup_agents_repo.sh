#!/usr/bin/env bash
# Clones wshobson/agents into ~/.claude/skills-references/plugin-browser/agents/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/plugin-browser/agents"
REPO_URL="https://github.com/wshobson/agents.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating wshobson/agents..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning wshobson/agents (sparse)..."
    mkdir -p "$DEST"
    git clone --quiet --depth=1 --filter=blob:none --no-checkout "$REPO_URL" "$DEST"

    git -C "$DEST" sparse-checkout init --no-cone

    cat > "$DEST/.git/info/sparse-checkout" << 'EOF'
/*
!/.github/
!/.gitignore
!/LICENSE
EOF

    git -C "$DEST" checkout --quiet
fi

echo "Done — agents repo available at $DEST"
