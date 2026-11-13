---
name: delta-review
description: Technical code review of uncommitted changes against the latest commit, run by a background reviewer — the session then evaluates the findings and fixes what holds up
disable-model-invocation: true
argument-hint: "[repo] [focus]"
allowed-tools:
  - Agent
---

Dispatch one `general-purpose` subagent in the background with exactly this prompt, and add nothing about this session's work — the reviewer must judge the code independently:

> Mode: delta. Arguments: `$ARGUMENTS`. Read `~/.claude/shared/change-set.md` and `~/.claude/shared/code-review.md` and follow them exactly: find the change set, then review it. Your final reply is the review output they specify.

Then say the review is running and stop; continue with whatever the user asks meanwhile.

When the review arrives:

- **Findings** — evaluate each one against what you know about this change. Fix those that hold up; for each one you skip, give the reason in one line.
- **A list of candidates, no changes, or a passed review** — relay it as is.
