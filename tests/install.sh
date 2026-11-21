#!/usr/bin/env bash
# Behavior tests for setup/install.sh (links repo entries into ~/.claude/).
# Each case copies the setup scripts into a throwaway git repo, runs install.sh with a throwaway HOME, and checks
# which entries got linked.

set -uo pipefail

SETUP="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/setup"
FAILS=0

# new_case — a throwaway repo (REPO) ignoring __pycache__, with a skill and a __pycache__ folder, and an empty HOME
new_case() {
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/install.XXXXXX")" || exit 1
  WORK="$(cd "$WORK" && pwd -P)"
  REPO="$WORK/repo"
  mkdir -p "$REPO/skills/foo" "$REPO/skills/__pycache__" "$REPO/retros" "$WORK/home"
  cp -R "$SETUP" "$REPO/setup"
  touch "$REPO/skills/foo/SKILL.md" "$REPO/skills/__pycache__/x.pyc" "$REPO/settings.json"
  echo "__pycache__" >"$REPO/.gitignore"
  git -C "$REPO" init -q
}

run_install() {
  OUT="$(HOME="$WORK/home" GIT_CEILING_DIRECTORIES="$WORK" bash "$REPO/setup/install.sh" 2>&1)"
  STATUS=$?
}

# check <name> <condition...> — runs the condition after the install
check() {
  local name="$1"
  shift
  if [ "$STATUS" = 0 ] && "$@"; then
    echo "ok   - $name"
  else
    echo "FAIL - $name"
    echo "       exit: $STATUS  output: $OUT"
    FAILS=$((FAILS + 1))
  fi
  rm -rf "${WORK:?}"
}

is_linked() { [ "$(readlink "$WORK/home/.claude/$1")" = "$REPO/$1" ]; }
is_absent() { [ ! -e "$WORK/home/.claude/$1" ] && [ ! -L "$WORK/home/.claude/$1" ]; }
are_kept() { local link; for link in "$@"; do [ -L "$WORK/home/.claude/$link" ] || return 1; done; }

# --- behaviors ---

new_case
run_install
check "a repo entry is linked" is_linked skills/foo

new_case
run_install
check "a git-ignored entry is not linked" is_absent skills/__pycache__

new_case
mkdir -p "$WORK/home/.claude/skills"
ln -s "$REPO/skills/__pycache__" "$WORK/home/.claude/skills/__pycache__"
run_install
check "an existing link to a git-ignored entry is removed" is_absent skills/__pycache__

new_case
mkdir -p "$WORK/home/.claude/skills"
ln -s "$REPO/skills/gone" "$WORK/home/.claude/skills/gone"
run_install
check "a link to an entry deleted from the repo is removed" is_absent skills/gone

new_case
mkdir -p "$WORK/home/.claude/skills" "$WORK/elsewhere/__pycache__"
ln -s "$WORK/elsewhere/__pycache__" "$WORK/home/.claude/skills/__pycache__"
ln -s "$WORK/nowhere" "$WORK/home/.claude/skills/mine"
run_install
check "links pointing outside the repo are left alone" are_kept skills/__pycache__ skills/mine

new_case
rm -rf "$REPO/.git"
run_install
check "outside a git repo every entry is linked" is_linked skills/__pycache__

if [ "$FAILS" -ne 0 ]; then
  echo "$FAILS failed"
  exit 1
fi
echo "all passed"
