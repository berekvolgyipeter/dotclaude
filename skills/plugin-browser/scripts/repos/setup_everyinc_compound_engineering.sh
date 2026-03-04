#!/usr/bin/env bash
# Clones EveryInc/compound-engineering-plugin into ~/.claude/skills-references/plugin-browser/everyinc-compound-engineering-plugin/ (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/plugin-browser/everyinc-compound-engineering-plugin"
REPO_URL="https://github.com/EveryInc/compound-engineering-plugin.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating EveryInc/compound-engineering-plugin..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning EveryInc/compound-engineering-plugin (sparse)..."
    mkdir -p "$DEST"
    git clone --quiet --depth=1 --filter=blob:none --no-checkout "$REPO_URL" "$DEST"

    git -C "$DEST" sparse-checkout init --no-cone

    cat > "$DEST/.git/info/sparse-checkout" << 'EOF'
/plugins/
!/**/*-plugin/
EOF

    git -C "$DEST" checkout --quiet
fi

echo "Done — EveryInc/compound-engineering-plugin repo available at $DEST"