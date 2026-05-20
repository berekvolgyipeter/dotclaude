---
name: init-rules
description: Decompose a fresh project into modules and write per-module `.claude/rules/*.md` files with `paths` frontmatter, plus a progressive-disclosure table in CLAUDE.md
disable-model-invocation: true
model: opus
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(make *), Bash(ls *), AskUserQuestion
---

# Initialize Per-Module Rule Files

Decompose this project into well-separable modules, write one rule file per module under `.claude/rules/` with a `paths` frontmatter, and add a progressive-disclosure table to the project's CLAUDE.md.

**Why this matters.** Claude Code natively supports path-scoped rule files in `.claude/rules/*.md`. A rule with a `paths` glob loads only when Claude reads a matching file, so curated architectural knowledge reaches the session exactly when it's relevant — without polluting every context. The CLAUDE.md table tells Claude to read the rule *before* scanning source, so it answers from design intent instead of re-deriving it.

**These files are prompts, not docs.** Each rule is read by Claude Code, and once loaded its contents stay in context for the rest of the session. Every line is a recurring token cost on every following turn. Treat each rule file with the discipline of a system prompt: ruthlessly concise, architectural, and free of anything a future reader could derive from the source.

**Mode check.** This command assumes no rule files exist yet. If `Glob` on `.claude/rules/*.md` returns any files, stop and tell the user to run `/refine-rules` instead.

Reference: https://code.claude.com/docs/en/memory.md#organize-rules-with-claude/rules/

## Stage 1 — Analyze

Explore this project to identify natural module boundaries. Minimize file reads — use directory listings and symbol overviews before reading full files.

@~/.claude/shared/analyze-project.md

Stop when you can name the module boundaries.

## Stage 2 — Decompose

Group source paths into **cohesive modules**. Apply these heuristics in order:

1. **Follow existing structure first.** Use the project's own layout as the skeleton — do not invent a new taxonomy.
2. **One module = one (or a few non-overlapping) globs.** If two candidates substantially overlap without one being a clean subset of the other, merge them. Clean subset relationships are handled by rule 4 (layering).
3. **Coherent abstraction.** A module's files should share purpose, vocabulary, or dependency neighbourhood. If you need "and" to describe what it covers, split it.
4. **Layering is fine.** A narrower glob can layer on a broader one (e.g. a subdirectory rule on top of its parent directory rule). Note the layering in the `Covers` line.
5. **Cap the count.** 5–12 modules is the sweet spot. More fragments the rule set; fewer defeats the purpose.
6. **Skip low-signal areas.** If a directory has no non-obvious architectural content worth documenting (e.g. three one-off scripts), do not create a rule for it.

## Stage 3 — Confirm with the user

Present the proposed decomposition as a table **before writing any files**:

| Rule file | Paths | Covers (one line) |
|---|---|---|
| `<module>.md` | `<path-glob>` | <design intent, key patterns, and constraints for this module> |
| `<broad-module>.md` | `<dir>/**` | <module-wide intent> |
| `<narrow-module>.md` | `<dir>/<subdir>/**` | <layers on `<broad-module>.md`; covers <subdir-specific intent>> |
| … | … | … |

Use `AskUserQuestion` to confirm. Offer options like "approve as-is", "revise — I'll send comments", or "start over". Do not proceed to Stage 4 until the user approves.

## Stage 4 — Write the rule files

@~/.claude/shared/project-rules/file-writing.md

For each approved module, write `.claude/rules/<name>.md` following the shape and writing rules in the included file.

## Stage 5 — Update CLAUDE.md

Apply the procedure below to the project's `.claude/CLAUDE.md`. Compress each `Covers` cell from Stage 3 to a one-line summary for the final table.

@~/.claude/shared/project-rules/claudemd-section.md

## Stage 6 — Verify

Before declaring done:

- [ ] One rule file per approved module; each has a `paths` frontmatter with at least one glob.
- [ ] No two rule files claim an identical glob (layering is fine; duplication is not).
- [ ] CLAUDE.md table matches the rule files on disk exactly (same filenames, same globs).
- [ ] No rule file contains content that will obviously rot (version strings, model names, magic counts).
- [ ] Every rule file satisfies the writing rules in `~/.claude/shared/project-rules/file-writing.md` — architectural, concise, no over-constraining, short enough to absorb in one read.

Report a short summary: N rule files written with their paths.
