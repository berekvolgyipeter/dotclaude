# dotclaude Repo Setup Brief

## Goal

This project is a shared Claude Code configuration repo that is
symlinked into `~/.claude/` on each machine. Changes to this repo immediately affect all
projects. Each project still has its own `.claude/` folder for project-specific overrides,
which Claude Code merges with the user-level `~/.claude/` natively.

---

## How Claude Code Configuration Layers Work

Claude Code merges configuration from two levels automatically:

| Level | Location | Loaded for |
|-------|----------|------------|
| User-level | `~/.claude/rules/`, `skills/`, `agents/`, `commands/` | All projects |
| Project-level | `.claude/rules/`, `skills/`, `agents/`, `commands/` | This project only |

Array settings (e.g. `permissions.allow`) **concatenate** across levels. Project-level
takes precedence over user-level for same-named items.

The `dotclaude` repo is symlinked into `~/.claude/` — so it IS the user-level config.
Project repos contribute their own `.claude/` on top.

---

## Directory Structure

```
dotclaude/                        # repo root — mirrors ~/.claude/ contents
├── rules/
│   ├── general.md                # universal behavioral rules (no guessing, tool prefs)
│   └── python/
│       ├── code.md               # Python coding standards (path-filtered to *.py)
│       ├── debug.md              # debugging tools (path-filtered)
│       └── test.md               # testing conventions (path-filtered)
├── commands/
│   ├── review.md
│   ├── delta-review.md
│   ├── fix-review.md
│   ├── generate-prp.md
│   ├── execute-prp.md
│   ├── execute-parallel.md
│   ├── prep-parallel.md
│   └── primer.md
├── agents/
│   ├── documentation-manager.md
│   └── validation-gates.md
├── skills/
│   ├── claude-code/
│   ├── claude-agent-sdk/
│   ├── prompt-engineering/
│   ├── skill-creator/
│   ├── plugin-browser/
│   ├── slither/
│   └── learn/
├── templates/
│   └── prp_template.md
├── install.sh                    # symlinks this repo into ~/.claude/
├── uninstall.sh
├── .gitignore
└── README.md
```

Skills, commands, rules, agents, and templates live **at the repo root** (not inside a
`.claude/` subfolder) because they will be symlinked directly into `~/.claude/`.

---

## install.sh

Symlinks each directory from this repo into `~/.claude/`. Must be idempotent (safe to
re-run). Example logic:

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
DIRS=(rules commands agents skills templates)

mkdir -p "$CLAUDE_DIR"

for dir in "${DIRS[@]}"; do
    target="$CLAUDE_DIR/$dir"
    source="$REPO_DIR/$dir"

    if [ -L "$target" ]; then
        rm "$target"
    elif [ -d "$target" ]; then
        echo "WARNING: $target is a real directory, not a symlink. Skipping."
        echo "  Back it up and remove it manually, then re-run."
        continue
    fi

    ln -s "$source" "$target"
    echo "Linked: $target -> $source"
done

echo "Done."
```

---

## uninstall.sh

Removes only symlinks created by `install.sh` — does not touch real directories.

```bash
#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
DIRS=(rules commands agents skills templates)

for dir in "${DIRS[@]}"; do
    target="$CLAUDE_DIR/$dir"
    if [ -L "$target" ]; then
        rm "$target"
        echo "Removed symlink: $target"
    fi
done
```

---

## .gitignore

```gitignore
# OS
.DS_Store

# Python cache inside skill scripts
__pycache__/
*.pyc

# skill-creator is large/vendored — fetched separately
skills/skill-creator/
```

Each skill with fetched references has its own `.gitignore` (e.g.
`skills/claude-code/.gitignore` ignores `references/llms.txt`). Those travel with the
skill files.

## Project-Level Layer (what stays in each project's .claude/)

After `dotclaude` is installed, each project's `.claude/` should contain only
project-specific overrides:

```
project/.claude/
├── settings.json          # project permissions, allowed bash commands, MCP servers
├── settings.local.json    # personal (gitignored)
├── .gitignore
├── rules/                 # only project-specific rules (if any)
└── skills/                # only project-specific skills (if any)
```

`.gitignore` for each project's `.claude/`:
```gitignore
settings.local.json
.code-reviews/
.DS_Store
```

---

## Editing Workflow

Because `~/.claude/` directories are symlinks into this repo, editing any file in
`~/.claude/rules/`, `~/.claude/skills/`, etc. is editing the real file in `dotclaude/`.
Changes are immediately visible in all projects. Commit and push from this repo to
version-control the change.

No need to touch project repos when updating shared config.

---

## Key Rules / Conventions for This Repo

- **No project-specific content.** If a rule, command, or skill references a specific
  project's paths, structure, or tools — it belongs in the project's `.claude/`, not here.
- **Rules with path filters** (via YAML frontmatter `paths:` field) are fine for
  language-specific content (e.g. Python-only rules scoped to `**/*.py`).
- **Commands that reference `make lint` / `make test`** are acceptable as a shared
  convention — all projects this owner works on use a Makefile.
- **Templates** — commands that reference `templates/prp_template.md` should use the path
  `~/.claude/templates/prp_template.md` (absolute) rather than a relative path, since the
  template now lives at user level.
- **`skill-creator/`** is gitignored because it is a large vendored skill. Document in
  README how to fetch it (e.g. from wshobson/agents or similar).

---

## README Sections to Include

1. What this repo is and how it works
2. Prerequisites (Claude Code installed, `~/.claude/` exists or will be created)
3. Installation (`./install.sh`)
4. Uninstallation (`./uninstall.sh`)
5. Editing workflow (edit here, commit here — propagates to all projects automatically)
6. Project-level layer (what goes in project `.claude/` vs here)
7. How to fetch vendored skills (skill-creator, etc.)
8. Adding a new project (what the project's `.claude/` should look like after install)
