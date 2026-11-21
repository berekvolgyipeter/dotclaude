#!/usr/bin/env bash
# Abort on any error (-e), undefined variable (-u), or failed pipe (-o pipefail)
set -euo pipefail

# Idempotent: prints only what it changed or what blocks a link, so it is
# silent when everything is already in place.

# shellcheck source=setup/lib/targets.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/targets.sh"

# --- Link directory entries ---
# ~/.claude/<dir>/ is a real directory shared with whatever Claude Code ships
# there itself (e.g. skills/synced/). Each top-level entry of the repo's <dir>/
# gets its own symlink inside it, so built-in content is never shadowed.
for dir in "${DIRS[@]}"; do
    target_dir="$CLAUDE_DIR/$dir"
    mkdir -p "$target_dir"

    # Remove repo links to entries deleted from the repo or ignored by git
    for target in "$target_dir"/*; do
        if links_into_repo "$target" && { [ ! -e "$target" ] || is_git_ignored "$(readlink "$target")"; }; then
            rm -f "$target"
            echo "Removed: ~/.claude/$dir/$(basename "$target")"
        fi
    done

    # Link each entry; the glob skips dotfiles and the loop skips git-ignored entries such as __pycache__
    for source in "$REPO_DIR/$dir"/*; do
        is_git_ignored "$source" && continue
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
        mv "$target" "$backup"
        echo "Backed up: ~/.claude/$file -> $(basename "$backup")"
    fi

    ln -sfn "$source" "$target"
    echo "Linked: ~/.claude/$file"
done

# --- Link whole folders ---
for folder in "${FOLDERS[@]}"; do
    source="$REPO_DIR/$folder"
    target="$CLAUDE_DIR/$folder"
    chmod 700 "$source"
    [ "$(readlink "$target")" = "$source" ] && continue

    if [ -e "$target" ] && ! links_into_repo "$target"; then
        echo "WARNING: ~/.claude/$folder already exists and is not linked to this repo. Skipping."
        continue
    fi

    ln -sfn "$source" "$target"
    echo "Linked: ~/.claude/$folder"
done
