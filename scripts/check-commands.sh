#!/usr/bin/env bash
# Print the command that runs each of a project's lint and test targets, one line per target:
#   lint: make lint | task lint | none
#   test: make test | task test | none
# The Makefile wins over the Taskfile; `none` means neither defines the target.
# Usage: check-commands.sh <project dir>

set -uo pipefail

root="${1:-}"
if [ -z "$root" ] || [ ! -d "$root" ]; then
  echo "usage: check-commands.sh <project dir>" >&2
  exit 1
fi

# Looks the target up in make's rule database: a dry run also succeeds for a mere file or dir of
# that name, and fails for a real target whose prerequisites are missing.
defines_make() {
  command -v make >/dev/null 2>&1 || return 1
  # -q exits non-zero by design; only the printed database matters.
  (cd "$root" && make -pRrq : 2>/dev/null || true) | awk -v t="$1" '
    /^# Not a target/ { skip = 1; next }
    !skip && index($0, t ":") == 1 && substr($0, length(t) + 2, 1) != "=" { found = 1 }
    { skip = 0 }
    END { exit !found }'
}

defines_task() {
  command -v task >/dev/null 2>&1 && compgen -G "$root/[Tt]askfile*.y*ml" >/dev/null \
    && (cd "$root" && task --list-all --json 2>/dev/null) \
    | jq -e --arg t "$1" 'any(.tasks[]; .name == $t)' >/dev/null 2>&1
}

for target in lint test; do
  if defines_make "$target"; then
    echo "$target: make $target"
  elif defines_task "$target"; then
    echo "$target: task $target"
  else
    echo "$target: none"
  fi
done
