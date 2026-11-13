#!/usr/bin/env bash
# Abort on any error (-e), undefined variable (-u), or failed pipe (-o pipefail)
set -euo pipefail

# Registers the claude-context and context7 MCP servers at user scope.
# Interactive; idempotent: an existing entry is removed before it is re-added.

# shellcheck source=setup/lib/targets.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/targets.sh"

command -v claude >/dev/null 2>&1 || { echo "claude CLI not found" >&2; exit 1; }

CLAUDE_CONTEXT_PKG="@zilliz/claude-context-mcp@latest"
MILVUS_ADDRESS="localhost:19531"
# settings.json points npm_config_cache at a sandbox tmp dir; MCP servers inherit it and
# npx then reinstalls on every launch, blowing the 30s connect timeout. Keep the warm cache.
NPM_CACHE="$HOME/.npm"

# ask <prompt> <default> — prints the answer, or the default when empty
ask() {
    local answer
    read -r -p "$1 [$2]: " answer
    echo "${answer:-$2}"
}

register() {
    local name="$1"
    shift
    claude mcp remove --scope user "$name" >/dev/null 2>&1 || true
    claude mcp add --scope user "$@"
    echo "Registered: $name"
}

# --- claude-context ---
provider="$(ask "Embedding provider (openai/ollama)" "openai")"
case "$provider" in
    openai|OpenAI)
        # The key stays in this repo's .env; the server reads it at launch, so no key lands in config.
        env_file="$REPO_DIR/.env"
        [ -f "$env_file" ] \
            || echo "WARNING: $env_file not found — create it from .env.example before using claude-context."
        register claude-context claude-context \
            -e MILVUS_ADDRESS="$MILVUS_ADDRESS" \
            -e npm_config_cache="$NPM_CACHE" \
            -- sh -c "set -a; . $(printf %q "$env_file"); set +a;
                : \"\${OPENAI_API_KEY:?missing in $env_file}\"; exec npx --yes $CLAUDE_CONTEXT_PKG"
        ;;
    ollama|Ollama)
        model="$(ask "Ollama embedding model" "qwen3-embedding:0.6b")"
        host="$(ask "Ollama host" "http://127.0.0.1:11434")"
        register claude-context claude-context \
            -e EMBEDDING_PROVIDER=Ollama \
            -e EMBEDDING_MODEL="$model" \
            -e OLLAMA_HOST="$host" \
            -e MILVUS_ADDRESS="$MILVUS_ADDRESS" \
            -e npm_config_cache="$NPM_CACHE" \
            -- npx --yes "$CLAUDE_CONTEXT_PKG"
        ;;
    *)
        echo "Unknown provider: $provider (expected openai or ollama)" >&2
        exit 1
        ;;
esac

# --- context7 ---
register context7 context7 \
    -e DEFAULT_MINIMUM_TOKENS=20000 \
    -e npm_config_cache="$NPM_CACHE" \
    -- npx -y @upstash/context7-mcp
