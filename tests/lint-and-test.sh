#!/usr/bin/env bash
# Behavior tests for hooks/lint-and-test.sh (the Stop-hook lint/test gate).
# Each case builds throwaway git repos whose Makefiles log the targets they ran,
# writes a transcript fixture, pipes Stop JSON to the hook, and checks exit code + targets run.

set -uo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/hooks/lint-and-test.sh"
FAILS=0

# --- fixture helpers ---

new_case() {
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/lint-and-test.XXXXXX")"
  WORK="$(cd "$WORK" && pwd -P)"
  RAN="$WORK/ran.log"
  TRANSCRIPT="$WORK/transcript.jsonl"
  : >"$RAN"
  : >"$TRANSCRIPT"
}

# new_repo <dir> [targets...] — git repo whose Makefile appends "<dir-name>:<target>" to $RAN.
# A target named "!x" is defined but fails.
new_repo() {
  local dir="$1" name t
  shift
  name="$(basename "$dir")"
  mkdir -p "$dir"
  git -C "$dir" init -q
  : >"$dir/Makefile"
  for t in "$@"; do
    if [[ "$t" == !* ]]; then
      printf '%s:\n\t@echo %s:%s >> %s\n\t@echo "%s broke" >&2; exit 1\n' \
        "${t#!}" "$name" "${t#!}" "$RAN" "${t#!}" >>"$dir/Makefile"
    else
      printf '%s:\n\t@echo %s:%s >> %s\n' "$t" "$name" "$t" "$RAN" >>"$dir/Makefile"
    fi
  done
}

user_prompt() {
  jq -cn --arg t "$1" '{type: "user", message: {role: "user", content: $t}}' >>"$TRANSCRIPT"
}

edit() {
  jq -cn --arg tool "$1" --arg p "$2" \
    '{type: "assistant", message: {role: "assistant",
      content: [{type: "tool_use", id: "x", name: $tool, input: {file_path: $p}}]}}' >>"$TRANSCRIPT"
  jq -cn '{type: "user", message: {role: "user",
    content: [{type: "tool_result", tool_use_id: "x", content: "ok"}]}}' >>"$TRANSCRIPT"
}

# run_hook [stop_hook_active] — sets STATUS and ERR
run_hook() {
  local active="${1:-false}"
  ERR="$(jq -cn --arg t "$TRANSCRIPT" --arg c "$WORK" --argjson a "$active" \
    '{transcript_path: $t, cwd: $c, stop_hook_active: $a}' | bash "$HOOK" 2>&1 >/dev/null)"
  STATUS=$?
}

# --- assertions ---

ran() { sort "$RAN" | tr '\n' ' ' | sed 's/ $//'; }

check() {
  local name="$1" want_status="$2" want_ran="$3"
  if [ "$STATUS" = "$want_status" ] && [ "$(ran)" = "$want_ran" ]; then
    echo "ok   - $name"
  else
    echo "FAIL - $name"
    echo "       exit: want $want_status, got $STATUS"
    echo "       ran:  want '$want_ran', got '$(ran)'"
    echo "       stderr: $ERR"
    FAILS=$((FAILS + 1))
  fi
  rm -rf "$WORK"
}

# --- behaviors ---

new_case
new_repo "$WORK/api" lint test
new_repo "$WORK/web" lint test
user_prompt "change both"
edit Edit "$WORK/api/main.py"
edit Write "$WORK/web/new.ts"
run_hook
check "edits in two repos run each repo's own targets" 0 "api:lint api:test web:lint web:test"

new_case
new_repo "$WORK/app" lint test
user_prompt "change something"
edit Edit "$WORK/app/main.py"
user_prompt "thanks, just answer a question now"
run_hook
check "edits only before the last user prompt run nothing" 0 ""

new_case
new_repo "$WORK/app" lint test
user_prompt "use a skill to change it"
edit Edit "$WORK/app/main.py"
jq -cn '{type: "user", isMeta: true,
  message: {role: "user", content: [{type: "text", text: "skill body"}]}}' >>"$TRANSCRIPT"
jq -cn '{type: "user", message: {role: "user", content: null}}' >>"$TRANSCRIPT"
run_hook
check "meta and empty user entries after an edit are not prompts" 0 "app:lint app:test"

new_case
new_repo "$WORK/app" lint test
mkdir -p "$WORK/elsewhere"
git -C "$WORK/app" add Makefile
git -C "$WORK/app" -c user.name=t -c user.email=t@t commit -q -m init
git -C "$WORK/app" worktree add -q "$WORK/elsewhere/app-wt"
user_prompt "fix it in the worktree"
edit Edit "$WORK/elsewhere/app-wt/main.py"
run_hook
check "an edit in a worktree outside cwd runs that worktree's targets" 0 "app:lint app:test"

new_case
new_repo "$WORK/app" lint test
echo "notes/" >"$WORK/app/.gitignore"
mkdir -p "$WORK/app/notes"
touch "$WORK/app/notes/todo.md"
user_prompt "jot this down"
edit Write "$WORK/app/notes/todo.md"
run_hook
check "an edit to a gitignored file only runs nothing" 0 ""

new_case
mkdir -p "$WORK/scratch"
printf 'lint:\n\t@echo scratch:lint >> %s\n' "$RAN" >"$WORK/scratch/Makefile"
user_prompt "write a scratch file"
edit Write "$WORK/scratch/notes.md"
run_hook
check "an edit outside any git repo runs nothing" 0 ""

new_case
new_repo "$WORK/app" test
user_prompt "change it"
edit Edit "$WORK/app/main.py"
run_hook
check "a missing target is skipped and the other still runs" 0 "app:test"

new_case
new_repo "$WORK/app" '!lint' test
user_prompt "change it"
edit Edit "$WORK/app/main.py"
run_hook
check "a failing target exits 2" 2 "app:lint app:test"
if [[ "$ERR" != *"lint broke"* ]]; then
  echo "FAIL - a failing target's make output reaches stderr"
  FAILS=$((FAILS + 1))
fi

new_case
new_repo "$WORK/app" '!lint' test
user_prompt "change it"
edit Edit "$WORK/app/main.py"
DOTCLAUDE_DISABLE_AUTO_LINT=1 run_hook
check "DOTCLAUDE_DISABLE_AUTO_LINT skips lint" 0 "app:test"

new_case
new_repo "$WORK/app" lint '!test'
user_prompt "change it"
edit Edit "$WORK/app/main.py"
DOTCLAUDE_DISABLE_AUTO_TEST=true run_hook
check "DOTCLAUDE_DISABLE_AUTO_TEST skips test" 0 "app:lint"

new_case
new_repo "$WORK/app" '!lint' test
user_prompt "change it"
edit Edit "$WORK/app/main.py"
run_hook true
check "stop_hook_active runs nothing" 0 ""

if [ "$FAILS" -ne 0 ]; then
  echo "$FAILS failed"
  exit 1
fi
echo "all passed"
