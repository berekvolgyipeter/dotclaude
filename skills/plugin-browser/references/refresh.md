# Refresh the references

Upstream repos get restructured, renamed, and extended over time, so the clones and the catalog drift. Bring them back in line with what upstream actually contains. On a first run this also clones every repo.

## 1. Sync and audit

```sh
python3 ~/.claude/skills/plugin-browser/scripts/skill_references.py sync ~/.claude/skills/plugin-browser
python3 ~/.claude/skills/plugin-browser/scripts/skill_references.py audit ~/.claude/skills/plugin-browser
```

Sync clones each catalog repo, or pulls it if present, and reapplies its `sparse` patterns; an entry without `sparse` is checked out in full. The audit prints, per repo: the last upstream commit date, any `sparse` pattern that matches nothing upstream (`STALE`), and every top-level entry with its checked-out/excluded file counts — marked `NEW` or `REMOVED` relative to the previous audit — plus clones that no catalog entry owns (`ORPHAN`).

## 2. Review the findings

Before deciding on a flagged path, look inside it: list its files with `git -C <clone> ls-tree -r --name-only HEAD <path>` and read a sample with `git -C <clone> show HEAD:<file>`. Folder names mislead — a `docs/` can be user guides or internal planning notes — so decide from content, not names.

A path belongs in the checkout when someone browsing for skills, agents, commands, plugins, or agent frameworks would want to read it: component definitions, plugin manifests, workflow definitions, the README, and user-facing guides. It stays out when it is noise for search: tests, CI, build and source code, lockfiles, translations, copies of the same skills generated for other harnesses, and the maintainers' internal plans or notes.

- **STALE pattern** — remove it, or point it at where the content moved.
- **NEW or excluded entry** — include it if it passes the test above.
- **Last commit long ago** — check the repo on GitHub for archival, a rename, or a successor, and report it.
- **ORPHAN clone** — report it; a catalog rename leaves the old clone behind.

## 3. Refresh descriptions

For each repo whose contents changed, check its catalog `description`, `topics`, and `content_types` against the README and component folders. Keep descriptions timeless: describe purpose, domains, and distinguishing traits, and leave out counts, versions, and exhaustive lists of skill or plugin names — those rot with every upstream commit. Name a component only when it is the repo's stable identity (a flagship entry point, a naming prefix).

## 4. Apply and verify

Edit the `sparse` lists and descriptions in the catalog, then re-run sync and audit until no `STALE` patterns remain and the checkout matches your decisions.

## Output

Report: patterns changed (with the evidence that justified each), descriptions updated, and anything that needs the user's decision — archived or renamed repos, orphan clones, or paths you could not classify.
