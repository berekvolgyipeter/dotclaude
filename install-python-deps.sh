#!/usr/bin/env bash
set -euo pipefail

DEPS=(anthropic pyyaml requests)

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
