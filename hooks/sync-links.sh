#!/bin/bash
# SessionStart hook: re-run setup/install.sh so entries added to (or removed
# from) the repo since the last session are linked into ~/.claude/.
#
# install.sh prints only what it changed, so this is silent when nothing did.
# Never blocks the session: failures are reported but the hook exits 0.

DOTCLAUDE_REPO="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd -P)"

bash "$DOTCLAUDE_REPO/setup/install.sh" || echo "dotclaude: setup/install.sh failed; run 'make install' to see why."
exit 0
