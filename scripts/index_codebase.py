#!/usr/bin/env python3
"""Indexes a codebase via the claude-context MCP server (JSON-RPC over stdio)."""

import atexit
import json
import subprocess
import sys
import time
import os
from dotenv import load_dotenv

load_dotenv()
os.environ.setdefault("MILVUS_ADDRESS", "localhost:19531")

path_to_index = sys.argv[1] if len(sys.argv) > 1 else None
if not path_to_index:
    print("Usage: index-codebase.py /absolute/path/to/codebase")
    sys.exit(1)

snapshot = os.path.expanduser("~/.context/mcp-codebase-snapshot.json")


# Start MCP server
def _cleanup():
    proc.kill()
    proc.wait()


proc = subprocess.Popen(
    ["npx", "--yes", "@zilliz/claude-context-mcp@latest"],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=sys.stderr,
    text=True,
    bufsize=1,
)
atexit.register(_cleanup)


def send(msg):
    proc.stdin.write(json.dumps(msg) + "\n")
    proc.stdin.flush()


def recv():
    while True:
        line = proc.stdout.readline()
        if not line:
            return None
        line = line.strip()
        if not line:
            continue
        try:
            return json.loads(line)
        except json.JSONDecodeError:
            continue


# 1. Initialize
send(
    {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "py", "version": "1.0"},
        },
    }
)

resp = recv()
print(f"Initialize: {resp and 'OK' or 'FAILED'}", file=sys.stderr)

# 2. Index
send(
    {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "tools/call",
        "params": {
            "name": "index_codebase",
            "arguments": {"path": path_to_index, "splitter": "ast"},
        },
    }
)

print(f"Sent index_codebase for: {path_to_index}", file=sys.stderr)

# 3. Poll snapshot
print("Polling indexing status...")
while True:
    time.sleep(5)
    if not os.path.exists(snapshot):
        print("Waiting for snapshot file...")
        continue

    with open(snapshot) as f:
        data = json.load(f)

    info = data.get("codebases", {}).get(path_to_index)
    if not info:
        print("Status: not_found")
        continue

    status = info.get("status")
    if status == "indexing":
        pct = info.get("indexingPercentage", 0)
        print(f"Status: indexing {pct:.1f}%")
    elif status == "indexed":
        print("Indexing complete!")
        sys.exit(0)
    elif status == "indexfailed":
        print(f"Indexing failed! {info.get('errorMessage', '')}")
        sys.exit(1)
    else:
        print(f"Status: {status}")
