#!/usr/bin/env bash
# Abort on any error (-e), undefined variable (-u), or failed pipe (-o pipefail)
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"

# Must match the same lists used in install.sh
DIRS=(rules commands agents skills templates hooks scripts index)
FILES=(settings.json statusline-command.sh)

# --- Remove directory symlinks ---
for dir in "${DIRS[@]}"; do
    target="$CLAUDE_DIR/$dir"

    # Only remove if it's a symlink (created by install.sh)
    if [ -L "$target" ]; then
        rm "$target"
        echo "Removed symlink: $target"
    # Leave real directories untouched — they weren't created by us
    elif [ -d "$target" ]; then
        echo "SKIP: $target is a real directory, not a symlink created by install.sh"
    fi
done

# --- Remove file symlinks and restore backups ---
for file in "${FILES[@]}"; do
    target="$CLAUDE_DIR/$file"

    # Only remove if it's a symlink (created by install.sh)
    if [ -L "$target" ]; then
        rm "$target"
        echo "Removed symlink: $target"

        # If install.sh backed up the original file, restore the most recent backup
        # ls -t sorts by modification time (newest first), head -1 picks the latest
        # 2>/dev/null suppresses errors if no backups exist
        latest_backup=$(find "$(dirname "$target")" -maxdepth 1 -name "$(basename "$target").backup.*" -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1)
        if [ -n "$latest_backup" ]; then
            mv "$latest_backup" "$target"
            echo "Restored backup: $latest_backup -> $target"
        fi
    # Leave real files untouched — they weren't created by us
    elif [ -f "$target" ]; then
        echo "SKIP: $target is a real file, not a symlink created by install.sh"
    fi
done

echo "Done. Symlinks removed."
