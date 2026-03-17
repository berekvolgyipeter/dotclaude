# dotclaude

Shared [Claude Code](https://docs.anthropic.com/en/docs/claude-code) configuration repo, symlinked into `~/.claude/`. Edit files here, commit here — changes propagate to all projects automatically.

Manage rules, skills, commands, agents, hooks, and templates in one place instead of duplicating them across every project.

> **Note:** This repo contains scripts that modify files on your system. Please review the contents before use.
>
> **Platform:** Only tested and developed on macOS. Linux may work but is untested; Windows is not supported.

## What's Included

### [Rules](rules/)

| File | Scope | Description |
|------|-------|-------------|
| [general.md](rules/general.md) | All files | No-guessing policy, tool preferences |
| [py-code.md](rules/py-code.md) | Python files | Python style, KISS/YAGNI, error handling, data models |
| [py-test.md](rules/py-test.md) | Python test files | pytest conventions, parametrize patterns, test organization |
| [docs.md](rules/docs.md) | Markdown files | Documentation principles, timeless writing, avoid volatile details |

### [Shared](shared/)

Reference files explicitly read by commands and skills — not auto-loaded.

| File | Description |
|------|-------------|
| [shared/rules-index.md](shared/rules-index.md) | Registry of all rule files — what each covers and when to load it |
| [shared/code-review.md](shared/code-review.md) | Subagent-based review orchestration protocol with parallel batch analysis |

### [Commands](commands/)

| Command | Description |
|---------|-------------|
| [/pr-review](commands/review/pr-review.md) | Full technical code review |
| [/delta-review](commands/review/delta-review.md) | Review uncommitted changes against latest commit |
| [/pr-summary](commands/review/pr-summary.md) | Brief PR summary grouped by feature/area |
| [/fix-review](commands/review/fix-review.md) | Fix issues found in a code review |
| [/generate-prp](commands/prp/generate-prp.md) | Generate a Product Requirements Prompt |
| [/execute-prp](commands/prp/execute-prp.md) | Implement a PRP |
| [/prep-parallel](commands/parallel/prep-parallel.md) | Set up worktrees for parallel Claude Code agents |
| [/execute-parallel](commands/parallel/execute-parallel.md) | Run parallel task execution |
| [/primer](commands/primer.md) | Prime context for a session |
| [/commit](commands/commit.md) | Stage all changes, commit, and push with a suggested conventional commit message |

### [Skills](skills/)

| Skill | Description |
|-------|-------------|
| [claude-code](skills/claude-code/SKILL.md) | Claude Code configuration & troubleshooting |
| [claude-agent-sdk](skills/claude-agent-sdk/SKILL.md) | Agent SDK implementation patterns |
| [prompt-engineering](skills/prompt-engineering/SKILL.md) | Prompt crafting and optimization techniques |
| [learn](skills/learn/SKILL.md) | Self-improvement from conversation feedback |
| [plugin-browser](skills/plugin-browser/SKILL.md) | Browse, discover, and explore skills/agents/plugins from multiple indexed community and official repos |
| [slither](skills/slither/SKILL.md) | Slither static analysis for Solidity & Vyper |
| [py-debug](skills/py-debug/SKILL.md) | Python debugging |
| [skill-creator](skills/skill-creator/) | Create & benchmark skills (vendored, gitignored) |

### [Agents](agents/)

| Agent | Description |
|-------|-------------|
| [validation-gates](agents/validation-gates.md) | Runs tests and iterates on fixes until they pass |
| [documentation-manager](agents/documentation-manager.md) | Keeps docs in sync with code changes |
| [code-reviewer](agents/review/code-reviewer.md) | Focused code reviewer for batches of changed files, dispatched by review commands |
| [diff-summarizer](agents/review/diff-summarizer.md) | Reads diffs on demand and returns structured change summaries |

### [Hooks](hooks/)

Event-driven shell scripts registered in `settings.json`.

| Hook | Event | Description |
|------|-------|-------------|
| [auto-approve-claude-dir.sh](hooks/auto-approve-claude-dir.sh) | `PreToolUse` | Auto-approves safe Bash, Write, Read, Grep, and Glob operations on `.claude/` paths that Claude Code would otherwise block due to command-injection detection |
| [log-instructions-loaded.sh](hooks/log-instructions-loaded.sh) | `InstructionsLoaded` | Logs each instruction file load to `.claude/.logs/instructions-loaded.log`. Disabled by default (`LOG_INSTRUCTIONS_LOADED_ENABLED=0` in `settings.json`); set to `1` to enable |

### [Templates](templates/)

| File | Description |
|------|-------------|
| [prp_template.md](templates/prp_template.md) | PRP template used by the `/generate-prp` command |

### [Scripts](scripts/)

| File | Description |
|------|-------------|
| [statusline-command.sh](scripts/statusline-command.sh) | Custom status line script |
| [index_codebase.py](scripts/index_codebase.py) | Indexes codebase for the claude-context MCP server |
| [delta-diff.sh](scripts/review/delta-diff.sh) | Injects a local change overview (stats, file list) as markdown context — diffs are read on demand by subagents |
| [pr-diff.sh](scripts/review/pr-diff.sh) | Injects a branch change overview (stats, file list, commits) as markdown context — diffs are read on demand by subagents |
| [latest-review.sh](scripts/review/latest-review.sh) | Outputs the path to the newest code review file in `.claude/.code-reviews/` |

### [settings.json](settings.json)

Shared permissions, preferences, and security posture.

**Privacy:** Three env flags disable telemetry, error reporting, and the feedback survey — Claude doesn't phone home by default. Override per-project if needed.

**Deny list — no exceptions, no approval prompts:**
- *Destructive commands:* `rm -rf`, `sudo`, `mkfs`, `dd`, `wget ... | bash` (classic supply-chain attack vector)
- *Irreversible git:* force-push and `git reset --hard`
- *Shell config:* `~/.bashrc`, `~/.zshrc` — PATH manipulation and alias injection are off the table
- *Credential stores:* SSH keys, AWS/Azure/GitHub CLI configs, git-credentials, Docker, Kubernetes, npm/pypi/gem tokens, macOS Keychain, `.env` files — and crypto wallet data (MetaMask, Electrum, Exodus, Phantom, Solflare)

**Hooks as a second layer:** `block-rm-rf.sh` and `block-push-to-main.sh` fire on every `Bash` call as a `PreToolUse` hook, independent of the permission system. If a permission rule is misconfigured, the hook still blocks it.

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

The claude-context MCP server (configured in `.mcp.json`) needs:
- an `OPENAI_API_KEY` set in project root `.env`
- a locally running instance of Milvus vector db
    - check out [this repo](https://github.com/berekvolgyipeter/milvus) to run Milvus via Docker Compose

## Installation

```bash
make install
```

This runs `setup/install.sh`, which symlinks directories and files from this repo into `~/.claude/`:
- **Directories**: `rules/`, `commands/`, `agents/`, `skills/`, `templates/`, `hooks/`, `scripts/`, `shared/`
- **Files**: `settings.json`

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

Some skills require Python dependencies:

```bash
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

- [coleam00/context-engineering-intro](https://github.com/coleam00/context-engineering-intro) — inspiration for some commands and rules
- [trailofbits/claude-code-config](https://github.com/trailofbits/claude-code-config) — security and privacy focused settings
- [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) — naming conventions and code review patterns
- [wshobson/agents](https://github.com/wshobson/agents) — Python style and naming patterns
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) — multi-agent code review pattern
