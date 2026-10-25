#!/usr/bin/env bash
# Abort on any error (-e), undefined variable (-u), or failed pipe (-o pipefail)
set -euo pipefail

# Idempotent: prints only what it changed or what blocks a link, so it is
# silent when everything is already in place. Also run on every session start
# by hooks/sync-links.sh, possibly by several sessions at once.

# shellcheck source=setup/lib/targets.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/targets.sh"

# --- Link directory entries ---
# ~/.claude/<dir>/ is a real directory shared with whatever Claude Code ships
# there itself (e.g. skills/synced/). Each top-level entry of the repo's <dir>/
# gets its own symlink inside it, so built-in content is never shadowed.
for dir in "${DIRS[@]}"; do
    target_dir="$CLAUDE_DIR/$dir"
    mkdir -p "$target_dir"

    # Remove dangling repo links: entries deleted from the repo
    for target in "$target_dir"/*; do
        if [ -L "$target" ] && [ ! -e "$target" ] && links_into_repo "$target"; then
            rm -f "$target"
            echo "Removed: ~/.claude/$dir/$(basename "$target")"
        fi
    done

    # Link each entry (dotfiles are skipped by the glob)
    for source in "$REPO_DIR/$dir"/*; do
        name="$(basename "$source")"
        target="$target_dir/$name"

        if [ "$(readlink "$target")" = "$source" ]; then
            continue
        elif links_into_repo "$target"; then
            rm -f "$target"
        elif [ -e "$target" ]; then
            echo "WARNING: ~/.claude/$dir/$name already exists and is not linked to this repo. Skipping."
            continue
        fi

        ln -sfn "$source" "$target"
        echo "Linked: ~/.claude/$dir/$name"
    done
done

# --- Link individual files ---
for file in "${FILES[@]}"; do
    source="$REPO_DIR/$file"
    target="$CLAUDE_DIR/$file"
    [ "$(readlink "$target")" = "$source" ] && continue

    # Back up a real file with a timestamp before replacing it
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        backup="$target.backup.$(date +%Y%m%d%H%M%S)"
        # A concurrent run may have already moved it
        mv "$target" "$backup" 2>/dev/null || [ ! -f "$target" ] || [ -L "$target" ]
        echo "Backed up: ~/.claude/$file -> $(basename "$backup")"
    fi

    ln -sfn "$source" "$target"
    echo "Linked: ~/.claude/$file"
done
