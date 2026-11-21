---
name: commit-msg
description: Generate a suggested conventional commit message for the current changes.
disable-model-invocation: true
model: haiku
context: fork
background: false
argument-hint: "[repo]"
---

**Mode: delta.** Arguments: `$ARGUMENTS` — may name the repo to describe.

Generate a concise, conventional commit message for the current changes.

@~/.claude/shared/change-set.md

## Step 1: Read the Changes

Start with the changed and untracked files from the overview, and `git -C <root> diff --stat HEAD` for their size. Read individual diffs or untracked files wherever these leave the type, the scope, what the change does, or whether it breaks an interface unclear. Note the change type, the area it touches, and what it does.

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
| `build` | Build system or dependencies |
| `chore` | Tooling, config, anything that fits no other type |
| `style` | Formatting, whitespace — no logic change |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |
| `revert` | Reverts an earlier commit |

### Message rules

- **Imperative mood** — "add X", not "added X" or "adds X"
- **No period** at the end
- **≤ 72 characters** total (type + scope + summary)
- **Lowercase** summary after the colon
- Scope is optional — use it when the change is clearly scoped to one area (e.g. `fix(auth): ...`)
- If the change spans multiple concerns, use the dominant concern's type and omit the scope
- Add `!` after the type/scope when the change breaks an existing interface (e.g. `feat!: drop v1 API`)

### Examples

```
feat(api): add pagination to /users endpoint
fix: prevent crash when config file is missing
refactor(db): extract query builder into separate module
docs: update installation steps in README
build: bump dependencies to latest patch versions
test(auth): add edge cases for token expiry
```

## Output

Reply with only the message in one fenced code block, so the user can copy it in one click — no preamble, explanation or suggestions. The one exception: if finding the change set stopped with a list or a "no changes" note, reply with that instead.

```markdown
<type>(<optional scope>): <imperative summary>
```

This command only suggests a message; leave staging and committing to the user.
