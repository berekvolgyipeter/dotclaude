#!/bin/sh
# Indexes a codebase directory via the claude-context MCP server (JSON-RPC over stdio).
# Starts the MCP server, triggers AST-based indexing, polls until complete, then exits.
#
# Usage: ./index-codebase.sh /absolute/path/to/codebase

PATH_TO_INDEX="${1:?Error: No codebase path provided. Usage: $0 /absolute/path/to/codebase}"
SNAPSHOT="$HOME/.context/mcp-codebase-snapshot.json"

# --- Environment -------------------------------------------------------------
# The claude-context MCP uses OpenAI embeddings, so it needs an API key.
# MILVUS_ADDRESS points to the local Milvus vector DB instance.
OPENAI_API_KEY=$(grep '^OPENAI_API_KEY=' .env | cut -d '=' -f2-)
export OPENAI_API_KEY
MILVUS_ADDRESS=$(grep '^MILVUS_ADDRESS=' .env | cut -d '=' -f2-)
export MILVUS_ADDRESS="${MILVUS_ADDRESS:-localhost:19531}"

# --- Start MCP server and trigger indexing -----------------------------------
# Pipe two JSON-RPC messages into the MCP server's stdin:
#   1. "initialize" – required MCP handshake to establish the connection
#   2. "tools/call"  – invokes index_codebase with AST splitter on our target path
# The server runs in the background so we can poll its progress below.
echo "Starting indexing for: $PATH_TO_INDEX"
printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"sh","version":"1.0"}}}\n{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"index_codebase","arguments":{"path":"'"$PATH_TO_INDEX"'","splitter":"ast"}}}\n' \
  | npx --yes @zilliz/claude-context-mcp@latest &

# Capture the background process PID so we can kill it when done
MCP_PID=$!
sleep 5  # Give the MCP server a moment to start up and register the indexing job

# --- Poll snapshot file for completion ---------------------------------------
# The MCP server persists indexing state to SNAPSHOT as JSON.
# We read it with node to check the status field for our path.
# Possible statuses: "indexing", "indexed", "indexfailed", or not_found.
echo "Polling indexing status..."
while true; do
  # Wait for the snapshot file to appear (first run may take a moment)
  if [ ! -f "$SNAPSHOT" ]; then
    echo "Waiting for snapshot file..."
    sleep 3
    continue
  fi

  # Parse the snapshot JSON to extract status and progress percentage
  STATUS=$(node -e "
    const s = JSON.parse(require('fs').readFileSync('$SNAPSHOT','utf8'));
    const info = (s.codebases || {})['$PATH_TO_INDEX'];
    console.log(info ? info.status : 'not_found');
    if (info && info.status === 'indexing') process.stdout.write(' ' + (info.indexingPercentage||0).toFixed(1) + '%\n');
    else console.log('');
  " 2>/dev/null | tr -d '\n')

  echo "Status: $STATUS"

  # Exit on terminal states: success or failure
  case "$STATUS" in
    *indexed*)   echo "Indexing complete!"; kill $MCP_PID 2>/dev/null; exit 0 ;;
    *indexfailed*) echo "Indexing failed!"; kill $MCP_PID 2>/dev/null; exit 1 ;;
  esac

  sleep 5
done