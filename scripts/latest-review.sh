#!/usr/bin/env bash
# Command helper — outputs the path to the newest code review file

set -euo pipefail

REVIEW_DIR=".claude/.code-reviews"

if ! ls "${REVIEW_DIR}"/*.md &>/dev/null; then
  echo "No review file found."
  exit 0
fi

stat -f '%m %N' "${REVIEW_DIR}"/*.md | sort -rn | head -1 | cut -d' ' -f2-
