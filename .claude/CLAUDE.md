# dotclaude

Shared Claude Code configuration repo symlinked into `~/.claude/`. See @README.md for full documentation.

## Critical: Repo Layout

Content directories (`rules/`, `commands/`, `agents/`, `skills/`, `templates/`, `hooks/`) live at the **repo root**, NOT inside `.claude/`. They symlink directly into `~/.claude/`. The `setup/` directory contains install/uninstall scripts and is not symlinked.

## Rules for Changes

- **No project-specific content.** Anything referencing a specific project's paths or tools belongs in that project's `.claude/`.
- **Path-filtered rules** (YAML frontmatter `paths:`) are fine for language-specific content (e.g. `**/*.py`).
- **Templates** must be referenced via absolute path: `~/.claude/templates/prp_template.md`.
- **`skills/skill-creator/`** is gitignored (large vendored skill — fetch separately).
- All projects use a `Makefile` — commands referencing `make lint` / `make test` are acceptable shared conventions.
- Edits here are live in all projects immediately (symlinks). No need to touch project repos for shared config.
- **Always update `README.md`** when adding, removing, or changing any rule, command, skill, agent, hook, template, or other configuration. Keep the README in sync with the actual repo contents.
