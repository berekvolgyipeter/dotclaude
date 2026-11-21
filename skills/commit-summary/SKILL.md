---
name: commit-summary
description: Summarize the uncommitted changes for the developer before they commit — a plain-language summary, a tree of the changed files, and a suggested conventional commit message. Use only when the user asks for a commit message or a summary of their uncommitted changes before committing.
model: haiku
context: fork
background: false
argument-hint: "[repo]"
---

**Mode: delta.** Arguments: `$ARGUMENTS` — may name the repo to describe.

The reader is the developer about to commit, possibly on a phone and without the repo open: they have seen neither the
diff nor the session that made it.

## Step 1: Find the Change Set

Read `~/.claude/shared/change-set.md` and follow it with the arguments.

## Step 2: Read the Changes

Start with the changed and untracked files from the overview, and `git -C <root> diff --stat HEAD` for their size.
Read each changed file's diff and each untracked file, enough to say what it does and why. Note the change type, the
area it touches, and whether it breaks an interface.

## Step 3: Write the Summary

- **Summary** — bullet points, one per topic the change touches: what changed there and why, in words a newcomer
  understands. Group related edits into one bullet; no file names.
- **Files** — a tree of the changed files only, rooted at the repo, each file with a `←` note of a few words on what
  changed in it. Mark added files `(new)`, deleted `(deleted)` and renamed `(from <old path>)`.
- **Commit message** — one line per the rules below.

### Commit message

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <imperative summary>
```

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

- **Imperative mood** — "add X", not "added X" or "adds X"
- **No period** at the end
- **≤ 72 characters** total (type + scope + summary)
- **Lowercase** summary after the colon
- Scope is optional — use it when the change is clearly scoped to one area (e.g. `fix(auth): ...`)
- If the change spans multiple concerns, use the dominant concern's type and omit the scope
- Add `!` after the type/scope when the change breaks an existing interface (e.g. `feat!: drop v1 API`)

## Output

Reply with exactly these three parts, in this order, and nothing else — the two blocks are separate so each copies in
one click. The one exception: if finding the change set stopped with a list or a "no changes" note, reply with that
instead.

1. The summary bullets, outside any code block.
2. The files tree, in its own fenced code block.
3. The commit message, in another fenced code block of its own.

<example>
- **Planning** — plans now say which folder each module lives in, so new code lands next to the code it changes
  with instead of piling into an existing flat folder.
- **Implementing** — the build step follows the plan's folder layout.

```
dotclaude/
└── skills/
    ├── implement/
    │   └── SKILL.md            ← reads the plan's folder tree
    └── write-plan/
        ├── SKILL.md            ← placement rule and a Layout self-check
        └── references/
            └── plan-template.md ← Location field, Output Structure section
```

```
feat(write-plan): design module folder layout with Location and Output Structure
```
</example>

This skill only suggests a message; leave staging and committing to the user.
