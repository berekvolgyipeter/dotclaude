---
name: refine-prp
description: Refine a PRP in place — check logical correctness and rule compliance, then edit the PRP to fix issues
disable-model-invocation: true
argument-hint: "@prp-file"
allowed-tools:
  - Read
  - Glob
  - Grep
---

# Refine PRP

Check the PRP below for logical correctness and compliance with applicable coding rules, then **edit the PRP file in place** to fix every issue you find. Do not produce a review report — the deliverable is a corrected PRP.

<prp>
$ARGUMENTS
</prp>

## Step 1 — Load Applicable Rules

### User-Level Rules

Read the rules index, then read every rule file referenced in it — both always-loaded rules and context rules whose file patterns match the PRP's target files:

@~/.claude/shared/rules-index.md

### Project-Level Rules

Check for `.claude/rules/` in the current project and read any rule files found there. Also read `.claude/CLAUDE.md` for project-specific instructions.

### Determine Applicable Context Rules

Based on the file types referenced in the PRP (e.g. "Key Files & Directories", "Desired File Changes", Task List):
- **Always apply**: all `rules/` files and `.claude/CLAUDE.md`
- **Conditionally apply**: context rules whose globs match the PRP's target files (e.g. `py-code.md` for `.py` files, `py-test.md` for test files, `docs.md` for `.md` files)

## Step 2 — Check the PRP

ULTRATHINK and evaluate the PRP against each category. For every issue found, plan the exact edit needed.

### A. Logical Correctness

1. **Internal consistency** — Do the Goal, Success Criteria, Task List, and Validation Loop agree? Any contradictions between sections?
2. **Dependency order** — Can the task list be executed sequentially without backtracking? Are tasks that depend on earlier work ordered correctly?
3. **Completeness of each task** — Does each task specify the file(s), the action (CREATE/MODIFY/DELETE), and enough detail to execute? No steps quietly skipped?
4. **Referenced artifacts exist** — Do file paths, patterns, functions, and URLs in the PRP actually exist in the codebase or on the web? Use Glob/Grep/Read to verify critical references.
5. **Success criteria are checkable** — Can each criterion be objectively verified (test passes, file exists, behavior observable)?
6. **Validation gates are executable** — Are the lint/test/manual steps concrete commands the agent can run?

### B. Rule Compliance

For each applicable rule file loaded in Step 1, verify the PRP's implementation blueprint, pseudocode, and task list do not contradict it:

- **Naming conventions** — Do proposed names follow the rules?
- **Code structure** — Do proposed files/classes/functions respect size limits and organization rules?
- **Error handling** — Does the error strategy match the rules?
- **Testing approach** — Do proposed tests follow the testing rules?
- **Style** — Do code examples follow style rules (type hints, imports, formatting)?
- **Documentation** — If docs are created/modified, do they follow documentation rules?

Flag any contradiction between the PRP and a loaded rule.

### C. Implementability

1. **Ambiguity** — Any requirement an AI agent would need to guess at? Resolve or mark as open.
2. **Missing context** — Are referenced files, patterns, libraries, and gotchas explained well enough to act on?
3. **Existing patterns** — Does the PRP reference real codebase patterns, or does it invent new ones where existing ones would do?
4. **Gotchas** — Are known pitfalls documented with enough "why" for the agent to avoid them?

### D. Anti-Patterns

Remove or correct:
- Speculative features not in the requirements
- Over-engineering (abstractions, flags, or fallbacks for one-time or hypothetical needs)
- Hardcoded values that should be configurable
- New patterns introduced when existing ones could be reused
- Test complexity that would be mocked away to meaninglessness

## Step 3 — Edit the PRP in Place

Use the `Edit` tool (or `Write` for a full rewrite when many sections change) on the PRP file to apply corrections. For each issue:

- **Rewrite ambiguous or contradictory text** to be concrete and consistent.
- **Reorder tasks** so dependencies are respected.
- **Fix wrong paths, names, or references** after verifying the correct values via Glob/Grep/Read.
- **Add missing context** (file references, gotchas, patterns) inline in the relevant section.
- **Align with rules** — rename symbols, adjust pseudocode style, fix error-handling and testing approaches to match the loaded rules.
- **Cut anti-patterns** — delete speculative scope, unneeded abstractions, and invented patterns.

Match the PRP's existing tone, structure, and formatting. Do not restructure sections that were already fine. Do not add commentary or meta-notes about what you changed inside the PRP itself.

If a problem cannot be fixed without information you don't have (e.g. ambiguous product intent), leave a single, clearly marked `> **OPEN QUESTION:** …` callout in the relevant section rather than guessing.

## Step 4 — Report Back

After editing, respond with a short summary (bullet list, ≤10 items) of the substantive changes you made to the PRP and any `OPEN QUESTION` callouts left for the user. Do not write this summary to a file.
