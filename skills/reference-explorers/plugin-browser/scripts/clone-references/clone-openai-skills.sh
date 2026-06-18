#!/usr/bin/env bash
# Clones openai/skills into ~/.claude/skills-references/plugin-browser/openai-skills/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/plugin-browser/openai-skills"
REPO_URL="https://github.com/openai/skills.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating openai/skills..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning openai/skills (sparse)..."
    mkdir -p "$DEST"
    git clone --quiet --depth=1 --filter=blob:none --no-checkout "$REPO_URL" "$DEST"

    git -C "$DEST" sparse-checkout init --no-cone

    cat > "$DEST/.git/info/sparse-checkout" << 'EOF'
/skills/
README.md
EOF

    git -C "$DEST" checkout --quiet
fi

echo "Done — openai/skills repo available at $DEST"
