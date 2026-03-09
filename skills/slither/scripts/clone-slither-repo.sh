#!/usr/bin/env bash
# Clones crytic/slither into ~/.claude/skills-references/slither/slither/ (or pulls if already present).

# Fail on errors, unset vars, and pipe failures.
set -euo pipefail

DEST="$HOME/.claude/skills-references/slither/slither"
REPO_URL="https://github.com/crytic/slither.git"

if [ -d "$DEST/.git" ]; then
    echo "Updating crytic/slither..."
    git -C "$DEST" pull --quiet
else
    echo "Cloning crytic/slither (sparse)..."
    mkdir -p "$DEST"
    git clone --quiet --depth=1 --filter=blob:none --no-checkout "$REPO_URL" "$DEST"

    # Non-cone mode: supports exact file/dir exclusions
    git -C "$DEST" sparse-checkout init --no-cone

    cat > "$DEST/.git/info/sparse-checkout" << 'EOF'
/*
!/.github/
!/.serena/
!/scripts/
!/tests/
!/.dockerignore
!/.gitattributes
!/.gitignore
!/.mcp.json
!/.pre-commit-config.yaml
!/.pre-commit-hooks.yaml
!/.yamllint
!/CLAUDE.md
!/CITATION.cff
!/CODEOWNERS
!/CONTRIBUTING.md
!/Dockerfile
!/LICENSE
!/Makefile
!/funding.json
!/logo.png
!/pyproject.toml
!/uv.lock
EOF

    git -C "$DEST" checkout --quiet
fi

echo "Done — slither source available at $DEST"
