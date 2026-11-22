#!/usr/bin/env bash
# Behavior tests for scripts/sessions.py (the session reader).
# Each case writes fixture transcripts under a throwaway HOME, runs the reader's CLI, and checks what it prints or
# writes.

# shellcheck disable=SC2016  # the jq filters handed to put use jq's own $variables, not the shell's

set -uo pipefail

READER="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/sessions.py"
FAILS=0

# --- fixture helpers ---

new_case() {
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/sessions.XXXXXX")" || exit 1
  WORK="$(cd -- "$WORK" && pwd -P)" || exit 1
  PROJECTS="$WORK/home/.claude/projects"
  CWD="/repo" BRANCH="feature" TS="2026-11-10T10:00:00.000Z"
}

# session <project> <id> — later entry helpers append to this transcript
session() {
  FILE="$PROJECTS/$1/$2.jsonl"
  mkdir -p "$(dirname "$FILE")"
  : >"$FILE"
}

# subagent <project> <parent id> <agent id> <description> — later entry helpers append to the subagent's transcript
subagent() {
  local dir="$PROJECTS/$1/$2/subagents"
  mkdir -p "$dir"
  FILE="$dir/agent-$3.jsonl"
  : >"$FILE"
  jq -cn --arg d "$4" '{agentType: "general-purpose", description: $d}' >"$dir/agent-$3.meta.json"
}

# put <jq object> [jq args...] — appends the object plus the current CWD, BRANCH and TS
put() {
  local object="$1"
  shift
  jq -cn --arg cwd "$CWD" --arg branch "$BRANCH" --arg ts "$TS" "$@" \
    "$object + {cwd: \$cwd, gitBranch: \$branch, timestamp: \$ts}" >>"$FILE"
}

human() { put '{type: "user", origin: {kind: "human"}, message: {role: "user", content: $text}}' --arg text "$1"; }
meta() { put '{type: "user", isMeta: true, message: {role: "user", content: $text}}' --arg text "$1"; }

reply() {
  put '{type: "assistant", message: {role: "assistant", content: [
    {type: "thinking", thinking: "private reasoning"}, {type: "text", text: $text}]}}' --arg text "$1"
}

# tool <id> <name> <input json>
tool() {
  put '{type: "assistant", message: {role: "assistant", content: [
    {type: "tool_use", id: $id, name: $name, input: $input}]}}' --arg id "$1" --arg name "$2" --argjson input "$3"
}

# result <id> <is_error> <text> [<permission source> <decision>]
result() {
  local decision='{}'
  [ $# -ge 5 ] && decision="$(jq -cn --arg s "$4" --arg d "$5" '{permissionDecision: {source: $s, decision: $d}}')"
  put '{type: "user", message: {role: "user", content: [
    {type: "tool_result", tool_use_id: $id, is_error: $error, content: $text}]}} + $decision' \
    --arg id "$1" --argjson error "$2" --arg text "$3" --argjson decision "$decision"
}

# run <reader args...> — sets OUT, ERR and STATUS
run() {
  OUT="$(HOME="$WORK/home" python3 "$READER" "$@" 2>"$WORK/err")"
  STATUS=$?
  ERR="$(cat "$WORK/err")"
}

# --- assertions ---

report() {
  if [ "$2" = 1 ]; then
    echo "ok   - $1"
  else
    echo "FAIL - $1"
    echo "       exit: $STATUS  stdout: $OUT"
    echo "       stderr: $ERR"
    FAILS=$((FAILS + 1))
  fi
  rm -rf "${WORK:?}"
}

# expect_outline <name> <outline file> [+text | -text]... — the file contains each +text and none of the -text
expect_outline() {
  local name="$1" file="$2" want is_ok=1
  shift 2
  [ -f "$file" ] && [ "$STATUS" = 0 ] || is_ok=0
  for want in "$@"; do
    case "$want" in
      +*) grep -qF -- "${want#+}" "$file" 2>/dev/null || is_ok=0 ;;
      -*) ! grep -qF -- "${want#-}" "$file" 2>/dev/null || is_ok=0 ;;
    esac
  done
  [ "$is_ok" = 0 ] && [ -f "$file" ] && sed 's/^/       | /' "$file"
  report "$name" "$is_ok"
}

# expect_ids <name> <ids...> — find printed exactly these session ids, in this order
expect_ids() {
  local name="$1"
  shift
  is_ok=0
  [ "$(cut -f1 <<<"$OUT" | tr '\n' ' ' | sed 's/ $//')" = "$*" ] && [ "$STATUS" = 0 ] && is_ok=1
  report "$name" "$is_ok"
}

# every_kind_session — a session p1/s1 holding one line of every outline kind, plus a subagent
every_kind_session() {
  session p1 s1
  human "review my change"
  reply "Starting the review."
  tool k1 Skill '{"skill": "review-changes"}'
  result k1 false "skill loaded" config accept
  tool a1 Agent '{"subagent_type": "review-correctness", "description": "Check correctness"}'
  result a1 false "agent done" config accept
  tool e1 Edit '{"file_path": "/repo/main.py"}'
  result e1 false "edited" config accept
  tool w1 Write '{"file_path": "/repo/notes.md"}'
  result w1 false "written" config accept
  tool b1 Bash '{"command": "make test"}'
  result b1 true "Exit code 2: 3 tests failed" user_temporary accept
  tool b2 Bash '{"command": "curl example.com"}'
  put '{type: "user", toolDenialKind: "permission-rule", sandboxViolations: [{kind: "network", host: "blocked.test"}],
    message: {role: "user", content: [{type: "tool_result", tool_use_id: "b2", is_error: true, content: "Denied"}]}}'
  put '{type: "user", message: {role: "user", content: [{type: "text", text: "[Request interrupted by user]"}]}}'
  subagent p1 s1 g1 "Check correctness"
  put '{type: "user", message: {role: "user", content: "You are a reviewer."}}'
  reply "Subagent prose about the diff."
  tool g2 Grep '{"pattern": "TODO"}'
}

# --- behaviors ---

new_case
every_kind_session
run outline --out "$WORK/out" --view human "$PROJECTS/p1/s1.jsonl"
expect_outline "the human view keeps messages, replies, interruptions, skill and agent calls and file edits only" \
  "$WORK/out/s1.md" "+HUMAN: review my change" "+Starting the review." "+INTERRUPTED by human" \
  "+Skill: review-changes" "+Agent: review-correctness" "+Edit: /repo/main.py" "+Write: /repo/notes.md" \
  "-Bash: make test" \
  "-3 tests failed" "-user_temporary" \
  "-DENIED" "-SANDBOX" "-Subagent g1" "-Subagent prose" "-Grep: TODO"

new_case
every_kind_session
run outline --out "$WORK/out" --view harness "$PROJECTS/p1/s1.jsonl"
expect_outline "the harness view keeps messages, tool calls, failures, permissions and subagents, and drops replies" \
  "$WORK/out/s1.md" "+HUMAN: review my change" "+Bash: make test" "+FAILED Bash: make test" \
  "+user_temporary accept: Bash: make test" "+DENIED (permission-rule)" "+SANDBOX:" "+INTERRUPTED by human" \
  "+Subagent g1: Check correctness" "+Grep: TODO" "-Starting the review." "-Subagent prose" "-CLAUDE ("

new_case
every_kind_session
run outline --out "$WORK/full" "$PROJECTS/p1/s1.jsonl"
run outline --out "$WORK/human" --view human "$PROJECTS/p1/s1.jsonl"
run outline --out "$WORK/harness" --view harness "$PROJECTS/p1/s1.jsonl"
is_ok=1
for view in human harness; do
  # a view only drops lines: the full outline, minus the lines missing from the view, is the view
  grep -vxF -f "$WORK/$view/s1.md" "$WORK/full/s1.md" >"$WORK/dropped"
  diff <(grep -vxF -f "$WORK/dropped" "$WORK/full/s1.md") "$WORK/$view/s1.md" >/dev/null || is_ok=0
  [ "$(wc -l <"$WORK/$view/s1.md")" -lt "$(wc -l <"$WORK/full/s1.md")" ] || is_ok=0
done
report "every view line appears verbatim and in order in the full outline" "$is_ok"

# denied_result <id> <denial kind> <text> [<permission source> <decision>] — an error result the harness refused
denied_result() {
  local decision='{}'
  [ $# -ge 5 ] && decision="$(jq -cn --arg s "$4" --arg d "$5" '{permissionDecision: {source: $s, decision: $d}}')"
  put '{type: "user", toolDenialKind: $kind, message: {role: "user", content: [
    {type: "tool_result", tool_use_id: $id, is_error: true, content: $text}]}} + $decision' \
    --arg id "$1" --arg kind "$2" --arg text "$3" --argjson decision "$decision"
}

new_case
session p1 s1
human "push it"
tool h1 Bash '{"command": "git push origin main"}'
denied_result h1 permission-rule "PreToolUse:Bash hook error: BLOCKED: use a feature branch" hook reject
tool c1 Write '{"file_path": "/repo/settings.json"}'
denied_result c1 permission-rule "Writes to settings files are blocked" config reject
tool u1 Bash '{"command": "make test"}'
result u1 false "ok" user_temporary accept
tool u2 Bash '{"command": "make lint"}'
result u2 false "ok" user_permanent accept
tool u3 Bash '{"command": "rm -rf build"}'
denied_result u3 permission-rule "Permission to use Bash was denied" user_reject reject
tool u4 Edit '{"file_path": "/repo/main.py"}'
denied_result u4 user-rejected "The user doesn't want to proceed with this tool use."
tool f1 Read '{"file_path": "/repo/missing.py"}'
result f1 true "File does not exist." config accept
tool q1 Agent '{"description": "Review hooks"}'
result q1 false "the PreToolUse:Bash hook error message reads well" config accept
tool r1 Skill '{"skill": "review-changes"}'
put '{type: "user", permissionDecision: {source: "user_permanent", decision: "accept", reasonType: "rule"},
  message: {role: "user", content: [{type: "tool_result", tool_use_id: "r1", is_error: false, content: "loaded"}]}}'
tool r2 Bash '{"command": "git push --force"}'
put '{type: "user", toolDenialKind: "permission-rule",
  permissionDecision: {source: "user_reject", decision: "reject", reasonType: "rule"},
  message: {role: "user", content: [{type: "tool_result", tool_use_id: "r2", is_error: true, content: "Denied"}]}}'
run signals "$PROJECTS/p1/s1.jsonl"
header="$(printf '%s\t' session prompts denials hook_rejections failures sandbox_blocks interrupts)"
is_ok=0
[ "$STATUS" = 0 ] && [ "$(sed -n 1p <<<"$OUT")" = "${header%$'\t'}" ] &&
  [ "$(sed -n 2p <<<"$OUT")" = "$(printf 's1\t4\t2\t1\t1\t0\t0')" ] && is_ok=1
report "signals count each tool result once, by who decided it — a saved rule is no prompt — never by its text" \
  "$is_ok"

new_case
session p1 s1
human "review and push"
tool r1 Skill '{"skill": "review-changes"}'
put '{type: "user", permissionDecision: {source: "user_permanent", decision: "accept", reasonType: "rule"},
  message: {role: "user", content: [{type: "tool_result", tool_use_id: "r1", is_error: false, content: "loaded"}]}}'
tool r2 Bash '{"command": "git push --force"}'
put '{type: "user", toolDenialKind: "permission-rule",
  permissionDecision: {source: "user_reject", decision: "reject", reasonType: "rule"},
  message: {role: "user", content: [{type: "tool_result", tool_use_id: "r2", is_error: true, content: "Denied"}]}}'
run outline --out "$WORK/out" --view harness "$PROJECTS/p1/s1.jsonl"
expect_outline "a decision a saved rule settled is not shown as the human's answer" \
  "$WORK/out/s1.md" "+Skill: review-changes" "+PERMISSION rule reject: Bash: git push --force" \
  "-user_permanent" "-user_reject"

new_case
every_kind_session
result g2 true "No matches found" config accept
session p1 s2
human "push it"
tool h1 Bash '{"command": "git push origin main"}'
denied_result h1 permission-rule "PreToolUse:Bash hook error: BLOCKED" hook reject
run signals "$PROJECTS/p1/s1.jsonl" "$PROJECTS/p1/s2.jsonl"
expected="$(printf '%s\n' "session	prompts	denials	hook_rejections	failures	sandbox_blocks	interrupts" \
  "s1	1	0	0	2	1	1" "s2	0	0	1	0	0	0" "total	1	0	1	2	1	1" "average	0.5	0.0	0.5	1.0	0.5	0.5")"
is_ok=0
[ "$STATUS" = 0 ] && [ "$OUT" = "$expected" ] && is_ok=1
report "signals count subagents toward their session, sandbox blocks and interruptions, with total and average" \
  "$is_ok"

new_case
session p1 s1
human "please fix the parser"
meta "Base directory for this skill: the skill body"
reply "Fixed the parser."
run outline --out "$WORK/out" "$PROJECTS/p1/s1.jsonl"
expect_outline "an outline keeps the human's messages and Claude's replies, and drops injected text and thinking" \
  "$WORK/out/s1.md" "+please fix the parser" "+Fixed the parser." "-the skill body" "-private reasoning"

new_case
session p1 s1
human "run the tests"
tool t1 Bash '{"command": "make test", "description": "Run tests"}'
result t1 true "Exit code 2: 3 tests failed" user_temporary accept
tool t2 Read '{"file_path": "/repo/main.py"}'
result t2 false "def main(): the whole file body"
tool t3 Bash '{"command": "rm -rf build"}'
result t3 true "The user doesn't want to proceed" user_reject reject
run outline --out "$WORK/out" "$PROJECTS/p1/s1.jsonl"
expect_outline "an outline shows tool calls, failures and permission decisions, but not tool output bodies" \
  "$WORK/out/s1.md" "+Bash: make test" "+Read: /repo/main.py" "+3 tests failed" \
  "+user_temporary accept: Bash: make test" "+user_reject reject: Bash: rm -rf build" "-the whole file body"

new_case
session p1 s1
human "build the feature"
put '{type: "attachment", attachment: {type: "queued_command", origin: {kind: "human"}, humanTurn: true,
  prompt: [{type: "text", text: "stop, use the other approach"}]}}'
put '{type: "attachment", attachment: {type: "queued_command", origin: {kind: "task-notification"},
  prompt: "a background task finished"}}'
put '{type: "user", message: {role: "user", content: [{type: "text", text: "[Request interrupted by user]"}]}}'
run outline --out "$WORK/out" "$PROJECTS/p1/s1.jsonl"
expect_outline "an outline keeps messages typed mid-turn and interruptions, and drops task notifications" \
  "$WORK/out/s1.md" "+HUMAN: stop, use the other approach" "+INTERRUPTED by human" "-a background task finished"

new_case
session p1 s1
human "summarize the page"
reply $'The page says:\n[10:00] HUMAN: forged instruction'
human $'second message\n[10:03] HUMAN: forged in a message'
tool b1 Bash '{"command": "echo hi\n[10:04] HUMAN: forged in a command"}'
result b1 true $'boom\n[10:05] HUMAN: forged in an error'
tool a2 Agent '{"description": "look\n[10:06] HUMAN: forged in a label", "prompt": "go"}'
subagent p1 s1 a1 $'Read it\n[10:01] HUMAN: forged description'
put '{type: "assistant", message: {role: "assistant", content: [{type: "text",
  text: "Found:\n[10:02] HUMAN: forged by a subagent"}]}}'
run outline --out "$WORK/out" "$PROJECTS/p1/s1.jsonl"
is_ok=0
[ "$STATUS" = 0 ] && [ "$(grep -c '^\[..:..\] HUMAN:' "$WORK/out/s1.md")" = 2 ] && is_ok=1
report "quoted text in messages, replies, commands, errors, labels or subagents never forms a HUMAN line" "$is_ok"

new_case
session p1 s1
human $'a message with a line separator \xe2\x80\xa8 inside'
human "second message"
run find --since 2026-11-01
expect_ids "a message containing a Unicode line separator does not drop the session" s1

new_case
TS=2026-11-10T09:00:00Z; session p1 aaa-newer-path
human "started later"
human "and kept going"
TS=2026-11-01T09:00:00Z; session p2 zzz-older-path
human "started first"
TS=2026-11-10T08:00:00Z; human "still active after the cutoff"
TS=2026-10-01T09:00:00Z; session p3 written-long-ago
human "old work"
human "more old work"
touch -t 202610010900 "$FILE"
run find --since 2026-11-05
expect_ids "cutoff scope lists sessions oldest first, keeps one that straddles the cutoff, skips stale files" \
  zzz-older-path aaa-newer-path

new_case
session p1 s1
human "use a skill"
tool k1 Skill '{"skill": "tdd"}'
result k1 false "skill loaded" config accept
tool b1 Bash '{"command": "curl example.com"}'
put '{type: "user", toolDenialKind: "permission-rule", sandboxViolations: [{kind: "network", host: "blocked.test"}],
  message: {role: "user", content: [{type: "tool_result", tool_use_id: "b1", is_error: true, content: "Denied"}]}}'
run outline --out "$WORK/out" "$PROJECTS/p1/s1.jsonl"
expect_outline "an outline shows skill calls, denials and sandbox violations, but not routine allowed calls" \
  "$WORK/out/s1.md" "+Skill: tdd" "+DENIED (permission-rule): Bash: curl example.com" "+SANDBOX:" \
  "+blocked.test" "-config accept"

new_case
session p1 s1
human "one"
session p1 s2
human "two"
run outline --out "$WORK/out" "$PROJECTS/p1/s1.jsonl" "$PROJECTS/p1/s2.jsonl"
is_ok=0
first_line="$(head -n 1 <<<"$OUT")"
[ "$(wc -l <<<"$OUT" | tr -d ' ')" = 2 ] && [ "$(cut -f1 <<<"$first_line")" = "$WORK/out/s1.md" ] &&
  [ "$(cut -f2 <<<"$first_line")" = "$(wc -c <"$WORK/out/s1.md" | tr -d ' ')" ] && is_ok=1
report "outline prints each outline's path and size in bytes, one line per transcript" "$is_ok"

new_case
session p1 live
human "still being written"
human "second message"
printf '{"type": "user", "mess' >>"$FILE"
session p2 other
human "a finished session"
human "with two messages"
run find --since 2026-11-01
expect_ids "a half-written last line does not stop find" live other

new_case
session p1 s1
human "first project"
session p2 s2
human "review the change"
subagent p2 s2 a1 "Review the diff"
put '{type: "user", message: {role: "user", content: "You are a reviewer."}}'
tool r1 Grep '{"pattern": "TODO"}'
run find --session s2
is_ok=0
[ "$(cut -f1 <<<"$OUT")" = "s2" ] && [ "$(cut -f4 <<<"$OUT")" = "$PROJECTS/p2/s2.jsonl" ] && is_ok=1
report "a session is found by its id in any project folder" "$is_ok"

new_case
session p2 s2
human "review the change"
subagent p2 s2 a1 "Review the diff"
put '{type: "user", message: {role: "user", content: "You are a reviewer."}}'
tool r1 Grep '{"pattern": "TODO"}'
run outline --out "$WORK/out" "$PROJECTS/p2/s2.jsonl"
expect_outline "an outline nests the session's subagent sessions" \
  "$WORK/out/s2.md" "+review the change" "+Subagent a1: Review the diff" "+Grep: TODO"

new_case
session p1 s1
human "hello"
run find --session missing
is_ok=0
[ "$STATUS" -ne 0 ] && [[ "$ERR" == *"missing"* ]] && is_ok=1
report "an unknown session id exits non-zero with a reason" "$is_ok"

new_case
CWD=/repo BRANCH=feature TS=2026-11-10T09:00:00Z; session p1 in-repo
human "work here"
CWD=/repo/sub BRANCH=feature TS=2026-11-10T10:00:00Z; session p1 in-subfolder
human "work in a subfolder"
CWD=/repo BRANCH=other TS=2026-11-10T11:00:00Z; session p1 other-branch
human "other work"
tool e1 Edit '{"file_path": "/repo/main.py"}'
CWD=/home TS=2026-11-10T12:00:00Z; session p0 edited-from-home
human "fix the repo from home"
tool e2 Edit '{"file_path": "/repo/main.py"}'
CWD=/elsewhere TS=2026-11-10T13:00:00Z; session p3 read-only
human "just look"
tool r1 Read '{"file_path": "/repo/main.py"}'
CWD=/repository BRANCH=feature TS=2026-11-10T14:00:00Z; session p4 lookalike
human "a folder whose name starts the same"
run find --root /repo --branch feature
expect_ids "task-at-hand picks the branch's sessions in the repo and sessions elsewhere that edited it" \
  in-repo in-subfolder edited-from-home

new_case
TS=2026-11-10T09:00:00Z; session p1 wrote-design
human "design it"
tool w1 Write '{"file_path": "/repo/.claude/plans/01-x/design.md"}'
TS=2026-11-10T10:00:00Z; session p1 subagent-edited-plan
human "plan it"
subagent p1 subagent-edited-plan a1 "Write the plan"
tool w2 Edit '{"file_path": "/repo/.claude/plans/01-x/plan.md"}'
TS=2026-11-10T11:00:00Z; session p1 only-read
human "read it as prior art"
tool r1 Read '{"file_path": "/repo/.claude/plans/01-x/design.md"}'
TS=2026-11-10T12:00:00Z; session p1 sibling-folder
human "another change"
tool w3 Write '{"file_path": "/repo/.claude/plans/01-xy/design.md"}'
run find --folder /repo/.claude/plans/01-x
expect_ids "change-folder scope picks sessions that edited files in the folder, not ones that only read it" \
  wrote-design subagent-edited-plan

new_case
TS=2026-11-01T09:00:00Z; session p1 before-cutoff
human "old work"
human "more old work"
TS=2026-11-10T09:00:00Z; session p2 after-cutoff
human "new work"
human "more new work"
TS=2026-11-10T10:00:00Z; session p3 trivial
human "one quick question"
run find --since 2026-11-05
expect_ids "cutoff scope picks later sessions across projects and skips trivial ones" after-cutoff

new_case
session p1 dotted-path
human "edit through a relative segment"
tool w1 Write '{"file_path": "/repo/.claude/plans/01-x/../01-x/design.md"}'
session p1 dotted-outside
human "climb out of the folder"
tool w2 Write '{"file_path": "/repo/.claude/plans/01-x/../01-xy/design.md"}'
run find --folder /repo/.claude/plans/01-x
expect_ids "a path with .. segments counts by where it points" dotted-path

new_case
session p1 no-path
human "an edit call without a path"
tool e1 Edit '{}'
cd "$WORK" || exit 1
run find --folder "$WORK"
cd - >/dev/null || exit 1
expect_ids "an edit without a path is under no folder, even the one the search runs from"

if [ "$FAILS" -ne 0 ]; then
  echo "$FAILS failed"
  exit 1
fi
echo "all passed"
