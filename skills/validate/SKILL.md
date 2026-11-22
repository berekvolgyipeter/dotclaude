---
name: validate
description: Validate a finished change before the developer reviews the diff and commits — independent helpers check it against its goal, plan and design and run it for real; the approved fixes are made in one round, and a validation report records run evidence, a risk summary and a diff reading order. Use after implement reports done, or on any change written by hand, when the user wants proof it works or asks to validate, verify or check a change against its goal.
argument-hint: "[@change-folder]"
---

# Validate

Check a finished change against what it was for, run it for real, and hand the developer a map for the diff review.

<request>
$ARGUMENTS
</request>

Read `~/.claude/shared/meet-the-user.md` and follow it whenever you ask the user something or report to them.

## 1. Resolve the Inputs

- **Change folder** — the one the request names, else the one this conversation worked in, else none.
- **Plan and design** — the change folder's `plan.md` and `design.md` (or `plan-<repo>.md`, `design-<repo>.md`; when
  the folder holds one plan per repo and the request names none, ask which repo before anything else).
- **Goal** — the design's Goal section, else the plan's, else what the user wants to be true as this conversation
  settled it. With none of these, ask for it in one line, with your best reading as the recommended answer.
- **Change set** — follow `~/.claude/shared/change-set.md`, naming the plan's repo when the plan names one, with the
  first base that applies, so committed work is included:
  - since mode with the plan's base from Before You Start;
  - since mode with the branch's merge-base with the default branch, when the branch has commits ahead of it;
  - delta mode.

  Keep the root, branch, diff base and file list. If it stops with a list or "no changes", relay that and stop. Pass
  the root as the repo to every `review-changes` call below.
- **Earlier answers** — when the folder already holds a validation report, read its as-is findings and its unticked
  Deferred items: as-is findings stay accepted and are not raised again, and both carry into the new report.

## 2. Run the Checks

Dispatch the helpers in `references/checks.md` in parallel, and wait for all of them:

- **goal and plan**, and **run it for real** — always;
- **design** — only with a plan or design, since without one there is no agreed shape to check against.

Send each exactly its prompt with the placeholders filled in. Add nothing from this session: the author's reasoning
anchors a reviewer to the author's blind spots, and an independent check is worth running only because it does not
share them.

When the change got no code review — no `review-changes` run earlier in this conversation, and no plan whose
Execution Record has a `Complete` entry — invoke the `review-changes` skill with `<root> since <the change set's diff
base>` once the checks have returned: its lint run may rewrite files, which the run check would blame on its own runs.
Its findings join the others in step 3; fix none of them before the developer answers.

## 3. Sort the Findings

First merge findings that point at the same problem — the checks overlap, so one bug often comes back two or three
times; keep the clearest wording and the highest severity. Then sort each finding before showing anything:

- **misread** — the helper got the goal, plan or design wrong: drop it, and note whether the plan or design invited
  the misreading;
- **actionable** — true and worth acting on: keep it;
- **trade-off** — true, but already accepted: by the design, the plan, the conversation or an earlier as-is answer;
  drop it. An entry in the plan's Execution Record accepts nothing: it is the author's note, not an agreement;
- **noise** — drop it.

Keep every dropped finding with its sort and a one-line reason for the report: you are sorting the work of the
session that wrote the change, so a drop the developer cannot see is where its bias slips back in.

Show the actionable findings in one message, in the shape `~/.claude/skills/review-changes/references/finding.md`
defines, numbered once across both groups, worst first — each helper numbered its own from 1 — and split into two
groups:

- **Decisions** — findings where a reasonable developer could choose differently: judgement calls, and bugs with
  more than one sensible fix. Each with the options and your recommended answer — fix now, later or as-is.
- **Mechanical fixes** — bugs with one obvious fix. Each with your recommended answer.

Above them, one line per scenario with its result, the run check's working-tree line, and a count of what was
dropped by sort. Files the runs changed in the working tree are a mechanical fix: undo them. End with: a plain "yes"
applies every recommendation; otherwise name the findings to change. When nothing is actionable, say so and go to
step 5.

## 4. Fix

Act on the developer's answer:

- **fix now** — fixed in the round below.
- **later** — no change; it goes in the report's Deferred list.
- **as-is** — no change; record it with the developer's reason, so a later run does not raise it again.

One round fixes every fix-now finding:

1. **Snapshot.** Before the first fix, take the snapshot the `review-changes` skill describes.
2. **Fix.** A behaviour change goes test-first through the `tdd` skill; anything else directly. Record each fix as
   you make it, as `<what> — <why> — <cost if wrong>`: in the plan's Execution Record when there is a plan — after
   its closing `Complete` entry, under a `Validation` entry — otherwise in the report.
3. **Test.** Run the lint and test commands `bash ~/.claude/scripts/check-commands.sh <root>` prints; for a target it
   prints as `none`, run the project's documented command.
4. **Recheck.** Rerun once each check that raised a fixed finding, with the same prompt; the run check also gets its
   first-run scenario blocks, with the instruction to run those scenarios again, failed ones first, so the fix is
   proven on the scenario that failed. Evidence keeps each scenario's latest result. Then invoke the
   `review-changes` skill with `<root> since <snapshot>`, so the fixes get a code review of their own. Sort what comes back
   as in step 3.
5. **Hand back.** Show each finding still open, and each new one, as a Decision with what is wrong and three
   options — **retry** (this round again, for that finding only), **later**, or **as-is** — and act on the answer.
   Never start another round without the developer's answer.

## 5. Report

Write the validation report in the shape `references/report.md` gives, carrying over the earlier report's as-is
findings and unticked Deferred items that this run did not fix: `validation.md` in the change folder, or
`validation-<repo>.md` when the folder covers several repos. Without a change folder, create one as the Change folder
section of `~/.claude/shared/planning-context.md` says, named after the goal.

The checks give you the evidence and findings; Risk and the Reading Order are yours to write. Read the change set's
diff for them: what a revert undoes, who else calls or reads what changed, and the one fact the change is safe
because of.

The Reading Order spends the developer's review on risk, not on every line. Under **Read**, list only the spots a
passing test does not make safe: a one-way change (a destructive migration, deleted data, a removed public interface,
anything sent outward), a change other repos, services or stored data depend on, a change to auth, a cross-service
contract or concurrency, and whatever Risk left unproven. Everything else goes under **Skim**, one line each with what
makes it safe. Doubt your own "reversible" most: a diff often hides that a change cannot be undone. When the
project's CLAUDE.md or rules list changes it always treats as one-way, every change that matches one is one-way.

Then reply in chat with only:

- the verdict, one line;
- the reading order;
- the offer, for after the commit: "Once committed, I can write the PR summary with `pr-summary @<change folder>`,
  and `/retro @<change folder>` looks back at how this change's sessions went."
