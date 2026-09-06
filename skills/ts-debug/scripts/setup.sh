#!/usr/bin/env bash
# Abort on any error (-e), undefined variable (-u), or failed pipe (-o pipefail)
set -euo pipefail

# The only debugging package this skill needs — everything else it uses ships with Node
DEPS=(why-is-node-running)

# Try package managers in order of preference: pnpm, npm, yarn
# "command -v" checks if a command exists; "&>/dev/null" hides the output
if command -v pnpm &>/dev/null; then
    echo "Using pnpm..."
    pnpm add -D "${DEPS[@]}"
elif command -v npm &>/dev/null; then
    echo "Using npm..."
    npm install --save-dev "${DEPS[@]}"
elif command -v yarn &>/dev/null; then
    echo "Using yarn..."
    yarn add --dev "${DEPS[@]}"
else
    echo "ERROR: No Node package manager found (pnpm, npm, or yarn)."
    exit 1
fi

echo "Done."
