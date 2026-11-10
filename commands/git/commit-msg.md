---
name: commit-msg
description: Generate a suggested conventional commit message for the current changes.
disable-model-invocation: true
model: haiku
context: fork
background: false
argument-hint: "[repo]"
---

**Mode: delta.** Arguments: `$ARGUMENTS` — may name the Project repo to describe.

Generate a concise, conventional commit message for the current changes.

@~/.claude/shared/change-set.md

## Step 1: Read the Changes

Read each changed file's diff and each untracked file. Note the change type, the area it touches, and what it does.

## Step 2: Derive the Commit Message

Produce **one short commit message** following [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <imperative summary>
```

### Type rules

| Type | When to use |
|------|-------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `refactor` | Code change that is neither a fix nor a feature |
| `test` | Adding or updating tests |
| `docs` | Documentation only |
| `chore` | Build, tooling, dependencies, config |
| `style` | Formatting, whitespace — no logic change |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |

### Message rules

- **Imperative mood** — "add X", not "added X" or "adds X"
- **No period** at the end
- **≤ 72 characters** total (type + scope + summary)
- **Lowercase** summary after the colon
- Scope is optional — use it when the change is clearly scoped to one area (e.g. `fix(auth): ...`)
- If the change spans multiple concerns, pick the dominant one and keep the scope out

### Examples

```
feat(api): add pagination to /users endpoint
fix: prevent crash when config file is missing
refactor(db): extract query builder into separate module
docs: update installation steps in README
chore: bump dependencies to latest patch versions
test(auth): add edge cases for token expiry
```

## Output Format

Your entire response must be a single fenced markdown code block so the user can copy it with one click. Do NOT output anything outside the code block — no preamble, no explanation, no follow-up.

Use this exact format:

```markdown
<type>(<optional scope>): <imperative summary>
```

## Rules

- Your ENTIRE response is the fenced code block — nothing else, unless finding the Change set stopped with a list or a "no changes" note
- Do not stage, commit, or run any git write commands
- Do not editorialize or suggest improvements — just output the message
