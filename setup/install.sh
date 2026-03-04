#!/usr/bin/env bash
# Abort on any error (-e), undefined variable (-u), or failed pipe (-o pipefail)
set -euo pipefail

# Resolve the repo root (one level up from this script's directory)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Directories and files to symlink into ~/.claude/
DIRS=(rules commands agents skills templates hooks)
FILES=(settings.json statusline-command.sh)

# Create ~/.claude/ if it doesn't exist yet
mkdir -p "$CLAUDE_DIR"

# --- Symlink directories ---
# Each directory (e.g. skills/) becomes a symlink in ~/.claude/ pointing
# back to this repo. Because the entire directory is symlinked, any new
# file added to the repo automatically appears in ~/.claude/.
for dir in "${DIRS[@]}"; do
    target="$CLAUDE_DIR/$dir"       # where the symlink will be created
    source="$REPO_DIR/$dir"         # what the symlink points to

    # Skip if the directory doesn't exist in this repo
    if [ ! -d "$source" ]; then
        echo "SKIP: $source does not exist in repo"
        continue
    fi

    # If a symlink already exists, remove it (we'll recreate it below)
    if [ -L "$target" ]; then
        rm "$target"
    # If it's a real directory (not a symlink), don't overwrite — user must handle it
    elif [ -d "$target" ]; then
        echo "WARNING: $target is a real directory, not a symlink. Skipping."
        echo "  Back it up and remove it manually, then re-run."
        continue
    fi

    # Create the symlink: ~/.claude/skills -> /path/to/dotclaude/skills
    ln -s "$source" "$target"
    echo "Linked: $target -> $source"
done

# --- Symlink individual files ---
# Files can live in the repo root (e.g. settings.json) or in setup/
# (e.g. statusline-command.sh). We check both locations.
SETUP_DIR="$REPO_DIR/setup"
for file in "${FILES[@]}"; do
    target="$CLAUDE_DIR/$file"      # where the symlink will be created

    # Find the file: check repo root first, then setup/ directory
    if [ -f "$REPO_DIR/$file" ]; then
        source="$REPO_DIR/$file"
    elif [ -f "$SETUP_DIR/$file" ]; then
        source="$SETUP_DIR/$file"
    else
        echo "SKIP: $file not found in repo"
        continue
    fi

    # If a symlink already exists, remove it (we'll recreate it below)
    if [ -L "$target" ]; then
        rm "$target"
    # If it's a real file, back it up with a timestamp before replacing
    elif [ -f "$target" ]; then
        backup="$target.backup.$(date +%Y%m%d%H%M%S)"
        echo "Backing up existing $target -> $backup"
        mv "$target" "$backup"
    fi

    # Create the symlink
    ln -s "$source" "$target"
    echo "Linked: $target -> $source"
done

echo "Done. All symlinks are in place."
