#!/usr/bin/env bash
# Clones mattpocock/skills into ~/.claude/skills-references/plugin-browser/mattpocock-skills/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/plugin-browser/mattpocock-skills"
REPO_URL="https://github.com/mattpocock/skills.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating mattpocock/skills..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning mattpocock/skills (sparse)..."
    mkdir -p "$DEST"
    git clone --quiet --depth=1 --filter=blob:none --no-checkout "$REPO_URL" "$DEST"

    git -C "$DEST" sparse-checkout init --no-cone

    cat > "$DEST/.git/info/sparse-checkout" << 'EOF'
/.claude-plugin/
/skills/
/README.md
/CLAUDE.md
/CONTEXT.md
EOF

    git -C "$DEST" checkout --quiet
fi

echo "Done — mattpocock/skills repo available at $DEST"