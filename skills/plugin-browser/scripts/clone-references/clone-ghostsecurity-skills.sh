#!/usr/bin/env bash
# Clones ghostsecurity/skills into ~/.claude/skills-references/plugin-browser/ghostsecurity-skills/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/plugin-browser/ghostsecurity-skills"
REPO_URL="https://github.com/ghostsecurity/skills.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating ghostsecurity/skills..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning ghostsecurity/skills (sparse)..."
    mkdir -p "$DEST"
    git clone --quiet --depth=1 --filter=blob:none --no-checkout "$REPO_URL" "$DEST"

    git -C "$DEST" sparse-checkout init --no-cone

    cat > "$DEST/.git/info/sparse-checkout" << 'EOF'
/README.md
/plugins/
!/**/*-plugin/
!/**/CHANGELOG.md
EOF

    git -C "$DEST" checkout --quiet
fi

echo "Done — ghostsecurity/skills repo available at $DEST"
