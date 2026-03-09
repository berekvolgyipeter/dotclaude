# plugin-browser skill

Browse and discover Claude Code skills, agents, commands, and plugins from community and official repositories.

## First-time setup

The skill uses local clones of plugin marketplace repos for semantic search. Run the two setup scripts once before using the skill.

### 1. Clone reference repos

```sh
bash ~/.claude/skills/plugin-browser/scripts/clone-references.sh
```

This clones all tracked plugin marketplace repositories into `~/.claude/skills-references/plugin-browser/`. Each repo is cloned with sparse checkout, excluding irrelevant content (CI configs, license files, etc.) to keep the index lean.

To add or update an individual repo, run its script directly:

```sh
bash ~/.claude/skills/plugin-browser/scripts/clone-references/clone-anthropics-claude-plugins-official.sh
```

### 2. Index for semantic search

```sh
bash ~/.claude/skills/plugin-browser/scripts/index-references.sh
```

This indexes the cloned repos via the `claude-context` MCP server, making them available for semantic search during skill lookup.

> Requires the `claude-context` MCP server to be configured. See the project README for MCP setup.

## Updating

Re-run both scripts to pull the latest plugins and rebuild the index:

```sh
bash ~/.claude/skills/plugin-browser/scripts/clone-references.sh
bash ~/.claude/skills/plugin-browser/scripts/index-references.sh
```
