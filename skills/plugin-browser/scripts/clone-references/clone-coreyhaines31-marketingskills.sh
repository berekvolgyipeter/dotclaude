#!/usr/bin/env bash
# Clones coreyhaines31/marketingskills into ~/.claude/skills-references/plugin-browser/coreyhaines31-marketingskills/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/plugin-browser/coreyhaines31-marketingskills"
REPO_URL="https://github.com/coreyhaines31/marketingskills.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating coreyhaines31/marketingskills..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning coreyhaines31/marketingskills (sparse)..."
    mkdir -p "$DEST"
    git clone --quiet --depth=1 --filter=blob:none --no-checkout "$REPO_URL" "$DEST"

    git -C "$DEST" sparse-checkout init --no-cone

    cat > "$DEST/.git/info/sparse-checkout" << 'EOF'
/skills/
EOF

    git -C "$DEST" checkout --quiet
fi

echo "Done — coreyhaines31/marketingskills repo available at $DEST"
