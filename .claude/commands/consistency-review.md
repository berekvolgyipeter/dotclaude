---
name: consistency-review
description: Review uncommitted changes for consistency with this repo's conventions, structure, and engineering philosophy
disable-model-invocation: true
allowed-tools:
  - Bash(bash ~/.claude/scripts/review/delta-diff.sh)
  - Bash(git diff *)
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: bash ~/.claude/hooks/block-git-mutations.sh
---

!`bash ~/.claude/scripts/review/delta-diff.sh`

The overview above lists the changed files and stats — not the diffs themselves. For each changed file, read its diff on demand with `git diff HEAD -- <file>` (read untracked files directly). Review those changes for **consistency** with this repo (dotclaude): not functional bugs, but alignment with its documented conventions, structure, and engineering philosophy.

## Load the source of truth

Read these before judging — quote the specific rule you're checking against, never paraphrase from memory:

1. `.claude/CLAUDE.md` — the **Rules for Changes** and **Engineering Philosophy** sections.
2. `README.md` and `shared/rules-index.md` — to check whether they are in sync with the change.
3. For each changed file, read the file and its **neighbors** (sibling entries, surrounding lines) to judge whether the new content matches their style.

## Checks

Work through each. For every finding, cite `file:line`, quote the rule it breaks, and give the fix.

### 1. Repo conventions (`.claude/CLAUDE.md` → Rules for Changes)

- **README sync** — was `README.md` updated for every added/removed/changed rule, command, skill, agent, hook, template, or script?
- **Command frontmatter** — does every new or changed command file carry `disable-model-invocation: true`?
- **Rules index sync** — was `shared/rules-index.md` updated when a rule or context-rule *file* was added or removed?
- **Context-rule placement** — do on-demand rule files live in `context-rules/` (not `rules/`) and have their glob registered in `load-context-rules.sh`?
- **Source acknowledgment** — if content was drawn from a `plugin-browser` source, is the repo listed under README *Acknowledgments*?
- **Script placement** — are hook scripts in `hooks/` and helper scripts in `scripts/`?
- **No irrelevant cross-references / no leaked internals** — is every artifact named one the reader actually reads, applies, or invokes? Is every env var, flag, or script detail one the reader actually sets or reacts to?

### 2. Engineering philosophy (only if an engineering-domain artifact changed)

- Uses the exact vocabulary from `improve-codebase-architecture` (*module, interface, implementation, depth, seam, adapter, leverage, locality*) — not "component/service/boundary"?
- Tests framed as behavior-through-interface, not implementation detail?
- The `commands/plan/` pipeline still aligned with the skills it builds on?

### 3. Claude Code best practices

- Frontmatter and hook/command/agent config use **only valid keys and schemas** — verify against the official docs when unsure (use the `claude-code` skill); do not guess.
- Symlink scope respected: repo root = user-level (symlinked to `~/.claude/`); the `.claude/` directory = project-level for this repo only.

### 4. Internal consistency

- New content matches the **style, naming, tone, and formatting** of its neighbors (e.g. human-readable table cells, not raw globs).
- Naming conventions followed: `DOTCLAUDE_*` prefix for this repo's env vars, kebab-case filenames, the accepted truthy set (`1|true|...`) for opt-out switches.

## Output

List findings ordered by severity (CRITICAL → MAJOR → MINOR). For each: `file:line`, the quoted rule, and the concrete fix, using this format:

### CRITICAL | [README.md:120](README.md#L120) — New `foo` command not documented
**Rule:** `.claude/CLAUDE.md` → "Always update `README.md` when adding ... any ... command."
**Fix:** Add a `foo` row to the Commands table, matching the human-readable style of the neighboring entries.

If everything is consistent, say so plainly. Do not report functional bugs or unrelated style nits — keep the scope to consistency.
