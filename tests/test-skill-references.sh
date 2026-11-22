#!/usr/bin/env bash
# Behavior tests for skills/plugin-browser/scripts/skill_references.py (syncs a skill's reference clones).
# Each case uses a throwaway HOME and serves github.com URLs from local bare repos, so nothing touches the network.

set -uo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/skills/plugin-browser/scripts/skill_references.py"
FAILS=0

# new_case — an empty HOME, a skill folder (SKILL_DIR) and a bare repo served as github.com/owner/repo
new_case() {
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/skill-references.XXXXXX")" || exit 1
  WORK="$(cd "$WORK" && pwd -P)"
  SKILL_DIR="$WORK/demo"
  CLONES="$WORK/home/.claude/skills-references"
  STAMP="$CLONES/.demo-synced"
  mkdir -p "$SKILL_DIR/references" "$CLONES/demo" "$WORK/seed"
  git -C "$WORK/seed" init -q
  touch "$WORK/seed/README.md"
  git -C "$WORK/seed" add README.md
  git -C "$WORK/seed" -c user.name=t -c user.email=t@example.com commit -qm seed
  mkdir -p "$WORK/remotes/owner"
  git clone -q --bare "$WORK/seed" "$WORK/remotes/owner/repo.git"
}

# catalog <github> <local_path> — the skill's catalog with that one repo
catalog() {
  jq -n --arg g "$1" --arg p "$2" '{repos: [{github: $g, local_path: $p}]}' >"$SKILL_DIR/references/catalog.json"
}

run_sync() {
  OUT="$(HOME="$WORK/home" GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0="url.file://$WORK/remotes/.insteadOf" \
    GIT_CONFIG_VALUE_0="https://github.com/" python3 "$SCRIPT" sync "$SKILL_DIR" 2>&1)"
  STATUS=$?
}

# check <name> <condition...> — runs the condition after the sync
check() {
  local name="$1"
  shift
  if "$@"; then
    echo "ok   - $name"
  else
    echo "FAIL - $name"
    echo "       exit: $STATUS  output: $OUT"
    FAILS=$((FAILS + 1))
  fi
  rm -rf "${WORK:?}"
}

is_synced() { [ "$STATUS" = 0 ] && [ -f "$CLONES/demo/repo/README.md" ] && [ -f "$STAMP" ]; }
is_refused() { [ "$STATUS" != 0 ] && [[ "$OUT" == *"$1"* ]] && [ ! -e "$STAMP" ]; }
is_unstamped() { [ "$STATUS" != 0 ] && [ ! -e "$STAMP" ]; }

# --- behaviors ---

new_case
catalog owner/repo "$CLONES/demo/repo"
run_sync
check "a sync clones each repo and stamps the sync time" is_synced

new_case
catalog owner/missing "$CLONES/demo/missing"
run_sync
check "a failed repo leaves the sync unstamped" is_unstamped

new_case
catalog owner/repo "$WORK/home/.claude/skills/planted"
run_sync
check "a clone path outside the skill's clones folder is refused" is_refused "clones outside"

new_case
catalog owner/repo "$CLONES/demo/../other/repo"
run_sync
check "a clone path that climbs out with .. is refused" is_refused "clones outside"

new_case
catalog "owner/repo --upload-pack=evil" "$CLONES/demo/repo"
run_sync
check "a malformed github repo name is refused" is_refused "malformed github repo"

if [ "$FAILS" -ne 0 ]; then
  echo "$FAILS failed"
  exit 1
fi
echo "all passed"
