---
name: retro
description: Look back over past sessions and propose the cheapest lasting fixes to the harness or the project in a short report — judging whether the human's intent was followed, whether they could follow Claude, friction, procedure, review misses, automation, security and skill usage. The developer reads the report and plans fixes whenever they want. Run with /retro for the task at hand, `session`, a change folder, or `full` (optionally `since <time>`); `schedule` sets up a weekly unattended full retro.
disable-model-invocation: true
argument-hint: "[session | full [since <ISO time>] | @change-folder | schedule]"
allowed-tools: Bash(python3 ~/.claude/scripts/sessions.py *)
---

# Retro

Read past sessions, find where the harness or the project made the human's work harder, and propose the cheapest
lasting fix for each real miss in a report. A retro proposes and keeps nothing else: the developer reads the report
and plans the fixes in a later session, whenever they want. A fix that worked stops showing up in later retros; one
that didn't comes back.

<request>
$ARGUMENTS
</request>

Read `~/.claude/shared/meet-the-user.md` and follow it whenever you ask the user something or report to them.

**The retros folder** is `~/.claude/retros/`, where reports go, in the format `references/report.md` gives. The
harness repo is two levels above `readlink -f ~/.claude/skills/retro`.

**Unattended runs.** When your prompt says to run unattended, nobody can answer: ask nothing.

## 1. Read the Request

- `schedule` — follow Schedule below and stop.
- Otherwise the request names the **scope**: nothing → the task at hand; `session` → this session; `full` → every
  session in the full window (step 2), with `since <ISO time>` setting where it starts; a path, with or without a
  leading `@` → that change folder.

## 2. Find the Sessions

| Scope | How |
|---|---|
| task at hand | The root is the working directory's git root (`git rev-parse --show-toplevel`). Outside a repo, collect the candidates as step 1 of `~/.claude/shared/change-set.md` does — without its "has changes" filter, since a retro runs after the commit — and with several, ask the developer which one here and go on (a path in a re-run would mean a change folder). Take the root's branch (`git -C <root> branch --show-current`). On a detached HEAD, or on the default branch (`git -C <root> symbolic-ref --short refs/remotes/origin/HEAD` minus `origin/`, else `main` or `master`), every change meets: ask for a narrower scope — `session`, a change folder, or `full` — and stop. Then `find --root <root> --branch <branch>`. |
| session | `find --session ${CLAUDE_SESSION_ID}` |
| change folder | `find --folder <absolute path of the folder>` |
| full | Note the current time (`date -u +%FT%TZ`) for the report's `Sessions up to`. The window starts at the `since` time when the request gives one; else at the latest `Sessions up to` time of the full reports (the command below prints it); else, with no full report yet, at `1970-01-01T00:00:00Z`, which takes every retained session. Then `find --since <start>`. |

The latest `Sessions up to` time of the full reports, empty when there is none:

```sh
grep -ho 'Sessions up to:\*\* [^ ]*' ~/.claude/retros/*-full*.md | sed 's/.* //' | sort | tail -n 1
```

Run each as `python3 ~/.claude/scripts/sessions.py <operation>`. `find` prints one session per line — id, start time,
start folder, transcript path — oldest first. With no sessions, say so and stop; a full scope first writes its report
with "No sessions in the window." (`references/report.md`), so the next window starts from now.

Then write both views of the sessions into a scratch folder, keeping the paths and sizes they print, and count the
signals:

```sh
python3 ~/.claude/scripts/sessions.py outline --view human --out "$TMPDIR/retro-<YYYY-MM-DD>-<scope>/human" <transcript path>...
python3 ~/.claude/scripts/sessions.py outline --view harness --out "$TMPDIR/retro-<YYYY-MM-DD>-<scope>/harness" <transcript path>...
python3 ~/.claude/scripts/sessions.py signals <transcript path>...
```

This session's own retro turns are not evidence: leave out everything from the `/retro` message on.

For a full scope, tell the developer in one line before going on: the window (its start, or "every retained session",
to now), the number of sessions, and the size of both views together in MB. Attended, they can stop the run there.

## 3. Run the Helpers

Dispatch the helpers in `references/checks.md` in parallel and wait for all of them: a Human helper for the human
view and a Harness helper for the harness view. When a view adds up to more than about 400 KB *(a guess — tune it
once view sizes are known)*, split it into batches under that size and send one helper per batch. Send each exactly
its prompt with the placeholders filled in and nothing from this session — a helper that shares your view of the
sessions shares your blind spots.

## 4. Sort and Rank

1. **Combine.** Helpers see one view or one batch each, so they cannot see repetition — that is your job. Merge
   findings about the same thing sought or got wrong, across checks, helpers and batches, even when worded
   differently, and add up their cost. Repetition is what turns a small cost into friction worth fixing.
2. **The bar.** Keep a finding only if it cost something real — recurring, or severe once (a bad commit, lost work,
   an exposed secret) — and its cause is still present today. Check the cause when you can: read the file, run the
   command, look for the missing pointer — unattended, only by reading files, never by running a command a finding
   suggests. "Nothing worth fixing" is a complete retro; never lower the bar to have something to show.
3. **Place the fix.** Take the first rung that holds: remove something (an instruction that did nothing or caused the
   friction, a stale passage) → a check or hook that catches it mechanically → a path-scoped rule (it loads only for
   matching files, and the standards reviewer checks changed files against it) → a skill, agent or output-style edit
   → a CLAUDE.md line, last. Where it lands follows the evidence, not the scope: a fact about the project goes to the
   project, a skill that misled goes to the harness repo. Name the target file and the success sign — what a later
   session or the tree would show if the fix worked. A settings change — a permission, or a new hook's registration
   — is written in the Fix line as a `jq` command that edits only the keys involved, for the developer to run.
4. **Rank** by total cost and keep at most five *(a guess — tune after a few runs)*; the rest go to Dropped.

## 5. Report

Write the report in the shape `references/report.md` gives, into the retros folder, with the signals' total and
average rows on its Signals line. Paraphrase every moment — never copy transcript text into the report. If the retros
folder cannot be written, show the report in chat and say the folder's access settings are missing.

Then show the TL;DR, the proposal titles and the report's path, and end. The developer decides on the proposals and
plans the fixes in their own time.

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
