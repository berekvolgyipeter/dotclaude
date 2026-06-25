---
name: refine-plan
description: Refine a plan in place — check logical correctness and rule compliance, then edit the plan to fix issues
disable-model-invocation: true
argument-hint: "@plan-file"
allowed-tools:
  - Read
  - Glob
  - Grep
---

# Refine Plan

Check the plan below for logical correctness and compliance with applicable coding rules, then **edit the plan file in place** to fix every issue you find. Do not produce a review report — the deliverable is a corrected plan.

<plan>
$ARGUMENTS
</plan>

## Step 1 — Load Applicable Rules

### User-Level Rules

Read the rules index, then read every rule file referenced in it — both always-loaded rules and context rules whose file patterns match the plan's target files:

@~/.claude/shared/rules-index.md

### Project-Level Rules

Check for `.claude/rules/` in the current project and read any rule files found there. Also read `.claude/CLAUDE.md` for project-specific instructions.

### Determine Applicable Context Rules

Based on the file types the plan touches (inferred from its Module Map, Key Decisions, and Testing Strategy):
- **Always apply**: all `rules/` files and `.claude/CLAUDE.md`
- **Conditionally apply**: context rules whose globs match the plan's target files (e.g. `py-code.md` for `.py` files, `py-test.md` for test files, `docs.md` for `.md` files)

## Step 2 — Check the Plan

ULTRATHINK and evaluate the plan against each category. For every issue found, plan the exact edit needed. The TL;DR, Goal, Requirements, and Module Map are mandatory — if any is missing, add it. For conditional sections (e.g. no Glossary, or no ADR area applies), skip that check rather than inventing the section.

### A. Logical Correctness

1. **Internal consistency** — Do the TL;DR, Goal, Requirements, Module Map, Key Decisions, and Testing Strategy agree? Does the TL;DR accurately summarize the body — outcome, scope, and risks still current? Any contradictions between sections?
2. **Dependency order** — Can the modules and decisions be executed without backtracking? Are decisions that depend on earlier work ordered correctly?
3. **Completeness** — Does each requirement have a module or decision that satisfies it? Are any aspects of the solution left unspecified?
4. **Referenced artifacts exist** — Do the modules, interfaces, patterns, and URLs in the plan actually exist in the codebase or on the web? Use Glob/Grep/Read to verify critical references.
5. **Out of Scope is honored** — Do any modules or decisions stray into work the plan declared out of scope?
6. **Glossary alignment** — Does the plan use the project's canonical terms (`CONTEXT.md`, or the per-context `CONTEXT.md` a root `CONTEXT-MAP.md` points to)? Flag any term that conflicts with the documented glossary.
7. **ADR compliance** — Do the Key Decisions respect the Architecture Decision Records in the area being touched (`docs/adr/`)? Flag any decision that silently reopens an ADR; if reopening is warranted, ensure it is called out and justified rather than assumed.

### B. Rule Compliance

For each applicable rule file loaded in Step 1, verify the plan's modules, decisions, and testing strategy do not contradict it:

- **Naming conventions** — Do proposed names follow the rules?
- **Code structure** — Do proposed modules/interfaces respect size limits and organization rules?
- **Error handling** — Does the error strategy match the rules?
- **Testing approach** — Do proposed tests follow the testing rules?
- **Style** — Do any inlined snippets follow style rules (type hints, imports, formatting)?
- **Documentation** — If docs are created/modified, do they follow documentation rules?

Flag any contradiction between the plan and a loaded rule.

### C. Implementability

1. **Ambiguity** — Any decision an AI agent would need to guess at? Resolve or mark as open.
2. **Missing context** — Are referenced modules, patterns, libraries, and gotchas explained well enough to act on?
3. **Existing patterns** — Does the plan reference real codebase patterns, or does it invent new ones where existing ones would do?
4. **Gotchas** — Are known pitfalls documented with enough "why" for the agent to avoid them?

### D. Anti-Patterns

Remove or correct:
- Speculative features not in the requirements
- Over-engineering (abstractions, flags, or fallbacks for one-time or hypothetical needs)
- Hardcoded values that should be configurable
- New patterns introduced when existing ones could be reused
- Test complexity that would be mocked away to meaninglessness

## Step 3 — Edit the Plan in Place

Use the `Edit` tool (or `Write` for a full rewrite when many sections change) on the plan file to apply corrections. For each issue:

- **Rewrite ambiguous or contradictory text** to be concrete and consistent.
- **Reorder modules and decisions** so dependencies are respected.
- **Fix wrong module names, interfaces, or references** after verifying the correct values via Glob/Grep/Read.
- **Add missing context** (references, gotchas, patterns) inline in the relevant section.
- **Align with rules** — rename symbols, adjust any snippet style, fix error-handling and testing approaches to match the loaded rules.
- **Cut anti-patterns** — delete speculative scope, unneeded abstractions, and invented patterns.

Match the plan's existing tone, structure, and formatting. Do not restructure sections that were already fine. Do not add commentary or meta-notes about what you changed inside the plan itself.

If a problem cannot be fixed without information you don't have (e.g. ambiguous product intent), leave a single, clearly marked `> **OPEN QUESTION:** …` callout in the relevant section rather than guessing.

## Step 4 — Report Back

After editing, respond with a short summary (bullet list, ≤10 items) of the substantive changes you made to the plan and any `OPEN QUESTION` callouts left for the user. Do not write this summary to a file.
