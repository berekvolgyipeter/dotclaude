---
name: retro
description: Look back over past sessions and report the problems the developer agrees on — their feedback and questions first, in their own words, then friction — each with its cause checked against today's text and earlier fixes. Proposes no fixes; a design session on the whole report designs them. Run with /retro for the task at hand, `session`, a change folder, or `full` (optionally `since <time>`).
disable-model-invocation: true
argument-hint: "[session | full [since <ISO time>] | @change-folder]"
allowed-tools: Bash(python3 ~/.claude/scripts/sessions.py *)
model: opus
---

# Retro

Read past sessions and find where the harness or the project made the developer's work harder: above all what the
developer said — their corrections, pushback, rejection reasons and questions — and then friction. Check each
problem's cause against today's text and what was tried before, go through the worst with the developer, and write
the problems they agree on in a report. A retro finds problems only and never proposes a fix: fixes chosen one problem
at a time become bandages, so a design session on the whole report designs them against the harness as a whole.

<request>
$ARGUMENTS
</request>

Read `~/.claude/shared/meet-the-user.md` and follow it whenever you ask the user something or report to them.

**The retros folder** is `~/.claude/retros/`, where reports go, in the format `references/report.md` gives. The
harness repo is two levels above `readlink -f ~/.claude/skills/retro`.

## 1. Read the Request

The request names the **scope**: nothing → the task at hand; `session` → this session; `full` → every session in the
full window (step 2), with `since <ISO time>` setting where it starts; a path, with or without a leading `@` → that
change folder.

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

This session's own retro turns are not evidence: leave out everything from the `/retro` message on — mark the cutoff
in that outline's line of the helpers' Outlines input, with `<n>` the last line before the `/retro` message in that
view's outline (each view numbers its lines differently).

For a full scope, tell the developer in one line before going on: the window (its start, or "every retained session",
to now), the number of sessions, and the size of both views together in MB. They can stop the run there.

## 3. Run the Helpers

Dispatch the helpers in parallel, with no model override, and wait for all of them: a `retro-human` agent for the
human view and a `retro-harness` agent for the harness view. When a view adds up to more than about 400 KB *(a guess —
tune it once view sizes are known)*, split it into batches under that size and send one helper per batch; an outline
over that size on its own is split by line range, one part per helper. Send each only the inputs listed under Your
Inputs in `references/helper-brief.md` — its Outlines, and the harness root for `retro-human` — and nothing from
this session: no summary of the sessions, no hint of what you expect it to find. A helper that shares your view of
the sessions shares your blind spots.

## 4. Sort and Check

1. **Combine.** Helpers see one view or one batch each, so they cannot see repetition — that is your job. Merge
   findings about the same thing sought or got wrong, across checks, helpers and batches, even when worded
   differently, and add up their sessions, strength and cost. Feedback and questions the developer repeated across
   sessions surface here. Friction the developer complained about is feedback.
2. **The bar.** Feedback always passes: most pushback happens once, and it is the clearest sign of where the harness
   failed the developer. Friction passes only if it cost something real — recurring, or severe once (a bad commit,
   lost work, an exposed secret). A skill step skipped with no harm done costs nothing, but passes on its own as a
   **removal candidate** when it shows in more than one session. "No problems found" is a complete retro; never lower
   the bar to have something to show.
3. **Cause.** For every problem kept, read today's text of the files behind its cause — the skill, rule, setting or
   doc — and say what in it causes the problem. Drop a problem whose cause is gone today.
4. **History.** Read the earlier reports in the retros folder and match their problems to yours by meaning, as
   Combine does. Drop a match an earlier report rejected, unless one of its sessions ran after that report's
   `Sessions up to` time. Then read the commit history of each cause's files, in the repo that holds the file and on
   its real path (`readlink -f <file>`, since `~/.claude` entries are links into the harness repo):

   ```sh
   git -C <folder of the real path> log --date=short --format='%h %ad %s' -- <real path>
   ```

   Read a commit with `git -C <folder> show <hash> -- <real path>` when its message touches the problem. Note what an
   earlier fix tried, when, and that the problem came back; and flag a commit that deliberately removed text a fix
   would put back.
5. **Criticality and rank.** Feedback is high when strong (capitals, repeated "!", calling the work bad) or repeated
   across sessions, else medium. Friction is high when severe once, else medium. A removal candidate is low. Rank
   feedback before friction and removal candidates, then by criticality, then by the number of sessions.

## 5. Agree

1. Write the report first, in the shape `references/report.md` gives, into the retros folder, with the signals'
   total and average rows on its Signals line and every problem under Not gone through. Stopping at any point then
   keeps what was agreed. If the retros folder cannot be written, keep the report in chat and say the folder's access
   settings are missing.
2. Go through the five worst problems one at a time, one per message: the developer's words (or the cost, for
   friction), what happened and the cause, in a few lines, then ask whether that is the problem. A plain "yes"
   confirms it; they may also correct it, or reject it with a reason. After each answer, move the problem in the
   report — to Problems with any correction, or to Rejected with their reason.
3. Then show the rest as a brief list, one line each with its criticality, and offer to go through them the same way.

## 6. Report

Make the final update to the report, then show its path and end. The report's last line names the next step: a
design session on the whole report.
