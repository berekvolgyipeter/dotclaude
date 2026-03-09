# slither skill

Slither static analysis expert for Solidity & Vyper.

## First-time setup

### 1. Clone the Slither repo

```sh
bash ~/.claude/skills/slither/scripts/clone-slither-repo.sh
```

Clones `crytic/slither` into `~/.claude/skills-references/slither/slither/` with sparse checkout, excluding tests, CI, scripts, and other non-essential files.

### 2. Index for semantic search

```sh
bash ~/.claude/skills/slither/scripts/index-references.sh
```

Indexes the cloned repo via the `claude-context` MCP server, making it available for semantic search during skill lookup.

> Requires the `claude-context` MCP server to be configured. See the project README for MCP setup.

## Updating

Re-run both scripts to pull the latest source and rebuild the index:

```sh
bash ~/.claude/skills/slither/scripts/clone-slither-repo.sh
bash ~/.claude/skills/slither/scripts/index-references.sh
```
