#!/usr/bin/env bash
# Sets up all plugin-browser skill reference repos.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for script in "$SCRIPT_DIR/repos"/setup_*.sh; do
    bash "$script"
done

echo "Done — all plugin-browser repos set up."
