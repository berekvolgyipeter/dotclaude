#!/usr/bin/env bash
# Clones anthropics/claude-plugins-official into ~/.claude/skills-references/plugin-browser/anthropics-claude-plugins-official/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/plugin-browser/anthropics-claude-plugins-official"
REPO_URL="https://github.com/anthropics/claude-plugins-official.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating anthropics/claude-plugins-official..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning anthropics/claude-plugins-official (sparse)..."
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

echo "Done — anthropics/claude-plugins-official repo available at $DEST"
