---
name: agent-harness
description: Browse and explore agent harness frameworks and Claude Code resource collections. Use when the user wants to learn about, explore, or use agent orchestration frameworks, multi-agent architectures, or Claude Code resource catalogs — e.g., "how does Archon work?", "show me ECC (everything-claude-code) resources", "find an agent pattern for X", "explore agent harness repos", "what's in the agent harness catalog?". Make sure to use this skill whenever the user asks about any agent framework, multi-agent pattern, or Claude Code resource collection — even if they don't explicitly say "agent harness" or name a specific repo.
allowed-tools:
  - Bash(grep *)
  - Bash(find *)
  - Read
  - mcp__claude-context__search_code
---

# Agent Harness

Help users discover, explore, and understand agent harness frameworks and Claude Code resource collections from curated repositories.

## Catalog

The catalog at `~/.claude/skills/agent-harness/references/catalog.json` lists all indexed repositories with descriptions and topics. Read it first to understand what's available and which repo is most relevant to the user's need.

Each entry has these fields: `github` (source repo), `local_path` (where it's cloned), `description` (what it contains), `topics` (keyword tags), and `content_types` (e.g. frameworks, workflows, agents, skills, rules).

All repos are cloned and indexed together under a single path:

```
~/.claude/skills-references/agent-harness/
```

Each repo lives at the `local_path` specified in the catalog (e.g., `~/.claude/skills-references/agent-harness/coleam00-archon/`).

## Search

**Always start with semantic search** — it combines semantic understanding with BM25 keyword matching, so it surfaces conceptually relevant results even when exact keywords differ. Only fall back to keyword search if semantic search returns no results or the index is unavailable.

**Primary — semantic search:**

```
mcp__claude-context__search_code(
  path="~/.claude/skills-references/agent-harness",
  query="<user need>"
)
```

**Fallback — keyword search** (only when semantic search fails or is unavailable). Use `grep` and `find` through Bash: they also search hidden folders such as `.archon/` and `.claude/`, where workflows and skills live.

```sh
grep -ril --include='*.md' --include='*.yaml' "<keyword>" ~/.claude/skills-references/agent-harness/
```

## Browse

To list contents of a specific repo — docs and skills are Markdown, workflow definitions are YAML:

```sh
find ~/.claude/skills-references/agent-harness/<repo-dir> \( -name '*.md' -o -name '*.yaml' \) -not -path '*/.git/*'
```

Check for plugin manifests if present:

```sh
find ~/.claude/skills-references/agent-harness/<repo-dir> -name '*plugin*.json' -not -path '*/.git/*'
```

## Workflow

1. **Understand the need** — ask clarifying questions if the user's request is vague (e.g., "agent" could mean orchestration framework, a specific Claude Code agent, or a resource collection).
2. **Catalog** — read `~/.claude/skills/agent-harness/references/catalog.json` to identify which repos are relevant based on descriptions and topics.
3. **Search** — use semantic search to find matching content across all repos.
4. **Read before recommending** — read the relevant README, docs, or workflow definitions before presenting findings. Understand what it does, what dependencies it needs, and how to use it.
5. **Present matches** — show name, description, source repo, and category. When multiple options exist, compare them briefly.
6. **Guide usage** — explain how to run, configure, or integrate what was found. Point to setup docs, env vars, or prerequisites as needed.
