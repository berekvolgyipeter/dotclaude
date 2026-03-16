---
name: pr-review
description: Technical code review for quality and bugs for changes to a target branch. If no target branch is passed, it defaults to the default branch.
disable-model-invocation: true
argument-hint: "[target-branch]"
allowed-tools:
  - Bash(bash $HOME/.claude/scripts/pr-diff.sh *)
  - Bash(make lint)
  - Bash(make lint 2>&1 || echo *)
  - Bash(make test)
  - Bash(make test 2>&1 || echo *)
---

!`bash $HOME/.claude/scripts/pr-diff.sh $ARGUMENTS`

@~/.claude/shared/code-review.md
