#!/usr/bin/env bash
# Clones all agent-harness skill reference repos.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for script in "$SCRIPT_DIR/clone-references"/clone-*.sh; do
    bash "$script"
done

echo "Done — all agent-harness reference repos are cloned."
