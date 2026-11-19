#!/usr/bin/env bash
# Abort on any error (-e), undefined variable (-u), or failed pipe (-o pipefail)
set -euo pipefail

# Registers the context7 MCP server at user scope.
# Idempotent: an existing entry is removed before it is re-added.

command -v claude >/dev/null 2>&1 || { echo "claude CLI not found" >&2; exit 1; }

# settings.json points npm_config_cache at a sandbox tmp dir; MCP servers inherit it and
# npx then reinstalls on every launch, blowing the 30s connect timeout. Keep the warm cache.
NPM_CACHE="$HOME/.npm"

register() {
    local name="$1"
    shift
    claude mcp remove --scope user "$name" >/dev/null 2>&1 || true
    claude mcp add --scope user "$@"
    echo "Registered: $name"
}

register context7 context7 \
    -e DEFAULT_MINIMUM_TOKENS=20000 \
    -e npm_config_cache="$NPM_CACHE" \
    -- npx -y @upstash/context7-mcp
