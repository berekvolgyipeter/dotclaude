---
name: scaffold-rules
description: Analyze the codebase, decompose it into modules, and scaffold per-module rule files (`.claude/rules/*.md` with `paths` frontmatter) plus a progressive-disclosure table in CLAUDE.md
disable-model-invocation: true
model: opus
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(make *), Bash(ls *), AskUserQuestion
---

# Scaffold Per-Module Rule Files

Decompose this project into well-separable modules, write one rule file per module under `.claude/rules/` with a `paths` frontmatter, and add a progressive-disclosure table to the project's CLAUDE.md.

**Why this matters.** Claude Code natively supports path-scoped rule files in `.claude/rules/*.md`. A rule with a `paths` glob loads only when Claude reads a matching file, so curated architectural knowledge reaches the session exactly when it's relevant — without polluting every context. The CLAUDE.md table tells Claude to read the rule *before* scanning source, so it answers from design intent instead of re-deriving it.

Reference: https://code.claude.com/docs/en/memory.md#organize-rules-with-claude/rules/

This command writes to the **current project's** `.claude/rules/` and `.claude/CLAUDE.md`. It does not modify the user-level dotclaude repo.

## Stage 1 — Analyze

Explore this project to identify natural module boundaries. Minimize file reads — use directory listings and symbol overviews before reading full files.

@~/.claude/shared/analyze-project.md

Stop when you can name the module boundaries.

## Stage 2 — Decompose

Group source paths into **well-separable modules**. Apply these heuristics in order:

1. **Follow existing structure first.** Use the project's own layout as the skeleton — do not invent a new taxonomy.
2. **One module = one (or a few non-overlapping) globs.** If two candidates overlap, merge them or pick the more specific one.
3. **Coherent abstraction.** A module's files should share purpose, vocabulary, or dependency neighbourhood. If you need "and" to describe what it covers, split it.
4. **Layering is fine.** A narrower module (e.g. `src/utils/workspace/**`) can layer on a broader one (`src/utils/**`). Note the layering in the `Covers` line.
5. **Cap the count.** 5–12 modules is the sweet spot. More fragments the rule set; fewer defeats the purpose.
6. **Skip low-signal areas.** If a directory has no non-obvious architectural content worth documenting (e.g. three one-off scripts), do not create a rule for it.

## Stage 3 — Confirm with the user

Present the proposed decomposition as a table **before writing any files**:

| Rule file | Paths | Covers (one line) |
|---|---|---|
| `agents.md` | `src/agents/**` | Agent architecture, retry strategy, orchestrator vs prompted agent separation |
| … | … | … |

Use `AskUserQuestion` to confirm. Offer options like "approve as-is", "revise the list", or "adjust a specific rule". Do not proceed to Stage 4 until the user approves.

## Stage 4 — Write the rule files

For each approved module, write `.claude/rules/<name>.md` with this shape:

```markdown
---
paths:
  - "<glob>"
---

# <Module Title>

<One-paragraph module charter: what this code does, its single responsibility, and why it exists as its own module.>

## Design intent

- <principle or constraint, with a one-clause rationale when non-obvious>

## Patterns

- <concrete pattern a reader should follow>

## Conventions

- <naming / file-layout / error-handling rule specific to this module>

## Gotchas

- <non-obvious thing that has bitten someone here>
```

### Rules for writing each rule file

- **Architectural, not implementation-level.** Describe intent, patterns, constraints — not function signatures that will rot.
- **Concrete and verifiable.** "Retry transient errors with exponential backoff in `BaseAgent.run`" beats "be resilient".
- **Explain *why* for non-obvious rules.** A one-clause rationale outperforms a shouted command. Skip the rationale when self-evident.
- **No volatile details.** No model names, version strings, file counts, or commit-sensitive numbers. Those rot.
- **No code dumps.** One small generic example per pattern is fine; full snippets belong in the source.
- **Keep each file short enough to absorb in one read.** If a module is rich enough to need more, split it into layered rules (broader + narrower paths) rather than growing one file.
- **Match the project's voice.** If the project's other docs are terse, be terse. If they use tables, use tables.

Use the `Write` tool — it creates parent directories automatically.

## Stage 5 — Update CLAUDE.md

Add (or replace) a `## Rule Files — Progressive Disclosure` section in `.claude/CLAUDE.md`. Populate this exact template from the approved table:

```markdown
## Rule Files — Progressive Disclosure

Rules in `.claude/rules/` contain curated architectural knowledge: design intent, patterns, constraints, and conventions.

**Before answering questions, researching, or modifying code in any area below:** read the relevant rule file(s) FIRST. They explain the "why" and "how" without needing to scan source files. Only dive into source code for details the rules don't cover.

| Rule file | Triggers on | Covers |
|---|---|---|
| `<name>.md` | `<glob>` | <one-line summary> |
```

If a section with that exact heading already exists, replace it in place (do not duplicate). Use `Edit` for the replacement; do not rewrite unrelated parts of CLAUDE.md.

## Stage 6 — Verify

Before declaring done:

- [ ] One rule file per approved module; each has a `paths` frontmatter with at least one glob.
- [ ] No two rule files claim an identical glob (layering is fine; duplication is not).
- [ ] CLAUDE.md table matches the rule files on disk exactly (same filenames, same globs).
- [ ] No rule file contains content that will obviously rot (version strings, model names, magic counts).

Report a short summary: N rule files written with their paths, and any modules deliberately deferred with a one-line rationale.
