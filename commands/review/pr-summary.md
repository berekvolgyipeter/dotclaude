---
name: pr-summary
description: Generate a brief PR summary of branch changes compared to a target branch. If no target branch is passed, it defaults to the default branch.
disable-model-invocation: true
model: haiku
argument-hint: "[target-branch]"
allowed-tools:
  - Bash(bash $HOME/.claude/scripts/review/pr-diff.sh *)
  - Agent(review:diff-summarizer)
---

!`bash $HOME/.claude/scripts/review/pr-diff.sh $ARGUMENTS`

The branch change overview above contains the DIFF_BASE, changed files, commits, and untracked files.

## Task

Dispatch a `review:diff-summarizer` subagent with the file list, untracked files, and DIFF_BASE from the overview above. The agent will read per-file diffs and return a structured summary.

Using the subagent's summary, generate a concise, human-readable PR summary of what changed on this branch compared to the target branch.

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

- Your ENTIRE response is the fenced code block — nothing else
- Keep it very short — a quick glance should tell the reader what happened
- Use short `##` sections grouped by area/feature as shown in the template
- Focus on *what* and *why*, not file-by-file details
- Do not editorialize, suggest improvements, or list individual files — just summarize
