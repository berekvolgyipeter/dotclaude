#!/usr/bin/env bash
# Clones anthropics/claude-agent-sdk-python into ~/.claude/skills-references/claude-agent-sdk/claude-agent-sdk-python/
# using sparse checkout to fetch only relevant source files (or pulls if already present).

set -euo pipefail

DEST="$HOME/.claude/skills-references/claude-agent-sdk/claude-agent-sdk-python"
REPO_URL="https://github.com/anthropics/claude-agent-sdk-python.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating anthropics/claude-agent-sdk-python..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning anthropics/claude-agent-sdk-python (sparse)..."
    mkdir -p "$DEST"
    git clone --quiet --depth=1 --filter=blob:none --no-checkout "$REPO_URL" "$DEST"

    # Non-cone mode: supports exact file exclusions at the root level
    git -C "$DEST" sparse-checkout init --no-cone

    # Write patterns: include everything, then exclude unwanted paths
    cat > "$DEST/.git/info/sparse-checkout" << 'EOF'
/*
!/.claude/
!/.github/
!/e2e-tests/
!/scripts/
!/tests/
!/.dockerignore
!/.gitignore
!/CHANGELOG.md
!/CLAUDE.md
!/Dockerfile.test
!/LICENSE
!/pyproject.toml
!/RELEASING.md
EOF

    git -C "$DEST" checkout --quiet
fi

echo "Done — SDK repo available at $DEST"
