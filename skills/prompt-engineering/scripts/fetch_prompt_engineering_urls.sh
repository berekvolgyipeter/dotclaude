#!/usr/bin/env bash
# Downloads llms.txt from platform.claude.com and keeps only prompt-engineering lines.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$SKILL_DIR/references/prompt_engineering_urls.md"

mkdir -p "$SKILL_DIR/references"

echo "Downloading llms.txt..."
curl -fsSL "https://platform.claude.com/llms.txt" \
  | { grep 'prompt-engineering' || true; } > "$DEST"

echo "Done — prompt engineering URLs saved to references/prompt_engineering_urls.md"
