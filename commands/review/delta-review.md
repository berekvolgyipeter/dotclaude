---
name: delta-review
description: Technical code review comparing uncommitted local changes against the latest commit on the current branch
disable-model-invocation: true
allowed-tools:
  - Bash(bash ~/.claude/scripts/review/delta-diff.sh)
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

!`bash ~/.claude/scripts/review/delta-diff.sh`

!`bash ~/.claude/scripts/review/automated-checks.sh`

@~/.claude/shared/code-review.md
