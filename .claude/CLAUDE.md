# dotclaude

Shared Claude Code configuration repo symlinked into `~/.claude/`. See @README.md for full documentation.

## Rules for Changes

- **Always update `README.md`** when adding, removing, or changing any rule, command, skill, agent, hook, template, or other configuration. Keep the README in sync with the actual repo contents.
- **Every command file** (`commands/*.md`) must include `disable-model-invocation: true` in its YAML frontmatter.
- **Update the learn skill** (`skills/learn/SKILL.md`) when adding or removing rule files — keep its "Scope reference" section in sync with the actual rule files in the repo.
