---
name: delta-review
description: Technical code review of uncommitted changes against the latest commit, run in the background — findings arrive in the session when done
disable-model-invocation: true
context: fork
argument-hint: "[repo] [focus]"
allowed-tools:
  - Agent(review:code-reviewer)
---

**Mode: delta.** Arguments: `$ARGUMENTS` — may name the Project repo to review; any other text is a focus hint.

@~/.claude/shared/change-set.md

@~/.claude/shared/code-review.md
