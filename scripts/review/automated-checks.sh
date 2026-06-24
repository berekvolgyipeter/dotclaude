#!/usr/bin/env bash
# Command helper — injects make lint and make test output as review context.
#
# No `set -e`: a failing lint must not stop test, and this script should always
# exit 0 so the rest of the review command still renders.
#
# Opt-out: set DOTCLAUDE_DISABLE_AUTO_LINT / DOTCLAUDE_DISABLE_AUTO_TEST to 1 (or true) to skip lint
# / test respectively.
is_disabled() {
  case "${1:-}" in
    1|true|True|TRUE|yes|YES) return 0 ;;
  esac
  return 1
}

# Run one make target; report "N/A" if it is disabled, or if make or the target
# is missing.
run_check() {
  local target=$1 heading=$2 disabled=$3 output
  printf '### %s\n\n' "$heading"
  if is_disabled "$disabled" || ! command -v make >/dev/null 2>&1 || ! make -n "$target" >/dev/null 2>&1; then
    printf 'N/A\n'
    return
  fi
  output=$(make "$target" 2>&1)
  printf '%s\n' "$output"
}

printf '## Automated Checks\n\n'

run_check lint Lint "${DOTCLAUDE_DISABLE_AUTO_LINT:-}"
printf '\n'
run_check test Test "${DOTCLAUDE_DISABLE_AUTO_TEST:-}"
printf '\n'
