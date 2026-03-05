# dotclaude

Shared [Claude Code](https://docs.anthropic.com/en/docs/claude-code) configuration repo, symlinked into `~/.claude/`. Edit files here, commit here — changes propagate to all projects automatically.

Manage rules, skills, commands, agents, hooks, and templates in one place instead of duplicating them across every project.

> **Note:** This repo contains scripts that modify files on your system. Please review the contents before use.

## What's Included

### [Rules](rules/)

| File | Scope | Description |
|------|-------|-------------|
| [general.md](rules/general.md) | All files | No-guessing policy, tool preferences |
| [code.md](rules/code.md) | `*.py` | Python style, KISS/YAGNI, error handling, data models |
| [debug.md](rules/debug.md) | `*.py` | ipdb, memory-profiler, line-profiler, rich |
| [test.md](rules/test.md) | `tests/**/*.py` | pytest conventions, parametrize patterns, test organization |

### [Commands](commands/)

| Command | Description |
|---------|-------------|
| [/review](commands/review.md) | Full technical code review |
| [/delta-review](commands/delta-review.md) | Review uncommitted changes against latest commit |
| [/fix-review](commands/fix-review.md) | Fix issues found in a code review |
| [/generate-prp](commands/generate-prp.md) | Generate a Product Requirements Prompt |
| [/execute-prp](commands/execute-prp.md) | Implement a PRP |
| [/prep-parallel](commands/prep-parallel.md) | Set up worktrees for parallel Claude Code agents |
| [/execute-parallel](commands/execute-parallel.md) | Run parallel task execution |
| [/primer](commands/primer.md) | Prime context for a session |
| [/commit](commands/commit.md) | Stage all changes and commit with a suggested conventional commit message |

### [Skills](skills/)

| Skill | Description |
|-------|-------------|
| [claude-code](skills/claude-code/SKILL.md) | Claude Code configuration & troubleshooting |
| [claude-agent-sdk](skills/claude-agent-sdk/SKILL.md) | Agent SDK implementation patterns |
| [prompt-engineering](skills/prompt-engineering/SKILL.md) | Prompt crafting and optimization techniques |
| [learn](skills/learn/SKILL.md) | Self-improvement from conversation feedback |
| [plugin-browser](skills/plugin-browser/SKILL.md) | Browse community plugins from wshobson/agents |
| [slither](skills/slither/SKILL.md) | Slither static analysis for Solidity & Vyper |
| [skill-creator](skills/skill-creator/) | Create & benchmark skills (vendored, gitignored) |

### [Agents](agents/)

| Agent | Description |
|-------|-------------|
| [validation-gates](agents/validation-gates.md) | Runs tests and iterates on fixes until they pass |
| [documentation-manager](agents/documentation-manager.md) | Keeps docs in sync with code changes |

### Other

| Item | Description |
|------|-------------|
| [hooks/](hooks/) | Event-driven shell scripts (e.g. auto-approve `.claude/` writes) |
| [scripts/](scripts/) | Shared utility scripts (e.g. `index-codebase.sh` for claude-context indexing) |
| [templates/](templates/) | Starter files for new projects (`CLAUDE.md`, `mcp.json`, `serena.project.yml`) |
| [settings.json](settings.json) | Shared permissions & preferences |
| [statusline-command.sh](statusline-command.sh) | Custom status line script |

## How It Works

Claude Code merges configuration from two levels:

| Level | Location | Scope |
|-------|----------|-------|
| User-level | `~/.claude/` (this repo, via symlinks) | All projects |
| Project-level | `project/.claude/` | That project only |

Array settings (e.g. `permissions.allow`) concatenate across levels. Project-level wins for same-named items.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- A `Makefile` in each project with at least: `lint`, `test`, `tree` targets

### claude-context

[template.mcp.json](template.mcp.json) sets up the claude-context MCP server which needs:
- an `OPENAI_API_KEY` set in project root `.env`
- a locally running instance of Milvus vector db
    - check out [this repo](https://github.com/berekvolgyipeter/milvus) to run Milvus via Docker Compose

## Installation

```bash
make install
```

This runs `setup/install.sh`, which symlinks directories and files from this repo into `~/.claude/`:
- **Directories**: `rules/`, `commands/`, `agents/`, `skills/`, `templates/`, `hooks/`, `scripts/`
- **Files**: `settings.json`, `statusline-command.sh`

If a real (non-symlink) directory or file already exists at the target, the script warns and skips it. Existing files are backed up with a timestamp before being replaced. Safe to re-run.

## Uninstallation

```bash
make uninstall
```

Removes only symlinks created by `install.sh`. Real directories and files are left untouched. If a backup exists for a file, the most recent backup is restored.

## Fetching Vendored Skills

`skill-creator` is gitignored because it's a large vendored skill. To fetch it:

```bash
make fetch-skill-creator
```

Some skills require Python dependencies (`anthropic`, `pyyaml`, `requests`). Activate a virtual environment first:

```bash
python -m venv .venv && source .venv/bin/activate
make python-deps
```

## Editing Workflow

Because `~/.claude/` directories are symlinks into this repo, editing any file in `~/.claude/rules/`, `~/.claude/skills/`, etc. is editing the real file here. Changes are immediately visible in all projects.

Commit and push from this repo to version-control shared config. No need to touch project repos when updating shared configuration.

## Project-Level Layer

After installing dotclaude, each project's `.claude/` should only contain project-specific overrides:

```
project/.claude/
├── CLAUDE.md              # project-specific instructions
├── settings.json          # project permissions, MCP servers
├── settings.local.json    # personal overrides (gitignored)
├── .gitignore
├── rules/                 # project-specific rules only (if any)
└── skills/                # project-specific skills only (if any)
```

Use `template.CLAUDE.md`, `template.mcp.json`, and `template.serena.project.yml` from this repo as starters when setting up a new project.

## Conventions

- **No project-specific content here.** Rules, commands, or skills referencing a specific project's paths belong in that project's `.claude/`.
- **Path-filtered rules** (YAML frontmatter `paths:`) are fine for language-specific content (e.g. scoped to `**/*.py`).
- **Templates** should be referenced via absolute path: `~/.claude/templates/prp_template.md`.
- **`make lint` / `make test`** in shared commands are acceptable — all projects are assumed to use a Makefile.

## Acknowledgments

- [coleam00/context-engineering-intro](https://github.com/coleam00/context-engineering-intro) — inspiration for commands and rules
