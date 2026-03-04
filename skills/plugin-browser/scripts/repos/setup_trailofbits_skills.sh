#!/usr/bin/env bash
# Clones trailofbits/skills into ~/.claude/skills-references/plugin-browser/trailofbits-skills/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/plugin-browser/trailofbits-skills"
REPO_URL="https://github.com/trailofbits/skills.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating trailofbits/skills..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning trailofbits/skills (sparse)..."
    mkdir -p "$DEST"
    git clone --quiet --depth=1 --filter=blob:none --no-checkout "$REPO_URL" "$DEST"

    git -C "$DEST" sparse-checkout init --no-cone

    cat > "$DEST/.git/info/sparse-checkout" << 'EOF'
/.claude-plugin/
/plugins/
!README.md
EOF

    git -C "$DEST" checkout --quiet
fi

echo "Done — trailofbits/skills repo available at $DEST"
