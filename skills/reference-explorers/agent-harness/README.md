# agent-harness skill

Browse and explore agent harness frameworks and Claude Code resource collections.

## First-time setup

The skill uses local clones of curated repos for semantic search. Run the two setup scripts once before using the skill.

### 1. Clone reference repos

```sh
bash ~/.claude/skills/reference-explorers/agent-harness/scripts/clone-references.sh
```

This clones all tracked repositories into `~/.claude/skills-references/agent-harness/`. Each repo is cloned with sparse checkout, excluding irrelevant content (CI configs, license files, etc.) to keep the index lean.

To add or update an individual repo, run its script directly:

```sh
bash ~/.claude/skills/reference-explorers/agent-harness/scripts/clone-references/clone-coleam00-archon.sh
```

### 2. Index for semantic search

```sh
bash ~/.claude/skills/reference-explorers/agent-harness/scripts/index-references.sh
```

This indexes the cloned repos via the `claude-context` MCP server, making them available for semantic search during skill lookup.

> Requires the `claude-context` MCP server to be configured. See the project README for MCP setup.

## Updating

Re-run both scripts to pull the latest content and rebuild the index:

```sh
bash ~/.claude/skills/reference-explorers/agent-harness/scripts/clone-references.sh
bash ~/.claude/skills/reference-explorers/agent-harness/scripts/index-references.sh
```
