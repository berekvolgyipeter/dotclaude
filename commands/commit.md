---
name: commit
description: Stage all changes and commit with a suggested conventional commit message.
disable-model-invocation: true
model: haiku
allowed-tools:
  - Bash(bash $HOME/.claude/scripts/review/delta-diff.sh)
  - Bash(git add -A)
  - Bash(git commit -m *)
  - Bash(git log *)
  - Agent(review:diff-summarizer)
---

!`bash $HOME/.claude/scripts/review/delta-diff.sh`

Stage all changes and commit them with a concise, conventional commit message.

## Step 1: Summarize Changes

Dispatch a `review:diff-summarizer` subagent with the file list, untracked files, and DIFF_BASE from the overview above. The agent will read per-file diffs and return a structured summary including change type, scope, and description.

## Step 2: Derive the Commit Message

Using the summary from the subagent, produce **one short commit message** following [Conventional Commits](https://www.conventionalcommits.org/):

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

## Step 3: Stage and Commit

First, show the proposed message to the user as a code block:

```
<type>(<scope>): <summary>
```

Then run both commands in sequence:

```bash
git add -A
git commit -m "<proposed message>"
```

If the commit fails, report the error and stop — do not retry or bypass hooks.

## Step 4: Confirm

Run `git log --oneline -3` and show the output so the user can verify the commit landed.
