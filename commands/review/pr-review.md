---
name: pr-review
description: Technical code review for quality and bugs for changes to a target branch. If no target branch is passed, it defaults to the default branch.
disable-model-invocation: true
argument-hint: "[target-branch]"
allowed-tools:
  - Bash(bash $HOME/.claude/scripts/review/pr-diff.sh *)
  - Bash(make lint)
  - Bash(make lint 2>&1 || echo *)
  - Bash(make test)
  - Bash(make test 2>&1 || echo *)
  - Bash(git diff *)
  - Bash(git show *)
  - Agent(review:code-reviewer)
---

!`bash $HOME/.claude/scripts/review/pr-diff.sh $ARGUMENTS`

@~/.claude/shared/code-review.md
