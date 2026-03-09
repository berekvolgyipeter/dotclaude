#!/usr/bin/env bash
# Clones anthropics/knowledge-work-plugins into ~/.claude/skills-references/plugin-browser/anthropics-knowledge-work-plugins/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/plugin-browser/anthropics-knowledge-work-plugins"
REPO_URL="https://github.com/anthropics/knowledge-work-plugins.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating anthropics/knowledge-work-plugins..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning anthropics/knowledge-work-plugins (sparse)..."
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

echo "Done — anthropics/knowledge-work-plugins repo available at $DEST"
