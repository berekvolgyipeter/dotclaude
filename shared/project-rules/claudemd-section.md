Add (or replace) a `## Rule Files — Progressive Disclosure` section in `.claude/CLAUDE.md`. Populate this exact template from the approved table:

```markdown
## Rule Files — Progressive Disclosure

Rules in `.claude/rules/` contain curated architectural knowledge: design intent, patterns, constraints, and conventions.

**Before answering questions, researching, or modifying code in any area below:** read the relevant rule file(s) FIRST. They explain the "why" and "how" without needing to scan source files. Only dive into source code for details the rules don't cover.

| Rule file | Triggers on | Covers |
|---|---|---|
| `<name>.md` | `<glob>` | <one-line summary> |
```

If a section with that exact heading already exists, replace it in place rather than appending a second one. Use `Edit` to replace only the section content, leaving the rest of CLAUDE.md untouched.
