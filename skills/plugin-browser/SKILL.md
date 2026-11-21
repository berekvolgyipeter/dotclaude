---
name: plugin-browser
description: Browse and discover Claude Code skills, agents, commands, and plugins, and explore agent harness frameworks and Claude Code resource collections, from curated community and official repositories. Use when the user wants to find, explore, or learn about existing skills, agents, commands, plugins, agent orchestration frameworks, or multi-agent patterns — e.g., "what plugins are available?", "is there a skill for code review?", "show me community agents", "find a plugin for testing", "how does Archon work?", "find an agent pattern for X". Also use when the user wants to learn what a community plugin or framework does, or to refresh, update, or audit the plugin-browser reference repos.
allowed-tools:
  - Bash(grep *)
  - Bash(find *)
  - Bash(git -C * log *)
  - Bash(git -C * ls-tree *)
  - Bash(git -C * show *)
  - Bash(python3 ~/.claude/skills/plugin-browser/scripts/*)
  - Read
  - Edit(~/.claude/skills/plugin-browser/references/catalog.json)
---

# Plugin Browser

Help users discover and explore skills, agents, commands, plugins, and agent harness frameworks from curated community and official repositories.

## Catalog

The catalog at `~/.claude/skills/plugin-browser/references/catalog.json` lists every repository with its description and topics. Each entry has these fields: `github` (source repo), `local_path` (where it's cloned), `description` (what it contains), `topics` (keyword tags), and `content_types` (e.g. skills, agents, commands, plugins, frameworks, workflows).

All repos are cloned under `~/.claude/skills-references/plugin-browser/`, each at its catalog `local_path`.

## Check the clones

Before searching, check that the clones were synced recently and since the catalog last changed. `find ~/.claude/skills-references/.plugin-browser-synced -mtime -30 -newer ~/.claude/skills/plugin-browser/references/catalog.json` prints the path when they were. If it prints nothing or errors, sync them before searching:

```sh
python3 ~/.claude/skills/plugin-browser/scripts/skill_references.py sync ~/.claude/skills/plugin-browser
```

If the sync fails, say so and search the clones that exist.

When the user asks to refresh, update, or audit the references, follow [references/refresh.md](references/refresh.md) instead — it also audits the clones against upstream and refines the catalog.

## Search

Pick the relevant repos from the catalog's descriptions and topics, then search them with `grep` and `find`; they also cover hidden folders such as `.claude-plugin/`, `.archon/` and `.claude/`, where manifests, workflows and skills live. Try several phrasings and synonyms of the user's need, since keyword search only matches the words you give it.

```sh
grep -ril --include='*.md' --include='*.yaml' --include='*.json' "<keyword>" ~/.claude/skills-references/plugin-browser/<repo-dir>
```

To list a repo's contents, and its plugin manifests for richer metadata:

```sh
find ~/.claude/skills-references/plugin-browser/<repo-dir> \( -name '*.md' -o -name '*.yaml' \) -not -path '*/.git/*'
find ~/.claude/skills-references/plugin-browser/<repo-dir> \( -name 'marketplace.json' -o -name '*plugin*.json' \) -not -path '*/.git/*'
```

## Workflow

1. **Understand the need** — ask clarifying questions if the request is vague (e.g., "security" could mean AppSec scanning, smart contract auditing, or secrets detection; "agent" could mean an orchestration framework or a single Claude Code agent).
2. **Catalog** — read the catalog to pick the relevant repos.
3. **Search** — find matching components or docs in those repos.
4. **Read before recommending** — read the component's SKILL.md, README, plugin.json, or workflow definition before presenting it. Understand what it does, what tools it needs, and any dependencies.
5. **Present matches** — show name, description, source repo, and category. When multiple options exist, compare them briefly.
6. **Guide usage** — for a framework, explain how to run, configure, or integrate it, pointing to its setup docs and prerequisites.
7. **Review for safety** — before installing, warn the user that community plugins are third-party content. They may request broad tool permissions, modify settings or permission files, execute shell commands via hooks, or overwrite existing configuration. Advise the user to review the plugin's contents (especially `allowed-tools`, hooks, and any shell scripts) before proceeding.
8. **Install** (if requested) — copy selected files into the user's `.claude/` directory (skills, agents, commands). Confirm before copying and warn if destination files already exist. Browse the repo's directory layout first to determine the correct source paths, since not all repos follow the same structure.
