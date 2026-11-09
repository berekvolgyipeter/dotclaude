---
name: refresh-references
description: Sync the plugin-browser and agent-harness reference repos, audit them against upstream, and refine each catalog's sparse patterns and descriptions.
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
  - Edit
  - mcp__claude-context__index_codebase
  - mcp__claude-context__get_indexing_status
---

# Refresh Skill References

The `plugin-browser` and `agent-harness` skills search local clones of upstream repos listed in each skill's `references/catalog.json`. Upstream repos get restructured, renamed, and extended over time, so the clones and the catalog drift. Bring both skills back in line with what upstream actually contains.

Work through both skills: `~/.claude/skills/plugin-browser` and `~/.claude/skills/agent-harness`.

## 1. Sync and audit

Run, per skill:

```sh
python3 ~/.claude/scripts/skill_references.py sync ~/.claude/skills/<skill>
python3 ~/.claude/scripts/skill_references.py audit ~/.claude/skills/<skill>
```

The audit prints, per repo: the last upstream commit date, any `sparse` pattern that matches nothing upstream (`STALE`), and every top-level entry with its checked-out/excluded file counts — marked `NEW` or `REMOVED` relative to the previous audit — plus clones that no catalog entry owns (`ORPHAN`).

## 2. Review the findings

Before deciding on a flagged path, look inside it: list its files with `git -C <clone> ls-tree -r --name-only HEAD <path>` and read a sample with `git -C <clone> show HEAD:<file>`. Folder names mislead — a `docs/` can be user guides or internal planning notes — so decide from content, not names.

A path belongs in the checkout when someone browsing for skills, agents, commands, or plugins would want to read it: component definitions, plugin manifests, the README, and user-facing guides. It stays out when it is noise for semantic search: tests, CI, build and source code, lockfiles, translations, copies of the same skills generated for other harnesses, and the maintainers' internal plans or notes.

- **STALE pattern** — remove it, or point it at where the content moved.
- **NEW or excluded entry** — include it if it passes the test above.
- **Last commit long ago** — check the repo on GitHub for archival, a rename, or a successor, and report it.
- **ORPHAN clone** — report it; a catalog rename leaves the old clone behind.

## 3. Refresh descriptions

For each repo whose contents changed, check its catalog `description`, `topics`, and `content_types` against the README and component folders. Keep descriptions timeless: describe purpose, domains, and distinguishing traits, and leave out counts, versions, and exhaustive lists of skill or plugin names — those rot with every upstream commit. Name a component only when it is the repo's stable identity (a flagship entry point, a naming prefix).

## 4. Apply and verify

Edit the `sparse` lists and descriptions in the catalogs, then re-run sync and audit until no `STALE` patterns remain and the checkout matches your decisions. If the repo list or catalog fields changed, update `README.md` accordingly.

Finish by re-indexing both skills for semantic search: call `mcp__claude-context__index_codebase` with the absolute path of `~/.claude/skills-references/<skill>`, `splitter: "ast"` and `force: true`, then poll `mcp__claude-context__get_indexing_status` for that path until it reports indexed or failed.

Indexing needs the `claude-context` MCP server; if it is unavailable, say so and leave indexing to the user.

## Output

Report per skill: patterns changed (with the evidence that justified each), descriptions updated, and anything that needs the user's decision — archived or renamed repos, orphan clones, or paths you could not classify.
