#!/usr/bin/env bash
# Abort on any error (-e), undefined variable (-u), or failed pipe (-o pipefail)
set -euo pipefail

# Python packages needed by skills (e.g. skill-creator uses anthropic + pyyaml)
DEPS=(anthropic pyyaml requests python-dotenv ruff)

# Try package managers in order of preference: uv (fastest), pip3, pip
# "command -v" checks if a command exists; "&>/dev/null" hides the output
if command -v uv &>/dev/null; then
    echo "Using uv..."
    uv pip install "${DEPS[@]}"
elif command -v pip3 &>/dev/null; then
    echo "Using pip3..."
    pip3 install "${DEPS[@]}"
elif command -v pip &>/dev/null; then
    echo "Using pip..."
    pip install "${DEPS[@]}"
else
    echo "ERROR: No Python package manager found (uv, pip3, or pip)."
    exit 1
fi

echo "Done."
