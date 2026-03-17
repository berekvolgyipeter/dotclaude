# dotclaude

Shared Claude Code configuration repo symlinked into `~/.claude/`. See @README.md for full documentation.

## Rules for Changes

- **Always update `README.md`** when adding, removing, or changing any rule, command, skill, agent, hook, template, or other configuration. Keep the README in sync with the actual repo contents.
- **Every command file** (`commands/*.md`) must include `disable-model-invocation: true` in its YAML frontmatter.
- **Update the rules index** (`shared/rules-index.md`) when adding or removing rule files — keep it in sync with the actual rule files in the repo.
- **Acknowledge sources** — when any content is added or inspired by a plugin found via the `plugin-browser` skill (whether a new skill/command/agent or content incorporated into existing files like rules), add the reference repo to the `Acknowledgments` section in `README.md`.
- **Hook scripts go in `hooks/`** — shell scripts registered as hooks in `settings.json` belong in `hooks/`. General helper scripts (e.g., command utilities invoked via `!` bang syntax) belong in `scripts/`.
