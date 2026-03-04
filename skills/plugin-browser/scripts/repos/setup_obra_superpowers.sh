#!/usr/bin/env bash
# Clones obra/superpowers into ~/.claude/skills-references/plugin-browser/obra-superpowers/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/plugin-browser/obra-superpowers"
REPO_URL="https://github.com/obra/superpowers.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating obra/superpowers..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning obra/superpowers (sparse)..."
    mkdir -p "$DEST"
    git clone --quiet --depth=1 --filter=blob:none --no-checkout "$REPO_URL" "$DEST"

    git -C "$DEST" sparse-checkout init --no-cone

    cat > "$DEST/.git/info/sparse-checkout" << 'EOF'
/agents
/commands
/hooks
/skills
/README.md
EOF

    git -C "$DEST" checkout --quiet
fi

echo "Done — obra/superpowers repo available at $DEST"