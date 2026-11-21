---
name: pr-summary
description: Write a brief, copyable PR or MR summary of a branch's changes against a target branch (the default branch unless one is named), with the evidence, risk and deferred items from the change's validation report when one exists. Use when the user asks for a PR summary, PR/MR description or merge request summary, or accepts validate's offer to write one.
model: haiku
context: fork
background: false
argument-hint: "[repo] [target-branch] [@change-folder]"
---

**Mode: PR.** Arguments: `$ARGUMENTS` — may name the repo to describe, a target (base) branch, and a change folder.

## Step 1: Find the Change Set

A token that starts with `@`, or is a path to a folder that is not a git repo root and lies under a `.claude/plans/`
directory or holds `design*.md`, `plan*.md` or `validation*.md` files, is the **change folder**; set it aside. Then read `~/.claude/shared/change-set.md`
and follow it with the remaining arguments.

## Step 2: Find the Validation Report

`<repo>` below is the basename of CHANGE_SET_ROOT. In a folder, prefer `validation-<repo>.md` over `validation.md`.

- **With a change folder** — its report for the chosen repo; none in it → as **None found**.
- **Without one** — among `<CHANGE_SET_ROOT>/.claude/plans/*/validation*.md`, the reports whose `**Branch:**` line
  names CURRENT_BRANCH; take the report in the folder with the highest number prefix. Remember that folder's path,
  relative to CHANGE_SET_ROOT: the Evidence section names it, so a reader can see which report was picked. A change
  spanning several repos keeps its folder outside them, so its report is found only when the change folder is passed.
- **None found** — leave out Evidence, Risk and Deferred.

## Step 3: Write the Summary

Read the commits and each changed file's diff. From them, write what changed on this branch and why. From the
validation report, if any, take the scenario results, the Risk section and the Deferred list.

## Output Format

Reply with a single fenced markdown code block, opened and closed with four backticks so a diff quoted inside cannot
end it early, and nothing outside it — the user copies it with one click. The one exception: when finding the change
set stopped (a candidate list, "no changes", or a request to name the base branch), reply with exactly that instead.

Use this format, leaving out sections as the rules below say:

````markdown
# [branch-name]

1-2 sentence overview of what changed and why.

## Area/feature

summary on what was done

## Area/feature

summary on what was done

## Evidence

- <scenario> — <Pass|Fail|Blocked> (<how real>)

Validated in `<change folder>`.

## Risk

<the report's Risk section, condensed to a few lines>

## Deferred

- [ ] <deferred finding>
````

<example>
````markdown
# feat/oauth-login

Adds Google sign-in next to password login, so users without a password can create an account.

## Login

New "Sign in with Google" button on the login page; the callback creates the account on first sign-in and links it
by email when one exists.

## Sessions

OAuth sessions use the existing session store and expire like password sessions.

## Evidence

- Sign in with a new Google account — Pass (real app)

Validated in `.claude/plans/03-oauth-login`.

## Risk

Reversible by reverting the commit. Affects only login; linking by email is safe because Google returns verified
addresses — proven by a test.
````
</example>

## Rules

- Keep it very short — a quick glance should tell the reader what happened
- Use short `##` sections grouped by area/feature, focused on *what* and *why* — no file lists, no editorializing or
  suggested improvements
- Evidence, Risk and Deferred come only from a validation report: leave all three out when there is none, and leave out
  Deferred when its list is empty
