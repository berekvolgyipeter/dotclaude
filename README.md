# dotclaude

Shared [Claude Code](https://docs.anthropic.com/en/docs/claude-code) configuration repo, symlinked into `~/.claude/`. Edit files here, commit here — changes propagate to all projects automatically.

Manage rules, skills, commands, agents, hooks, and templates in one place instead of duplicating them across every project.

> **Note:** This repo contains scripts that modify files on your system. Please review the contents before use.
>
> **Platform:** Only tested and developed on macOS. Linux may work but is untested; Windows is not supported.

## What's Included

### [Rules](rules/)

Always-loaded rule files discovered automatically by Claude Code.

| File | Scope | Description |
|------|-------|-------------|
| [general.md](rules/general.md) | All files | No-guessing policy, tool preferences |

### [Context Rules](context-rules/)

Rule files loaded on demand by the `load-context-rules.sh` hook when Edit/Write targets a matching file pattern. Not auto-discovered by Claude Code — the hook controls when they enter context.

| File | Loaded when | Description |
|------|-------------|-------------|
| [py-code.md](context-rules/py-code.md) | Python files | Python style, KISS/YAGNI, error handling, data models |
| [py-test.md](context-rules/py-test.md) | Python test files | pytest conventions, parametrize patterns, test organization |
| [docs.md](context-rules/docs.md) | Markdown files | Documentation principles, timeless writing, avoid volatile details |

### [Shared](shared/)

Reference files explicitly read by commands and skills — not auto-loaded.

| File | Description |
|------|-------------|
| [shared/rules-index.md](shared/rules-index.md) | Registry of all rule files — what each covers and when to load it |
| [shared/code-review.md](shared/code-review.md) | Subagent-based review orchestration protocol with parallel batch analysis |

### [Commands](commands/)

| Command | Description |
|---------|-------------|
| [/primer](commands/primer.md) | Prime context for a session |
| [/commit](commands/commit.md) | Stage all changes and commit with a suggested conventional commit message |

**[review/](commands/review/)**

| Command | Description |
|---------|-------------|
| [/pr-review](commands/review/pr-review.md) | Full technical code review |
| [/delta-review](commands/review/delta-review.md) | Review uncommitted changes against latest commit |
| [/pr-summary](commands/review/pr-summary.md) | Brief PR summary grouped by feature/area |
| [/fix-review](commands/review/fix-review.md) | Fix issues found in a code review |
| [/skill-review](commands/review/skill-review.md) | Review a skill or command file for best practices — structure, writing style, progressive disclosure, and prompt engineering |

**[prp/](commands/prp/)**

| Command | Description |
|---------|-------------|
| [/generate-prp](commands/prp/generate-prp.md) | Generate a Product Requirements Prompt |
| [/execute-prp](commands/prp/execute-prp.md) | Execute a PRP — internalize, plan, implement, validate, and verify |
| [/refine-prp](commands/prp/refine-prp.md) | Refine a PRP in place — check logical correctness and rule compliance, then edit the PRP to fix issues |

**[parallel/](commands/parallel/)**

| Command | Description |
|---------|-------------|
| [/prep-parallel](commands/parallel/prep-parallel.md) | Set up worktrees for parallel Claude Code agents |
| [/execute-parallel](commands/parallel/execute-parallel.md) | Run parallel task execution |

### [Skills](skills/)

| Skill | Description |
|-------|-------------|
| [claude-code](skills/claude-code/SKILL.md) | Claude Code configuration & troubleshooting |
| [claude-agent-sdk](skills/claude-agent-sdk/SKILL.md) | Agent SDK implementation patterns |
| [prompt-engineering](skills/prompt-engineering/SKILL.md) | Prompt crafting and optimization techniques |
| [learn](skills/learn/SKILL.md) | Self-improvement from conversation feedback |
| [plugin-browser](skills/plugin-browser/SKILL.md) | Browse, discover, and explore skills/agents/plugins from multiple indexed community and official repos |
| [agent-harness](skills/agent-harness/SKILL.md) | Browse and explore agent harness frameworks and Claude Code resource collections (Archon, everything-claude-code) |
| [slither](skills/slither/SKILL.md) | Slither static analysis for Solidity & Vyper |
| [py-debug](skills/py-debug/SKILL.md) | Python debugging |
| [skill-creator](skills/skill-creator/) | Create & benchmark skills (vendored, gitignored) |

### [Agents](agents/)

| Agent | Description |
|-------|-------------|
| [validation-gates](agents/validation-gates.md) | Runs tests and iterates on fixes until they pass |
| [documentation-manager](agents/documentation-manager.md) | Keeps docs in sync with code changes |

**[review/](agents/review/)**

| Agent | Description |
|-------|-------------|
| [code-reviewer](agents/review/code-reviewer.md) | Focused code reviewer for batches of changed files, dispatched by review commands |
| [diff-summarizer](agents/review/diff-summarizer.md) | Reads diffs on demand and returns structured change summaries |

### [Hooks](hooks/)

Event-driven shell scripts registered in `settings.json`.

| Hook | Event | Description |
|------|-------|-------------|
| [auto-approve-claude-dir.sh](hooks/auto-approve-claude-dir.sh) | `PreToolUse` | Auto-approves Read, Grep, and Glob operations on `.claude/` paths |
| [load-context-rules.sh](hooks/load-context-rules.sh) | `PreToolUse` | Loads context rules from `context-rules/` on first Edit/Write per session when the target file matches a rule's glob pattern. Deduplicates via transcript markers |
| [stop-lint-and-test.sh](hooks/stop-lint-and-test.sh) | `Stop` | Runs `make lint` and `make test` after any session that used Edit or Write tools on non-gitignored files. Exits with code 2 to block and prompt Claude to fix failures; skips gracefully when no Makefile or `make` is found; skips individual `lint`/`test` targets that are not defined |
| [block-rm-rf.sh](hooks/block-rm-rf.sh) | `PreToolUse` | Blocks destructive `rm -rf` and `rm -fr` Bash commands |
| [block-push-to-main.sh](hooks/block-push-to-main.sh) | `PreToolUse` | Blocks direct `git push` to the `main` branch |

### [Templates](templates/)

| File | Description |
|------|-------------|
| [prp_template.md](templates/prp_template.md) | Language-agnostic PRP template used by the `/generate-prp` command |

### [Scripts](scripts/)

| File | Description |
|------|-------------|
| [statusline-command.sh](scripts/statusline-command.sh) | Custom status line script |
| [index_codebase.py](scripts/index_codebase.py) | Indexes codebase for the claude-context MCP server |

**[review/](scripts/review/)**

| File | Description |
|------|-------------|
| [delta-diff.sh](scripts/review/delta-diff.sh) | Injects a local change overview (stats, file list) as markdown context — diffs are read on demand by subagents |
| [pr-diff.sh](scripts/review/pr-diff.sh) | Injects a branch change overview (stats, file list, commits) as markdown context — diffs are read on demand by subagents |
| [latest-review.sh](scripts/review/latest-review.sh) | Outputs the path to the newest code review file in `.claude/.code-reviews/` |

### [settings.json](settings.json)

Shared permissions, preferences, and security posture.

**Privacy:** Three env flags disable telemetry, error reporting, and the feedback survey — Claude doesn't phone home by default. Override per-project if needed.

**Deny list:**
- *Destructive commands:* `rm -rf`, `sudo`, `mkfs`, `dd`, `wget ... | bash` (classic supply-chain attack vector)
- *Irreversible git:* force-push and `git reset --hard`
- *Shell config:* `~/.bashrc`, `~/.zshrc` — PATH manipulation and alias injection are off the table
- *Credential stores:* SSH keys, AWS/Azure/GitHub CLI configs, git-credentials, Docker, Kubernetes, npm/pypi/gem tokens, macOS Keychain, `.env` files — and crypto wallet data (MetaMask, Electrum, Exodus, Phantom, Solflare)

**Ask list** (allowed but requires confirmation):
- *Root-equivalent access:* `docker`, `curl --unix-socket`, `socat *UNIX*`, `nc -U`, `ncat --unixsock` — the Docker socket and arbitrary Unix sockets grant host-level control
- *Permission/ownership:* `chmod`, `chown`
- *Network/data transfer:* `ssh`, `scp`, `rsync` — outbound sessions and file exfiltration vectors
- *Git remotes:* `git push`, `git remote` — pushing code or changing remote URLs
- *Process control:* `pkill`, `kill`, `launchctl` — killing processes or managing macOS services

**Hooks:** `block-rm-rf.sh` and `block-push-to-main.sh` fire on every `Bash` call as a `PreToolUse` hook, independent of the permission system. If a permission rule is misconfigured, the hook still blocks it.

**Sandboxing:** OS-level filesystem and network isolation for all bash commands and their subprocesses. Bash commands within sandbox boundaries are auto-approved — reducing prompt fatigue while maintaining security. The escape hatch is disabled; commands must run sandboxed or be explicitly excluded. Deny permission rules and sandbox isolation complement each other for defense in depth.

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
- **Directories**: `rules/`, `context-rules/`, `commands/`, `agents/`, `skills/`, `templates/`, `hooks/`, `scripts/`, `shared/`
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
- **Context rules** (`context-rules/`) are loaded by the `load-context-rules.sh` hook on Edit/Write — not auto-discovered. Add new context rules there and register their patterns in the hook script.
- **Templates** should be referenced via absolute path: `~/.claude/templates/prp_template.md`.
- **`make lint` / `make test`** in shared commands are acceptable — all projects are assumed to use a Makefile.

## Acknowledgments

- [coleam00/context-engineering-intro](https://github.com/coleam00/context-engineering-intro) — inspiration for some commands and rules
- [trailofbits/claude-code-config](https://github.com/trailofbits/claude-code-config) — security and privacy focused settings
- [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) — naming conventions and code review patterns
- [wshobson/agents](https://github.com/wshobson/agents) — Python style and naming patterns
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) — multi-agent code review pattern
- [coleam00/archon](https://github.com/coleam00/archon) — agent-harness skill reference repo
- [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) — agent-harness skill reference repo
