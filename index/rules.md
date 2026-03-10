# Rules Index

Registry of all user-level rule files in `~/.claude/rules/`.

## Rule Files

| Rule file                     | Covers                                           | Load when                                       |
| ----------------------------- | ------------------------------------------------ | ----------------------------------------------- |
| `~/.claude/rules/general.md`  | Behavioral rules, general philosophy, tool prefs | Always                                          |
| `~/.claude/rules/py-code.md`  | Linting, typing, logging, formatting standards   | Any `*.py` file is involved                     |
| `~/.claude/rules/py-test.md`  | Testing best practices, fixtures, mocking        | Any `test_*.py` or `*_test.py` file is involved |
| `~/.claude/rules/docs.md`     | Documentation principles, timeless writing       | Any `*.md` documentation file is involved       |
