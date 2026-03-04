---
name: plugin-browser
description: Browse and discover Claude Code skills, agents, and plugins from the wshobson/agents community repository. Use when the user wants to find existing skills, agents, commands, or plugins — e.g., "what plugins are available?", "is there a skill for code review?", "show me community agents", "find a plugin for testing". Also use when the user mentions the wshobson/agents repo or wants to adopt/install a community plugin into their project.
allowed-tools:
  - "Bash(bash ~/.claude/skills/plugin-browser/scripts/setup_agents_repo.sh)"
  - "Glob(~/.claude/skills-references/plugin-browser/agents/**)"
  - "Read(~/.claude/skills-references/plugin-browser/agents/**)"
  - "mcp__claude-context__search_code"
  - "mcp__claude-context__get_indexing_status"
---

# Claude Code Plugin Browser

Help users discover and adopt skills, agents, and plugins from [wshobson/agents](https://github.com/wshobson/agents).

## Repository Structure

Each plugin is a focused automation unit containing:

- `agents/` — Specialized sub-agents
- `commands/` — Slash commands and workflows
- `skills/` — Modular knowledge packages

## Plugin Catalog

The marketplace index at `~/.claude/skills-references/plugin-browser/agents/.claude-plugin/marketplace.json` contains structured metadata for all plugins (name, description, category, version). Use it as the primary entry point for browsing — it's faster than globbing directories and gives richer context for recommendations.

```
Read(~/.claude/skills-references/plugin-browser/agents/.claude-plugin/marketplace.json)
```

Each plugin also has a `plugin.json` at `plugins/<name>/.claude-plugin/plugin.json` with its own metadata.

## Browse & Search

**Catalog first** — read `marketplace.json` to get an overview of all plugins with descriptions and categories. Filter by category to narrow results for the user.

**Browse** to list contents of a specific plugin:

```
Glob(~/.claude/skills-references/plugin-browser/agents/plugins/<name>/**/*.md)
```

**Search** to find components by topic or capability:

```
mcp__claude-context__search_code(
  path="~/.claude/skills-references/plugin-browser/agents",
  query="<user need>"
)
```

If semantic search fails (codebase not indexed), fall back to Grep:

```
Grep(pattern="<keyword>", path="~/.claude/skills-references/plugin-browser/agents/", glob="*.md")
```

## Workflow

1. **Catalog** — read `marketplace.json` to understand what's available, then filter by category or search by need.
2. Present matches with name, description, and category from the catalog.
3. **Read** the component's SKILL.md or README before recommending — understand what it actually does.
4. **Install** selected components by copying the relevant files into the user's project:
   - Skills → `cp -r ~/.claude/skills-references/plugin-browser/agents/plugins/<plugin>/skills/<name>/ .claude/skills/<name>/`
   - Agents → `cp ~/.claude/skills-references/plugin-browser/agents/plugins/<plugin>/agents/<name>.md .claude/agents/<name>.md`
   - Commands → `cp ~/.claude/skills-references/plugin-browser/agents/plugins/<plugin>/commands/<name>.md .claude/commands/<name>.md`
   - Entire plugin → copy all its skills, agents, and commands into the respective directories

   Always confirm with the user before copying. If destination files already exist, warn before overwriting.

## Setup and Troubleshooting

If `~/.claude/skills-references/plugin-browser/agents/` is missing, run `bash ~/.claude/skills/plugin-browser/scripts/setup_agents_repo.sh`.
Then check if the codebase is indexed (`mcp__claude-context__get_indexing_status`);
if not, index it with `mcp__claude-context__index_codebase(path="~/.claude/skills-references/plugin-browser/agents", splitter="ast")`.