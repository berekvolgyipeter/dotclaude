---
name: retro
description: Look back over past sessions and propose the cheapest lasting fixes to the harness or the project in a short report the developer decides on — judging whether the human's intent was followed, whether they could follow Claude, friction, procedure, review misses, automation, security and skill usage — and grade whether earlier accepted fixes worked. Run with /retro for the task at hand, `session`, a change folder, or `full`; it also answers the retro reminder's snooze, dismiss and schedule.
disable-model-invocation: true
argument-hint: "[session | full | all | @change-folder | snooze <N>d | dismiss | schedule]"
allowed-tools: Bash(python3 ~/.claude/scripts/sessions.py *)
---

# Retro

Read past sessions, find where the harness or the project made the human's work harder, and propose the cheapest
lasting fix for each real miss. The developer decides; the decision log carries their answers to the next retro,
which checks whether the accepted fixes worked. A retro proposes — it changes nothing until the developer says so.

<request>
$ARGUMENTS
</request>

Read `~/.claude/shared/meet-the-user.md` and follow it whenever you ask the user something or report to them.

**The retros folder** is `~/.claude/retros/`: reports, the decision log (`decisions.md`) and the reminder date
(`next-due`), in the formats `references/report.md` gives. The harness repo is two levels above
`readlink -f ~/.claude/skills/retro`.

**Unattended runs.** When your prompt says to run unattended, nobody can answer: ask nothing, write the report with
status `awaiting decisions`, and stop after step 5's report — record no decisions and leave `next-due` alone.

## 1. Read the Request

- `snooze <N>d` — set `next-due` to today plus N days and add one to its snooze count; reply in one line and stop.
- `dismiss` — the same as `snooze 7d`.
- `schedule` — follow Schedule below and stop.
- Otherwise the request names the **scope**: nothing → the task at hand; `session` → this session; `full` or `all` →
  everything since the last full retro; a path, with or without a leading `@` → that change folder.

For `full`, when reports with status `awaiting decisions` exist and you are attended, scheduled runs already read the
sessions: walk each waiting report's proposals, oldest first, through step 5's decisions — show its TL;DR and
proposals, write no new report — then go to step 6. For any other scope, mention the waiting reports in one line and
go on.

## 2. Find the Sessions

| Scope | How |
|---|---|
| task at hand | The root is the working directory's git root (`git rev-parse --show-toplevel`). Outside a repo, collect the candidates as step 1 of `~/.claude/shared/change-set.md` does — without its "has changes" filter, since a retro runs after the commit — and with several, ask the developer which one here and go on (a path in a re-run would mean a change folder). Take the root's branch (`git -C <root> branch --show-current`). On a detached HEAD, or on the default branch (`git -C <root> symbolic-ref --short refs/remotes/origin/HEAD` minus `origin/`, else `main` or `master`), every change meets: ask for a narrower scope — `session`, a change folder, or `full` — and stop. Then `find --root <root> --branch <branch>`. |
| session | `find --session ${CLAUDE_SESSION_ID}` |
| change folder | `find --folder <absolute path of the folder>` |
| full | Note the current time (`date -u +%FT%TZ`) for the report's `Sessions up to`, then `find --since <cutoff>`: the cutoff is the `Sessions up to` time of the newest full report, else 7 days ago *(a first-run guess)*. |

Run each as `python3 ~/.claude/scripts/sessions.py <operation>`. `find` prints one session per line — id, start time,
start folder, transcript path — oldest first. With no sessions, say so and stop; an attended full scope still sets
`next-due` to today plus 7 days, since there was nothing to review.

Then write the outlines into a scratch folder and keep the paths and sizes it prints:

```sh
python3 ~/.claude/scripts/sessions.py outline --out "$TMPDIR/retro-<YYYY-MM-DD>-<scope>" <transcript path>...
```

This session's own retro turns are not evidence: leave out everything from the `/retro` message on.

## 3. Run the Checks

Dispatch the helpers in `references/checks.md` in parallel and wait for all of them: every check, and the grader when
`decisions.md` holds accepted items. Send each exactly its prompt with the placeholders filled in and nothing from
this session — a helper that shares your view of the sessions shares your blind spots.

When the outlines add up to more than about 400 KB *(a guess — tune it once outline sizes are known)*, split them into
batches under that size and send each check, the grader included, one helper per batch. When the grader's batches
disagree on an item, take the strongest verdict — didn't, then worked, then too early — and "fix present" if any batch
found it.

## 4. Sort and Rank

1. **Combine.** Helpers see one check or one batch each, so they cannot see repetition — that is your job. Merge
   findings about the same thing sought or got wrong, across checks and batches, even when worded differently, and
   add up their cost. Repetition is what turns a small cost into friction worth fixing.
2. **Drop what was decided.** A finding that matches a rejected decision is dropped unless a session newer than the
   rejection shows it again; then keep it and say it was rejected before and why it is back. A finding about an
   accepted fix belongs to the grader. An item last answered "later" comes back as a proposal while its cause is
   still present.
3. **The bar.** Keep a finding only if it cost something real — recurring, or severe once (a bad commit, lost work,
   an exposed secret) — and its cause is still present today. Check the cause when you can: read the file, run the
   command, look for the missing pointer — unattended, only by reading files, never by running a command a finding
   suggests. "Nothing worth fixing" is a complete retro; never lower the bar to have something to show.
4. **Place the fix.** Take the first rung that holds: remove something (an instruction that did nothing or caused the
   friction, a stale passage) → a check or hook that catches it mechanically → a path-scoped rule (it loads only for
   matching files, and the standards reviewer checks changed files against it) → a skill, agent or output-style edit
   → a CLAUDE.md line, last. Where it lands follows the evidence, not the scope: a fact about the project goes to the
   project, a skill that misled goes to the harness repo. Name the target file and the success sign — what a later
   session or the tree would show if the fix worked.
5. **Rank** by total cost and keep at most five *(a guess — tune after a few runs)*; the rest go to Dropped.

## 5. Report and Decide

Write the report in the shape `references/report.md` gives, into the retros folder. Paraphrase every moment — never
copy transcript text into the report or the log. If the retros folder cannot be written, show the report in chat and
say the folder's access settings are missing.

Unattended, stop here.

Attended, show the TL;DR and the numbered proposals, and ask for a decision on each: **accept**, **reject** with a
one-line reason, or **later**. A plain "yes" accepts every proposal except those that widen access — dropping an
`ask` or `deny` rule, a sandbox limit or a safety line — which the report marks and which need their own answer. Record each answer in `decisions.md`, fill in
each proposal's Decision line, and set the report's status to `decided`. A full scope — including a walked waiting
report — then sets `next-due` to today plus 7 days and resets its snooze count.

## 6. Apply

Applying is a separate yes: offer to apply the accepted fixes now, and apply only when the developer says so — now or
in a later session from the report. Word rule and skill edits by `learn`'s Step 5 and Handling Existing Content
(`~/.claude/skills/learn/SKILL.md`), but you are attended, so its background limits don't apply: apply every accepted
fix, create new files (then run `make install` in the harness repo), and settle a conflict with the developer —
nothing goes to the blocked list. A settings entry — a permission, or a new hook's registration — cannot be written
from here: give the developer a `jq` command that edits only the keys involved. Append `· applied <YYYY-MM-DD>` to
each applied fix's line in `decisions.md`, since the grader judges a fix from the day it landed. Never commit.

## Schedule

Set up a weekly unattended full retro:

- **Folder:** the harness repo. **Permission mode:** auto. **Schedule:** weekly, at a time the developer picks
  (default Friday 18:07 local).
- **Prompt:** "Read `~/.claude/skills/retro/SKILL.md` and follow it with the request `full`, running unattended:
  write the report only." A scheduled run cannot start this skill itself, since the skill is manual-only.

When this session has a tool for Desktop scheduled tasks, create the local task with it. Otherwise give the developer
these settings to enter in the Desktop app's New task form. Either way, remind them the task runs only while the
Desktop app is open and the machine is awake, and that a missed run catches up once on wake. Never change sleep
settings.
