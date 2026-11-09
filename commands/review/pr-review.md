---
name: pr-review
description: Technical code review of a branch's changes against its base branch (default branch unless one is named), run in the background — findings arrive in the session when done
disable-model-invocation: true
context: fork
argument-hint: "[repo] [base-branch] [focus]"
allowed-tools:
  - Bash(git -C * fetch *)
  - Agent(review:code-reviewer)
---

**Mode: PR.** Arguments: `$ARGUMENTS` — may name the Project repo to review and a base branch; any other text is a focus hint.

@~/.claude/shared/change-set.md

@~/.claude/shared/code-review.md
