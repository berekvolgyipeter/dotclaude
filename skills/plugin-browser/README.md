# plugin-browser skill

Browse and discover Claude Code skills, agents, commands, and plugins from community and official repositories.

## First-time setup

The skill uses local clones of plugin marketplace repos for semantic search. Run the two setup scripts once before using the skill.

### 1. Clone reference repos

```sh
bash ~/.claude/skills/plugin-browser/scripts/sync-references.sh
```

This clones every repo listed in `references/catalog.json` into `~/.claude/skills-references/plugin-browser/`, or pulls it if already present. Each catalog entry's `sparse` patterns limit the checkout to content worth searching (skills, agents, commands, plugin manifests, docs) and leave out noise such as tests, CI, and other harnesses' copies; an entry without `sparse` is checked out in full. The patterns are reapplied on every run.

To add a repo, add an entry to the catalog and re-run the script.

### 2. Index for semantic search

```sh
bash ~/.claude/skills/plugin-browser/scripts/index-references.sh
```

This indexes the cloned repos via the `claude-context` MCP server, making them available for semantic search during skill lookup.

> Requires the `claude-context` MCP server to be configured. See the project README for MCP setup.

## Updating

Run `/refresh-references` every once in a while. It syncs the repos, audits them against upstream, refines the catalog's sparse patterns and descriptions, and re-indexes.

To only check for upstream layout changes, run the audit:

```sh
bash ~/.claude/skills/plugin-browser/scripts/audit-references.sh
```

It reports stale sparse patterns, top-level entries added or removed since the previous audit with their checked-out/excluded file counts, and clones no catalog entry owns.
