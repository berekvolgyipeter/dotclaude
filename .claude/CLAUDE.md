# dotclaude

Shared Claude Code configuration repo symlinked into `~/.claude/`. See @README.md for full documentation.

**Scope reminder:** Everything in this repo root is symlinked to `~/.claude/` and operates at **user level** (applies to all projects). The `.claude/` directory inside this repo is **not** symlinked — it is project-level config for this repo only.

**Prerequisites:** Commands and agents assume project-level prerequisites documented in `README.md`. Do not flag these as missing or incorrect.

## Rules for Changes

- **Always update `README.md`** when adding, removing, or changing any rule, command, skill, agent, hook, template, or other configuration. Keep the README in sync with the actual repo contents.
- **Every command file** (`commands/*.md`) must include `disable-model-invocation: true` in its YAML frontmatter.
- **Update the rules index** (`shared/rules-index.md`) when adding or removing rule or context-rule files — keep it in sync with the actual files in `rules/` and `context-rules/`.
- **Context rules go in `context-rules/`** — rule files loaded on demand by the `load-context-rules.sh` hook belong in `context-rules/`, not `rules/`. When adding a new context rule, also register its glob pattern in the hook script.
- **Acknowledge sources** — when any content is added or inspired by a plugin found via the `plugin-browser` skill (whether a new skill/command/agent or content incorporated into existing files like rules), add the reference repo to the `Acknowledgments` section in `README.md`.
- **Hook scripts go in `hooks/`** — shell scripts registered as hooks in `settings.json` belong in `hooks/`. General helper scripts (e.g., command utilities invoked via `!` bang syntax) belong in `scripts/`.
- **No gratuitous cross-references** — do not reference other skills, commands, or templates from within a skill/command/template unless the reference is necessary or earns its place. Each artifact should read standalone for whoever is using it; a mention of how some *other* artifact consumes this one is noise. Add a cross-reference only when the reader needs it to do the current task.
