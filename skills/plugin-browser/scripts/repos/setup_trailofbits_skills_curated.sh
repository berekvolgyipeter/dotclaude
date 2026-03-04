#!/usr/bin/env bash
# Clones trailofbits/skills-curated into ~/.claude/skills-references/plugin-browser/trailofbits-skills-curated/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/plugin-browser/trailofbits-skills-curated"
REPO_URL="https://github.com/trailofbits/skills-curated.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating trailofbits/skills-curated..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning trailofbits/skills-curated (sparse)..."
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

echo "Done — trailofbits/skills-curated repo available at $DEST"