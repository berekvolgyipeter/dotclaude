---
name: plugin-browser
description: Browse and discover Claude Code skills, agents, commands, and plugins from community and official repositories. Use when the user wants to find, explore, or learn about existing skills, agents, commands, or plugins — e.g., "what plugins are available?", "is there a skill for code review?", "show me community agents", "find a plugin for testing", "browse the plugin marketplace". Also use when the user wants to learn what a community plugin does.
allowed-tools:
  - Glob
  - Grep
  - Read
  - mcp__claude-context__search_code
---

# Plugin Browser

Help users discover and explore skills, agents, commands, and plugins from community and official repositories.

## Catalog

The catalog at `~/.claude/skills/plugin-browser/references/catalog.json` lists all indexed repositories with descriptions and topics. Read it first to understand what's available and which repo is most relevant to the user's need.

Each entry has these fields: `github` (source repo), `local_path` (where it's cloned), `description` (what it contains), `topics` (keyword tags), and `content_types` (e.g. skills, agents, commands, plugins).

All repos are cloned and indexed together under a single path:

```
~/.claude/skills-references/plugin-browser/
```

Each repo lives at the `local_path` specified in the catalog (e.g., `~/.claude/skills-references/plugin-browser/wshobson-agents/`).

## Search

**Always start with semantic search** — it combines semantic understanding with BM25 keyword matching, so it surfaces conceptually relevant results even when exact keywords differ. Only fall back to Grep if semantic search returns no results or the index is unavailable.

**Primary — semantic search:**

```
mcp__claude-context__search_code(
  path="~/.claude/skills-references/plugin-browser",
  query="<user need>"
)
```

**Fallback — keyword search** (only when semantic search fails or is unavailable):

```
Grep(pattern="<keyword>", path="~/.claude/skills-references/plugin-browser/", glob="*.md")
```

## Browse

To list contents of a specific plugin or repo:

```
Glob(~/.claude/skills-references/plugin-browser/<repo-dir>/**/*.md)
```

For structured plugin repos (like wshobson-agents), check for a `marketplace.json` or `plugin.json` for richer metadata:

```
Glob(~/.claude/skills-references/plugin-browser/<repo-dir>/**/*marketplace*.json)
Glob(~/.claude/skills-references/plugin-browser/<repo-dir>/**/*plugin*.json)
```

## Workflow

1. **Understand the need** — ask clarifying questions if the user's request is vague (e.g., "security" could mean AppSec scanning, smart contract auditing, or secrets detection).
2. **Catalog** — read `~/.claude/skills/plugin-browser/references/catalog.json` to identify which repos are relevant based on descriptions and topics.
3. **Search** — use semantic search to find matching components across all repos.
4. **Read before recommending** — read the component's SKILL.md, README, or plugin.json before presenting it. Understand what it does, what tools it needs, and any dependencies.
5. **Present matches** — show name, description, source repo, and category. When multiple options exist, compare them briefly.
6. **Review for safety** — before installing, warn the user that community plugins are third-party content. They may request broad tool permissions, modify settings or permission files, execute shell commands via hooks, or overwrite existing configuration. Advise the user to review the plugin's contents (especially `allowed-tools`, hooks, and any shell scripts) before proceeding.
7. **Install** (if requested) — copy selected files into the user's `.claude/` directory (skills, agents, commands). Confirm before copying and warn if destination files already exist. Browse the repo's directory layout first to determine the correct source paths, since not all repos follow the same structure.
