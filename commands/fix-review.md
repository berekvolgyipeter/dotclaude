---
name: fix-review
description: Process to fix bugs found in manual/AI code review
disable-model-invocation: true
---

User feedback or questions: $1

Find the newest code review file and fix all issues found in it.

## Step 1: Load the Review

Find the newest `.md` file in `.claude/.code-reviews/`:

```bash
ls -t .claude/.code-reviews/*.md | head -1
```

If no files exist, tell the user and stop.

Read the entire file to understand all issues.

## Step 2: Handle User Input

If the user provided feedback or questions above, address those first.
- Answer questions directly
- If they say "skip #3" or "only fix critical ones", adjust your plan accordingly
- Once resolved, proceed

## Step 3: Plan and Track Fixes

Create a TodoList with all issues in the order they appear in the review file (they are already prioritized by severity).

Mark each as `pending` before starting. Move to `in_progress` when you begin, `completed` when done.

## Step 4: Re-read Standards

Before writing any code, read `~/.claude/index/rules.md` and load the applicable rule files for the files you're about to change.

This ensures guidelines are fresh in context at the point of action, not just loaded at the start of a review.

## Step 5: Fix Each Issue

For each issue, the review already explains the problem and suggests a fix. Your job is to apply it:
1. **Apply the fix** using the appropriate edit tools
2. **Verify** — run targeted tests if possible to confirm the fix works

If a fix would conflict with another issue already fixed, note the conflict and adapt.

## Step 6: Finalize

Run lint and tests:

```bash
make lint
```

```bash
make test
```

If either fails:
- Diagnose the failure
- Fix the root cause
- Re-run until passing (or explain clearly why it can't pass)

## Step 7: Summary

End with a concise summary:
- How many issues were fixed (and at what severity)
- Any issues skipped and why
- Whether lint and tests pass
