---
name: pr-summary
description: Generate a brief PR summary of branch changes compared to a target branch. If no target branch is passed, it defaults to the default branch.
disable-model-invocation: true
model: haiku
context: fork
background: false
argument-hint: "[repo] [target-branch]"
---

**Mode: PR.** Arguments: `$ARGUMENTS` — may name the Project repo to describe and a target (base) branch.

@~/.claude/shared/change-set.md

## Task

Read the commits and each changed file's diff, then generate a concise, human-readable PR summary of what changed on this branch compared to the target branch.

## Output Format

Your entire response must be a single fenced markdown code block so the user can copy it with one click. Do NOT output anything outside the code block — no preamble, no explanation, no follow-up.

Use this exact format:

```markdown
# [branch-name]

1-2 sentence overview of what changed and why.

## Area/feature

summary on what was done

## Area/feature

summary on what was done
```

## Rules

- Your ENTIRE response is the fenced code block — nothing else, unless finding the Change set stopped with a list or a "no changes" note
- Keep it very short — a quick glance should tell the reader what happened
- Use short `##` sections grouped by area/feature as shown in the template
- Focus on *what* and *why*, not file-by-file details
- Do not editorialize, suggest improvements, or list individual files — just summarize
