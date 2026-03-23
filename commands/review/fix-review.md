---
name: fix-review
description: Process to fix bugs found in manual/AI code review
disable-model-invocation: true
allowed-tools:
  - Bash(bash $HOME/.claude/scripts/review/latest-review.sh)
---

The review file to fix is:

!`bash $HOME/.claude/scripts/review/latest-review.sh`

User feedback or questions: $ARGUMENTS

Read the review file above. If no review file path is shown above, tell the user no review files exist and stop.

---

## Step 1: Handle User Input

If the user provided feedback or questions, address those first.
- Answer questions directly
- If they say "skip #3" or "only fix critical ones", adjust your plan accordingly
- Once resolved, proceed

## Step 2: Plan and Track Fixes

Create a TodoList with all issues in the order they appear in the review file (they are already prioritized by severity).

Mark each as `pending` before starting. Move to `in_progress` when you begin, `completed` when done.

## Step 3: Re-read Standards

Before writing any code load the applicable rule files for the files you're about to change.

@~/.claude/shared/rules-index.md

This ensures guidelines are fresh in context at the point of action, not just loaded at the start of a review.

## Step 4: Fix Each Issue

For each issue, the review already explains the problem and suggests a fix. Your job is to apply it:
1. **Apply the fix** using the appropriate edit tools
2. **Verify** — run targeted tests if possible to confirm the fix works

If a fix would conflict with another issue already fixed, note the conflict and adapt.

## Step 5: Finalize

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

## Step 6: Summary

End with a concise summary:
- How many issues were fixed (and at what severity)
- Any issues skipped and why
- Whether lint and tests pass
