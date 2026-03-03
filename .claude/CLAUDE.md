# dotclaude — Global Claude Code Configuration Repo

This repo is symlinked into `~/.claude/` via `./install.sh`. Editing files here immediately affects all projects on this machine. It IS the user-level config layer.

## Repo Structure

```
dotclaude/              # mirrors ~/.claude/ contents (not inside .claude/)
├── rules/              # universal + language-specific rules (path-filtered)
├── commands/           # slash commands available in all projects
├── agents/             # reusable subagent definitions
├── skills/             # packaged skills (claude-code, learn, etc.)
├── templates/          # PRP and other templates
├── install.sh          # symlinks repo dirs into ~/.claude/
└── uninstall.sh        # removes only symlinks, never real dirs
```

Skills, commands, rules, agents, and templates live at the **repo root** (not inside `.claude/`), because they symlink directly into `~/.claude/`.

## Key Conventions

- **No project-specific content here.** Anything referencing a specific project's paths or tools belongs in that project's `.claude/`.
- **Path-filtered rules** (YAML frontmatter `paths:`) are fine for language-specific content (e.g. `**/*.py`).
- **Templates** — reference as `~/.claude/templates/prp_template.md` (absolute path).
- **`skills/skill-creator/`** is gitignored (large vendored skill — fetch separately).
- All projects use a `Makefile` — commands referencing `make lint` / `make test` are acceptable shared conventions.

## How Configuration Layers Work

| Level | Location | Scope |
|-------|----------|-------|
| User-level | `~/.claude/` (this repo) | All projects |
| Project-level | `project/.claude/` | That project only |

Array settings (e.g. `permissions.allow`) concatenate across levels. Project-level wins for same-named items.

## Editing Workflow

Edit files in this repo → changes are live in all projects immediately (symlinks). Commit and push from here to version-control.
