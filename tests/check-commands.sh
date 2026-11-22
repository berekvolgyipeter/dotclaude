#!/usr/bin/env bash
# Behavior tests for scripts/check-commands.sh (which command runs a project's lint and test targets).

set -uo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/check-commands.sh"
FAILS=0

# check <name> <want exit> <want stdout> <args...>
check() {
  local name="$1" want_status="$2" want_out="$3" out status
  shift 3
  out="$(bash "$SCRIPT" "$@" 2>/dev/null)"
  status=$?
  if [ "$status" = "$want_status" ] && [ "$out" = "$want_out" ]; then
    echo "ok   - $name"
  else
    echo "FAIL - $name"
    echo "       exit: want $want_status, got $status"
    echo "       out:  want '$want_out', got '$out'"
    FAILS=$((FAILS + 1))
  fi
}

# project [targets...] — a fresh dir whose Makefile defines the given targets
project() {
  local dir t
  dir="$(mktemp -d "${TMPDIR:-/tmp}/check-commands.XXXXXX")"
  for t in "$@"; do printf '%s:\n\t@true\n' "$t" >>"$dir/Makefile"; done
  echo "$dir"
}

dir="$(project lint test)"
check "both make targets" 0 $'lint: make lint\ntest: make test' "$dir"
rm -rf "$dir"

dir="$(project test)"
check "only a test target" 0 $'lint: none\ntest: make test' "$dir"
rm -rf "$dir"

dir="$(project lint)"
check "only a lint target" 0 $'lint: make lint\ntest: none' "$dir"
rm -rf "$dir"

dir="$(project)"
check "no targets" 0 $'lint: none\ntest: none' "$dir"
rm -rf "$dir"

dir="$(project)"
mkdir "$dir/test"
check "a test dir without a Makefile is not a target" 0 $'lint: none\ntest: none' "$dir"
rm -rf "$dir"

dir="$(project lint)"
mkdir "$dir/test"
check "a test dir beside a Makefile without the target is not a target" 0 $'lint: make lint\ntest: none' "$dir"
rm -rf "$dir"

dir="$(project)"
printf 'test: missing.txt\n\t@true\nlint:\n\t@true\n' >"$dir/Makefile"
check "a target with a missing prerequisite is still a target" 0 $'lint: make lint\ntest: make test' "$dir"
rm -rf "$dir"

check "a missing dir is a usage error" 1 "" "${TMPDIR:-/tmp}/check-commands-missing-$$"
check "no argument is a usage error" 1 ""

if [ "$FAILS" -ne 0 ]; then
  echo "$FAILS failed"
  exit 1
fi
echo "all passed"
