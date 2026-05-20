**Before drafting any rule file, invoke the `prompt-engineering` skill** and run its checklist over each draft before writing. Rule files are prompts that will steer every future session that touches a matching file — over-constraining, kitchen-sinking, and missing examples cost the user real tokens forever.

## Rule file shape

Write each rule as `.claude/rules/<name>.md` with this shape:

```markdown
---
paths:
  - "<glob>"
---

# <Module Title>

<One-paragraph module charter: what this code does, its single responsibility, and why it exists as its own module.>

## Design intent

- <principle or constraint, with a one-clause rationale when non-obvious>

## Patterns

- <concrete pattern a reader should follow>

## Conventions

- <naming / file-layout / error-handling rule specific to this module>

## Gotchas

- <non-obvious thing that has bitten someone here>
```

## Writing rules

Every bullet below is a Claude Code best practice. Every rule file must satisfy all of them.

- **Every line is a recurring token cost.** Once loaded, the rule sits in context for the rest of the session. Cut anything that doesn't earn its tokens. If a sentence only explains *what* the code does, the code already does that — delete it.
- **Architectural, not implementation-level.** Describe intent, patterns, constraints — not function signatures that will rot.
- **Concrete and verifiable.** "Retry transient errors with exponential backoff in `BaseAgent.run`" beats "be resilient".
- **Explain *why* for non-obvious rules.** A one-clause rationale outperforms a shouted command. Skip the rationale when self-evident.
- **No volatile details.** No model names, version strings, file counts, or commit-sensitive numbers. Those rot.
- **No code dumps.** One small generic example per pattern is fine; full snippets belong in the source.
- **Keep each file short enough to absorb in one read.** If a module is rich enough to need more, split it into layered rules (broader + narrower paths) rather than growing one file.
- **No over-constraining.** A wall of MUST/NEVER/ALWAYS produces brittle behaviour. One explained rationale outperforms five shouted commands.
- **Match the project's voice.** If the project's other docs are terse, be terse. If they use tables, use tables.

When creating a new rule file, use the `Write` tool — it creates parent directories automatically.
