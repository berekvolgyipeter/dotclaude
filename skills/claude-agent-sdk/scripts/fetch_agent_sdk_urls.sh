#!/usr/bin/env bash
# Downloads llms.txt from platform.claude.com and keeps only agent-sdk lines,
# excluding any that mention TypeScript.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$SKILL_DIR/references/agent_sdk_urls.md"

mkdir -p "$SKILL_DIR/references"

echo "Downloading llms.txt..."
curl -fsSL "https://platform.claude.com/llms.txt" \
  | { grep 'agent-sdk' || true; } \
  | { grep -iv 'typescript' || true; } > "$DEST"

echo "Done — agent-sdk URLs saved to references/agent_sdk_urls.md"
