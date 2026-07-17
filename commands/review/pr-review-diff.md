---
name: pr-review-diff
description: Diff-only code review for changes to a target branch — reviews only the diff hunks, never the full files, and skips lint/test checks. If no target branch is passed, it defaults to the default branch.
disable-model-invocation: true
argument-hint: "[target-branch]"
allowed-tools:
  - Bash(bash ~/.claude/scripts/review/pr-diff.sh *)
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

!`bash ~/.claude/scripts/review/pr-diff.sh $ARGUMENTS`

@~/.claude/shared/code-review.md
