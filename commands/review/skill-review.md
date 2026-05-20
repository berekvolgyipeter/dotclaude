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

<path>
$ARGUMENTS
</path>

Use the **skill-creator** skill for structural checks (anatomy, progressive disclosure, writing patterns) and the **prompt-engineering** skill for instruction quality (over-constraining, example gaps, vague action language). Do not modify anything.

Detect the type from the `$ARGUMENTS` reference:
- **Directory reference** — treat as a skill; use Glob to find `SKILL.md` inside it and review that file
- **`SKILL.md` filename** — treat as a skill
- **Any other `.md` file** — treat as a command

If a non-`SKILL.md` file is missing `disable-model-invocation: true`, report it as a **CRITICAL** finding (missing required frontmatter key) — do not reclassify it as a skill.

Read every file referenced with `@path` syntax in the target file (and recursively in those files). Their content is part of the skill/command and must be reviewed alongside the entry file. Report findings against the referenced files using their own paths.

For commands, also check what skill-creator won't cover:
- `disable-model-invocation: true` is present
- `argument-hint` is set if the command takes arguments
- `$ARGUMENTS` is used in the body if it receives a file reference
- `allowed-tools` only lists what the body actually calls

Report issues by severity (critical / major / minor) with file:line references and concrete fixes. Keep it short.
