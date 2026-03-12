---
name: pr-summary
description: Generate a brief PR summary of branch changes compared to base branch.
disable-model-invocation: true
---

Set `BASE_BRANCH` to `$ARGUMENTS` if provided, otherwise `main`.

Generate a concise, human-readable PR summary of changes on this branch compared to the base branch.

## Step 1: Gather Changes

Fetch the latest remote state:
```bash
git fetch origin $BASE_BRANCH
```

See which files changed and line counts:
```bash
git diff --stat origin/$BASE_BRANCH
```

See commit history on this branch:
```bash
git log origin/$BASE_BRANCH..HEAD --oneline
```

See the full diff:
```bash
git diff origin/$BASE_BRANCH
```

See untracked files:
```bash
git ls-files --others --exclude-standard
```

## Step 2: Read Changed Files

Read each changed file to understand the full context — not just the diff.

## Step 3: Write the Summary

Save to `.claude/.code-reviews/[current-branch-name]--pr-summary--yyyy-mm-dd--HH-MM.md`

Use this format:

```markdown
# PR Summary: [branch-name]

**Base:** `$BASE_BRANCH` | **Date:** yyyy-mm-dd

## Overview

Brief 2-4 sentence overview of the purpose and scope of the changes.

## Changes

Group changes by feature or logical area — not by individual file. Each group should explain what was done and why. Mention key files only when it helps the reader understand the change.

### Feature/Area Name

Brief description of what changed in this area and why.

### Another Feature/Area

Brief description.

## Notes

Anything a reviewer should know: breaking changes, migration steps, follow-ups needed, or dependencies.
```

## Important

- Be brief — this is for humans scanning a PR
- Group changes by feature, logical area, or purpose — never list hundreds of files individually
- Focus on *what* and *why*, not line-by-line diffs
- Mention specific files only when it adds clarity (e.g. a new entrypoint, a config change)
- Omit the Notes section if there's nothing noteworthy
- Do not editorialize or suggest improvements — just summarize
