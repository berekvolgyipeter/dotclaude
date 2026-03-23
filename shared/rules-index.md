# Rules Index

Registry of all user-level rule files.

## Rules (`~/.claude/rules/`)

Always-loaded — auto-discovered by Claude Code.

| Rule file                     | Covers                                           |
| ----------------------------- | ------------------------------------------------ |
| `~/.claude/rules/general.md`  | Behavioral rules, general philosophy, tool prefs |

## Context Rules (`~/.claude/context-rules/`)

Loaded on demand by the `load-context-rules.sh` hook when Edit/Write targets a matching file pattern.

| Rule file                              | Covers                                           | Loaded when                                     |
| -------------------------------------- | ------------------------------------------------ | ----------------------------------------------- |
| `~/.claude/context-rules/py-code.md`   | Python style, KISS/YAGNI, typing, naming, error handling, code structure | Any `*.py` file is involved                     |
| `~/.claude/context-rules/py-test.md`   | Testing best practices, fixtures, mocking        | Any `*.py` file under a `test/` or `tests/` directory, or any `test_*.py` / `*_test.py` file |
| `~/.claude/context-rules/docs.md`      | Documentation principles, timeless writing       | Any `*.md` documentation file is involved       |
