---
name: delta-review
description: Technical code review comparing uncommitted local changes against the latest commit on the current branch
disable-model-invocation: true
allowed-tools:
  - Bash(bash $HOME/.claude/scripts/delta-diff.sh)
  - Bash(make lint)
  - Bash(make lint 2>&1 || echo *)
  - Bash(make test)
  - Bash(make test 2>&1 || echo *)
---

!`bash $HOME/.claude/scripts/delta-diff.sh`

@~/.claude/shared/code-review.md
