---
name: delta-review-diff
description: Diff-only code review comparing uncommitted local changes against the latest commit — reviews only the diff hunks, never the full files, and skips lint/test checks
disable-model-invocation: true
allowed-tools:
  - Bash(bash ~/.claude/scripts/review/delta-diff.sh)
  - Bash(git diff *)
  - Bash(git show *)
  - Agent(review:code-reviewer-diff)
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: bash ~/.claude/hooks/block-git-mutations.sh
---

REVIEW_SCOPE: diff-only

!`bash ~/.claude/scripts/review/delta-diff.sh`

@~/.claude/shared/code-review.md
