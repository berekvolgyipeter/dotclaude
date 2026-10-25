#!/usr/bin/env bash
# Abort on any error (-e), undefined variable (-u), or failed pipe (-o pipefail)
set -euo pipefail

# shellcheck source=setup/lib/targets.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/targets.sh"

# --- Remove directory entry links ---
# Only symlinks pointing into this repo are removed; anything else in
# ~/.claude/<dir>/ (e.g. content Claude Code ships itself) is left untouched.
for dir in "${DIRS[@]}"; do
    target_dir="$CLAUDE_DIR/$dir"

    for target in "$target_dir"/*; do
        if links_into_repo "$target"; then
            rm -f "$target"
            echo "Removed: ~/.claude/$dir/$(basename "$target")"
        fi
    done

    # Drop the directory if nothing else lives in it
    rmdir "$target_dir" 2>/dev/null || true
done

# --- Remove file links and restore backups ---
for file in "${FILES[@]}"; do
    target="$CLAUDE_DIR/$file"
    links_into_repo "$target" || continue

    rm -f "$target"
    echo "Removed: ~/.claude/$file"

    # Restore the most recent backup made by install.sh, if any
    # (timestamped names sort chronologically, so the last match is the newest)
    backups=("$target.backup."*)
    if [ ${#backups[@]} -gt 0 ]; then
        latest_backup="${backups[${#backups[@]} - 1]}"
        mv "$latest_backup" "$target"
        echo "Restored: $(basename "$latest_backup") -> ~/.claude/$file"
    fi
done
