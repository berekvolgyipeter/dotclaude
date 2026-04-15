---
name: skill-review
description: Review a skill or command file against best practices. Pass the file with @path/to/SKILL.md or @path/to/command.md.
disable-model-invocation: true
argument-hint: "@path/to/SKILL.md or @path/to/command.md"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Skill
---

# Skill / Command Review

<file>
$ARGUMENTS
</file>

Use the **skill-creator** skill for structural checks (anatomy, progressive disclosure, writing patterns) and the **prompt-engineering** skill for instruction quality (over-constraining, example gaps, vague action language). Do not modify anything.

Detect the type first:
- **Skill** — `SKILL.md` filename
- **Command** — any other `.md` file

If a non-`SKILL.md` file is missing `disable-model-invocation: true`, report it as a **CRITICAL** finding (missing required frontmatter key) — do not reclassify it as a skill.

For commands, also check what skill-creator won't cover:
- `disable-model-invocation: true` is present
- `argument-hint` is set if the command takes arguments
- `$ARGUMENTS` is used in the body if it receives a file reference
- `allowed-tools` only lists what the body actually calls

Report issues by severity (critical / major / minor) with file:line references and concrete fixes. Keep it short.
