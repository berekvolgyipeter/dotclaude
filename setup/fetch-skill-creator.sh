#!/usr/bin/env bash
# Abort on any error (-e), undefined variable (-u), or failed pipe (-o pipefail)
set -euo pipefail

# Resolve the repo root (one level up from this script's directory)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Where skill-creator will be placed in this repo
TARGET_DIR="$REPO_DIR/skills/skill-creator"

# The GitHub repo that contains the skill-creator (among other skills)
REPO_URL="https://github.com/anthropics/skills.git"

# The subdirectory within that repo we want to extract
SUBPATH="skills/skill-creator"

# If skill-creator already exists and is not empty, ask before overwriting
if [ -d "$TARGET_DIR" ] && [ "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
    echo "skill-creator already exists at $TARGET_DIR"
    read -rp "Overwrite? [y/N] " answer
    # Only proceed if user types y or Y
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    rm -rf "$TARGET_DIR"
fi

echo "Fetching skill-creator from $REPO_URL ..."

# Create a temporary directory and ensure it's cleaned up when the script exits
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Sparse clone: only download the specific subdirectory we need, not the full repo
# --depth 1          : only fetch the latest commit (no history)
# --filter=blob:none : don't download file contents until needed (faster)
# --sparse           : enable sparse checkout (only specific paths)
git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" "$TMPDIR/skills-repo"
cd "$TMPDIR/skills-repo"

# Tell git we only want the skill-creator subdirectory
git sparse-checkout set "$SUBPATH"

# Move the extracted skill-creator into our repo's skills/ directory
mkdir -p "$(dirname "$TARGET_DIR")"
mv "$SUBPATH" "$TARGET_DIR"

echo "Done. skill-creator installed at $TARGET_DIR"
