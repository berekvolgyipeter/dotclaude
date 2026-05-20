---
name: commit-msg
description: Generate a suggested conventional commit message for the current changes.
disable-model-invocation: true
model: haiku
allowed-tools:
  - Bash(bash ~/.claude/scripts/review/delta-diff.sh)
  - Bash(git log *)
  - Agent(review:diff-summarizer)
---

!`bash ~/.claude/scripts/review/delta-diff.sh`

Generate a concise, conventional commit message for the current changes.

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

## Output Format

Your entire response must be a single fenced markdown code block so the user can copy it with one click. Do NOT output anything outside the code block — no preamble, no explanation, no follow-up.

Use this exact format:

```markdown
<type>(<optional scope>): <imperative summary>
```

## Rules

- Your ENTIRE response is the fenced code block — nothing else
- Do not stage, commit, or run any git write commands
- Do not editorialize or suggest improvements — just output the message
