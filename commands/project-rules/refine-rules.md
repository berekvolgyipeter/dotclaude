---
name: refine-rules
description: Audit existing `.claude/rules/*.md` files and apply a minimal delta — modify, split, merge, remove, or add — keeping the CLAUDE.md progressive-disclosure table in sync
disable-model-invocation: true
model: opus
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(make *), Bash(ls *), Bash(rm *), AskUserQuestion
---

# Refine Per-Module Rule Files

Audit the existing `.claude/rules/*.md` files, propose a **minimal delta** against them, and apply the approved changes — keeping the progressive-disclosure table in `.claude/CLAUDE.md` in sync.

**Why this matters.** Claude Code natively supports path-scoped rule files in `.claude/rules/*.md`. A rule with a `paths` glob loads only when Claude reads a matching file, so curated architectural knowledge reaches the session exactly when it's relevant — without polluting every context. The CLAUDE.md table tells Claude to read the rule *before* scanning source, so it answers from design intent instead of re-deriving it.

**These files are prompts, not docs.** Each rule is read by Claude Code, and once loaded its contents stay in context for the rest of the session. Every line is a recurring token cost on every following turn. Treat each rule file with the discipline of a system prompt: ruthlessly concise, architectural, and free of anything a future reader could derive from the source.

**Mode check.** This command assumes existing rule files. If `.claude/rules/` doesn't exist or `Glob` on `.claude/rules/*.md` returns nothing, stop and tell the user to run `/init-rules` instead.

Reference: https://code.claude.com/docs/en/memory.md#organize-rules-with-claude/rules/

## Stage 0 — Read existing rules

`Glob` `.claude/rules/*.md` and read every file. Also read the current `## Rule Files — Progressive Disclosure` section in `.claude/CLAUDE.md` (if present) to see how the existing rules are advertised. The goal is a **minimal delta**, not a rewrite: keep curated content unless it is stale, wrong, or violates the writing rules.

## Stage 1 — Analyze (lightly)

Lean on the existing rule files as the project map — they already encode the modules. Re-explore only where the rules are silent, look stale, or the directory layout has obviously changed. Pick steps from `~/.claude/shared/analyze-project.md` à la carte (e.g. `make tree` if the layout may have shifted, a fresh read of CLAUDE.md if conventions may have changed) — skip anything the existing rules already cover.

Stop when you can decide what's drifted and what's new.

## Writing rules

@~/.claude/shared/project-rules/file-writing.md

## Stage 2 — Classify

For each existing rule, classify it as:

- **keep** — content is correct, paths still match, writing rules satisfied.
- **modify** — paths drifted, `paths` frontmatter missing, content stale, scope unclear, file has grown too long or too detailed, or it violates any of the writing rules above.
- **split** — covers two distinct concerns, or has grown past one-read length and naturally layers.
- **merge** — overlaps another rule.
- **remove** — paths no longer exist or area is now low-signal.

Then check whether any new module has emerged since the rules were last written and propose **add**s for it.

The decomposition heuristics that govern adds, splits, and merges:

1. **Follow existing structure.** Use the project's layout as the skeleton.
2. **One module = one (or a few non-overlapping) globs.** If two candidates overlap, merge or narrow.
3. **Coherent abstraction.** A module's files should share purpose, vocabulary, or dependency neighbourhood. "And" in the description is a smell.
4. **Layering is fine.** A narrower glob can layer on a broader one.
5. **Cap the count.** 5–12 modules.
6. **Skip low-signal areas.**

## Stage 3 — Confirm the delta

Present the proposal as a delta table with an explicit `Action` column and a one-line `Why` for every non-`keep` row:

| Action | Rule file | Paths | Covers | Why |
|---|---|---|---|---|
| keep / add / modify / split / merge / remove | `<name>.md` | `<glob>` | <one line> | <rationale> |

Use `AskUserQuestion` to confirm. Offer terminal options like "approve as-is", "revise — I'll send comments", or "start over". Wait for explicit user approval before applying any actions in Stage 4.

## Stage 4 — Apply the delta

Apply the approved actions:

- **keep** — leave the file untouched.
- **add** — `Write` a new rule file following the shape and writing rules above.
- **modify** — use `Edit` for targeted changes; preserve curated wording. Only `Write` (full rewrite) if the file is largely wrong.
- **split** — `Write` the new narrower rule(s), then `Edit` the original to narrow its scope (or delete it if fully replaced).
- **merge** — fold content into the surviving rule via `Edit`, then delete the absorbed file with `Bash(rm <path>)`.
- **remove** — delete the file with `Bash(rm <path>)`.

## Stage 5 — Update CLAUDE.md

@~/.claude/shared/project-rules/claudemd-section.md

## Stage 6 — Verify

Before declaring done:

- [ ] Each remaining rule file has a `paths` frontmatter with at least one glob.
- [ ] No two rule files claim an identical glob (layering is fine; duplication is not).
- [ ] CLAUDE.md table matches the rule files on disk exactly (same filenames, same globs).
- [ ] No rule file contains content that will obviously rot (version strings, model names, magic counts).
- [ ] Every rule file satisfies the writing rules in `~/.claude/shared/project-rules/file-writing.md` — architectural, concise, no over-constraining, short enough to absorb in one read.
- [ ] Every approved `remove`/`merge` source file is gone from disk and from the CLAUDE.md table.

Report a short summary: counts of added / modified / split / merged / removed rules, plus any modules deliberately deferred with a one-line rationale.
