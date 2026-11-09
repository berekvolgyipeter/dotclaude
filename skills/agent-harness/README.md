# agent-harness skill

Browse and explore agent harness frameworks and Claude Code resource collections.

## First-time setup

The skill uses local clones of curated repos for semantic search. Clone and index them once before using the skill.

### 1. Clone reference repos

```sh
python3 ~/.claude/scripts/skill_references.py sync ~/.claude/skills/agent-harness
```

This clones every repo listed in `references/catalog.json` into `~/.claude/skills-references/agent-harness/`, or pulls it if already present. Each catalog entry's `sparse` patterns limit the checkout to content worth searching (skills, agents, docs) and leave out noise such as tests, CI, and source code; an entry without `sparse` is checked out in full. The patterns are reapplied on every run.

To add a repo, add an entry to the catalog and re-run the command.

### 2. Index for semantic search

Ask Claude to index `~/.claude/skills-references/agent-harness` with the `claude-context` MCP server's `index_codebase` tool, or run `/refresh-references`, which indexes as its last step.

> Requires the `claude-context` MCP server (`make mcp`). See the project README.

## Updating

Run `/refresh-references` every once in a while. It syncs the repos, audits them against upstream, refines the catalog's sparse patterns and descriptions, and re-indexes.

To only check for upstream layout changes, run the audit:

```sh
python3 ~/.claude/scripts/skill_references.py audit ~/.claude/skills/agent-harness
```

It reports stale sparse patterns, top-level entries added or removed since the previous audit with their checked-out/excluded file counts, and clones no catalog entry owns.
