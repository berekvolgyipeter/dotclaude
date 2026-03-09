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

## Updating the documentation reference

`references/reference.md` is a hand-curated summary of the official SDK docs. To regenerate it:

1. Fetch the current doc URLs:
   ```sh
   bash ~/.claude/skills/claude-agent-sdk/scripts/fetch-agent-sdk-urls.sh
   ```
   This downloads `llms.txt` from `platform.claude.com` and saves agent-sdk URLs (Python only) to `references/agent_sdk_urls.md`.

2. Visit each URL in `references/agent_sdk_urls.md` and write a short summary for each into `references/reference.md`.

This step is manual and only needed when the SDK docs change significantly.
