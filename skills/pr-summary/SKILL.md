---
name: pr-summary
description: Write a brief, copyable PR summary of a branch's changes against a target branch (the default branch unless one is named), with the evidence, risk and deferred items from the change's validation report when one exists. Use when the user asks for a PR summary or PR description, or accepts validate's offer to write one.
model: haiku
context: fork
background: false
argument-hint: "[repo] [target-branch] [@change-folder]"
---

**Mode: PR.** Arguments: `$ARGUMENTS` — may name the repo to describe, a target (base) branch, and a change folder.

## Step 1: Find the Change Set

A token that is a path to a folder under a `.claude/plans/` directory, or starts with `@`, is the **change folder**;
set it aside. Then read `~/.claude/shared/change-set.md` and follow it with the remaining arguments.

## Step 2: Find the Validation Report

`<repo>` below is the basename of CHANGE_SET_ROOT. In a folder, prefer `validation-<repo>.md` over `validation.md`.

- **With a change folder** — its report for the chosen repo.
- **Without one** — among `<CHANGE_SET_ROOT>/.claude/plans/*/validation*.md`, the reports whose `**Branch:**` line
  names CURRENT_BRANCH; take the report in the folder with the highest number prefix. Remember that folder's path,
  relative to CHANGE_SET_ROOT: the Evidence section names it, so a reader can see which report was picked.
- **None found** — leave out Evidence, Risk and Deferred.

## Step 3: Write the Summary

Read the commits and each changed file's diff. From them, write what changed on this branch and why. From the
validation report, if any, take the scenario results, the Risk section and the Deferred list.

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

## Evidence

- <scenario> — <Pass|Fail|Blocked> (<how real>)

<only when no change folder was given: Validated in `<change folder>`.>

## Risk

<the report's Risk section, condensed to a few lines>

## Deferred

- [ ] <deferred finding>
```

## Rules

- Your ENTIRE response is the fenced code block — nothing else, unless finding the change set stopped (a candidate list, "no changes", or a request to name the base branch): then reply with exactly that
- Keep it very short — a quick glance should tell the reader what happened
- Use short `##` sections grouped by area/feature as shown in the template
- Focus on *what* and *why*, not file-by-file details
- Do not editorialize, suggest improvements, or list individual files — just summarize
- Evidence, Risk and Deferred come only from a validation report: leave all three out when there is none, and leave out Deferred when its list is empty
- Write the "Validated in" line only when the report was found without a change folder argument
