#!/usr/bin/env bash
# Shared by install.sh and uninstall.sh: what gets linked into ~/.claude/.
# shellcheck disable=SC2034  # variables are used by the sourcing scripts

# Resolve the repo root (two levels up from this file's directory)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
CLAUDE_DIR="$HOME/.claude"

# Directories whose top-level entries are linked one by one into ~/.claude/<dir>/
DIRS=(rules context-rules commands agents skills output-styles templates hooks scripts shared)

# Files linked directly into ~/.claude/
FILES=(settings.json)

# Globs that match nothing expand to nothing instead of a literal '*'
shopt -s nullglob

# True if $1 is a symlink pointing into this repo
links_into_repo() {
    case "$(readlink "$1")" in
        "$REPO_DIR"/*) return 0 ;;
    esac
    return 1
}
