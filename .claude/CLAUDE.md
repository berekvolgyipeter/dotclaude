# dotclaude

Shared Claude Code configuration repo symlinked into `~/.claude/`. See @README.md for full documentation.

**Scope reminder:** Everything in this repo root is symlinked to `~/.claude/` and operates at **user level** (applies to all projects). The `.claude/` directory inside this repo is **not** symlinked — it is project-level config for this repo only.

**Prerequisites:** Commands and agents assume project-level prerequisites documented in `README.md`. Do not flag these as missing or incorrect.

## Rules for Changes

- **Always update `README.md`** when adding, removing, or changing any rule, command, skill, agent, hook, template, or other configuration. Keep the README in sync with the actual repo contents.
- **Don't document project-level `.claude/` files in `README.md`** — the README catalogs only the user-level artifacts symlinked from the repo root. Files under this repo's own `.claude/` directory (e.g. `.claude/commands/`, `.claude/settings.json`) are project-level config for this repo only and must not be added to the README tables.
- **Every command file** (`commands/*.md`) must include `disable-model-invocation: true` in its YAML frontmatter.
- **Update the rules index** (`shared/rules-index.md`) when adding or removing rule or context-rule files — keep it in sync with the actual files in `rules/` and `context-rules/`.
- **Context rules go in `context-rules/`** — rule files loaded on demand by the `load-context-rules.sh` hook belong in `context-rules/`, not `rules/`. When adding a new context rule, also register its glob pattern in the hook script.
- **Acknowledge sources** — when any content is added or inspired by a plugin found via the `plugin-browser` skill (whether a new skill/command/agent or content incorporated into existing files like rules), add the reference repo to the `Acknowledgments` section in `README.md`.
- **Hook scripts go in `hooks/`** — shell scripts registered as hooks in `settings.json` belong in `hooks/`. General helper scripts (e.g., command utilities invoked via `!` bang syntax) belong in `scripts/`.
- **No cross-references irrelevant to the usage context** — name another artifact, or the mechanism behind a rule, only when the reader acts on it: reads it, applies its vocabulary, invokes it, sets the flag, or reacts to the value. A source the reader genuinely draws on earns its place (e.g. linking the skill whose vocabulary they must use). Everything else is noise the reader never acts on — how some *other* artifact consumes this one, which command produced a file they only need to edit, *why* a section is absent when "absent → treat as not run" is all they need, or that a hook enforces a rule as a "backstop" when the rule itself is the whole instruction. The reader obeys the rule, not the mechanism enforcing it. The test is relevance to the usage context, not whether a cross-reference exists.

## Engineering Philosophy

The engineering skills (`tdd`, `improve-codebase-architecture`, `grill-with-docs`) are the source of truth for how this repo thinks about building software. The `commands/plan/` commands (`generate-plan`, `to-plan`, `refine-plan`, `execute-plan`) are a downstream pipeline built directly on top of them: research → deep-module design → domain-grounded refinement → test-first execution. The whole engineering domain rests on four tenets:

- **Deep modules.** Prefer modules whose interface is small relative to the functionality they hide (high *leverage*), so complexity is concentrated in one place (*locality*). Reason about architecture with the exact vocabulary in [`improve-codebase-architecture`](../skills/improve-codebase-architecture/SKILL.md): *module, interface, implementation, depth, seam, adapter, leverage, locality* — not "component," "service," or "boundary." Apply the **deletion test** to judge whether a module earns its keep.
- **Behavior-first testing.** Tests verify behavior through public interfaces, never implementation details — *the interface is the test surface*, so a good test survives any internal refactor. Build in **vertical slices** via the `tdd` red-green-refactor loop (one test → one implementation → repeat), never all-tests-then-all-code.
- **Domain-grounded.** Use the project's canonical vocabulary from `CONTEXT.md` (or the per-context files a root `CONTEXT-MAP.md` points to) and respect the decisions recorded in `docs/adr/`. Sharpen fuzzy terms into the glossary as they crystallize; don't silently re-litigate an ADR.
- **Evidence over speculation.** Explore the codebase and research docs before designing; ground every plan in real prior-art patterns and tests rather than inventing new ones.

**When editing or adding any rule, skill, or command in this engineering domain, stay consistent with these tenets and with the existing artifacts** — reuse the established vocabulary exactly, keep tests behavior-focused, preserve the deep-module framing, and keep the `plan/` pipeline aligned with the skills it builds on. A change to one engineering artifact must not drift from the language or principles of the others.
