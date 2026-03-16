---
name: review
description: Technical code review for quality and bugs for changes to a target branch. If no target branch is passed, it defaults to the default branch.
disable-model-invocation: true
argument-hint: "[target-branch]"
allowed-tools:
  - Bash(bash $HOME/.claude/scripts/pr-diff.sh *)
  - Bash(make lint)
  - Bash(make test)
---

!`bash $HOME/.claude/scripts/pr-diff.sh $ARGUMENTS`

@~/.claude/shared/code-review.md
