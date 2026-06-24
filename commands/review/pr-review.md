---
name: pr-review
description: Technical code review for quality and bugs for changes to a target branch. If no target branch is passed, it defaults to the default branch.
disable-model-invocation: true
argument-hint: "[target-branch]"
allowed-tools:
  - Bash(bash ~/.claude/scripts/review/pr-diff.sh *)
  - Bash(bash ~/.claude/scripts/review/automated-checks.sh)
  - Bash(git diff *)
  - Bash(git show *)
  - Agent(review:code-reviewer)
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: bash ~/.claude/hooks/block-git-mutations.sh
---

!`bash ~/.claude/scripts/review/pr-diff.sh $ARGUMENTS`

!`bash ~/.claude/scripts/review/automated-checks.sh`

@~/.claude/shared/code-review.md
