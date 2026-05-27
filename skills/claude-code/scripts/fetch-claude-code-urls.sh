#!/usr/bin/env bash
# Downloads llms.txt from code.claude.com and saves it as the skill's URL index.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$SKILL_DIR/references/claude-code-urls.md"

mkdir -p "$SKILL_DIR/references"

echo "Downloading llms.txt..."
curl -fsSL "https://code.claude.com/docs/llms.txt" > "$DEST"

echo "Done — saved to references/claude-code-urls.md"
