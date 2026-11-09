# dotclaude

User-level Claude Code configuration: the rules, skills, commands, agents and hooks that shape how Claude works across every project.

## Language

### Workspaces

**Index repo**:
A working directory whose direct children are several **Project repos**; may itself be a git repository, in which case it is also a **Project repo**.
_Avoid_: monorepo, workspace, outer repo

**Project repo**:
A git repository holding one project's code; the unit that git-aware artifacts (reviews, commit messages, PR summaries, the lint/test gate) operate on.
_Avoid_: repo (when an **Index repo** may be meant), codebase

**Project worktree**:
An additional git worktree of a **Project repo**, checked out in its own directory anywhere on disk — not necessarily under the **Index repo**.
_Avoid_: checkout, clone

**Change set**:
The changes under review or description in exactly one **Project repo** or **Project worktree** — never spanning several.
_Avoid_: diff (for the whole set)

## Example dialogue

> **Dev:** I edited files in two **Project repos** — does `/commit-msg` write one message?
> **Expert:** Two. Each **Project repo** has its own **Change set**, so each gets its own message.
> **Dev:** And a **Project worktree** of the same repo?
> **Expert:** Its own **Change set** too — the worktree's changes are separate from the main checkout's.
