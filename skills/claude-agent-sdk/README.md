# claude-agent-sdk skill

Expert implementation guidance for the Claude Agent SDK (Python).

## First-time setup

### 1. Clone the SDK repo

```sh
bash ~/.claude/skills/claude-agent-sdk/scripts/clone-python-sdk-repo.sh
```

Clones `anthropics/claude-agent-sdk-python` into `~/.claude/skills-references/claude-agent-sdk/claude-agent-sdk-python/` with sparse checkout, excluding tests, CI, changelogs, and other non-essential files.

### 2. Index for semantic search

```sh
bash ~/.claude/skills/claude-agent-sdk/scripts/index-references.sh
```

Indexes the cloned repo via the `claude-context` MCP server, making it available for semantic search during skill lookup.

> Requires the `claude-context` MCP server to be configured. See the project README for MCP setup.

## Doc index refresh

`references/agent-sdk-urls.md` is a snapshot of the Agent SDK (Python) pages listed in Anthropic's `code.claude.com/llms.txt`. A committed snapshot ships with the skill so it works offline. The skill refreshes the snapshot via `scripts/fetch-agent-sdk-urls.sh` when it needs to consult official docs and the existing snapshot may be stale; for purely conceptual answers or when the existing snapshot is sufficient, it reads the committed snapshot as-is. No manual step required — `SKILL.md` is the authoritative description of when the refresh runs.
