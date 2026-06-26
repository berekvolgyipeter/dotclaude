#!/usr/bin/env bash
# Command helper — deletes the newest code review file

set -euo pipefail

REVIEW_DIR=".claude/.code-reviews"

if ! ls "${REVIEW_DIR}"/*.md &>/dev/null; then
  echo "No review file found."
  exit 0
fi

# shellcheck disable=SC2012
LATEST=$(ls -t "${REVIEW_DIR}"/*.md 2>/dev/null | head -1 || true)

if [[ -n "${LATEST}" ]]; then
  rm -- "${LATEST}"
  echo "Removed ${LATEST}"
fi
