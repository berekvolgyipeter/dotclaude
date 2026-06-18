---
name: execute-plan
description: Execute a plan test-first — internalize, sequence the work, implement via the tdd red-green-refactor loop, validate, and verify
disable-model-invocation: true
argument-hint: "@plan-file"
---

# Execute Plan

Implement the feature defined in the plan below. Follow the plan's requirements and module map precisely, along with whichever of key decisions, testing strategy, and scope the plan includes.

<plan>
$ARGUMENTS
</plan>

Build it test-first. Invoke the `tdd` skill and follow its red-green-refactor loop — the plan already encodes the interface decisions (Module Map) and the behaviors worth testing (Testing Strategy), so treat those as the approved inputs the skill asks for rather than re-interviewing the user.

## Execution Process

### 1. Load and Internalize

- Read the plan in full and identify every requirement, module, key decision, and the behaviors the Testing Strategy calls for
- Explore the codebase to locate the modules and interfaces the plan describes — the plan deliberately omits file paths, so map its decisions onto the real files yourself
- Respect the project's domain glossary (`CONTEXT.md`) and any ADRs in the area you're touching
- If the plan references documentation URLs, fetch them for additional context
- Extend the research if the plan's context is insufficient to begin implementation

### 2. Sequence the Work

ULTRATHINK about dependencies and implementation order:
- Order the modules so each is built on top of what it depends on — no backtracking
- For each module the Testing Strategy marks for testing, list the behaviors to drive out, smallest first; the module's interface is the test surface
- Note which existing patterns and prior-art tests to mirror, and where library gotchas apply
- Create a TodoWrite plan: one item per behavior cycle for tested modules, one per change for the rest

### 3. Implement Test-First

Before writing anything, study the prior art the plan points to — the existing tests and modules it names as patterns to mirror. Match them throughout: don't invent a new pattern when the codebase already solves the problem.

Work module by module in dependency order. For each module the Testing Strategy marks for testing, drive it out in **vertical slices** via the `tdd` skill's loop — one behavior at a time, never all tests then all code:

- **RED** — write one test for the next behavior through the module's public interface, following the structure and conventions of the prior-art tests; run it; watch it fail for the right reason
- **GREEN** — write the minimal code to pass, mirroring the existing patterns rather than minimal-but-novel scaffolding; run it; watch it pass
- Repeat for the next behavior
- **REFACTOR** — only once green: extract duplication, deepen modules, bring the code further in line with surrounding conventions; re-run tests after each step. Never refactor while red.

Modules the Testing Strategy does not mark for testing: implement directly, mirroring the codebase's existing patterns. Mark each todo complete as you finish it.

### 4. Validate

- Run the project's full test suite, including the tests you just wrote — `make test` if the project defines it, otherwise the project's documented runner (`pytest`, `npm test`, `cargo test`, etc.). Fix failures by fixing code, not by weakening or deleting tests
- Run the project's linter — `make lint` if defined, otherwise the documented lint/format/type-check commands — and fix any errors
- Re-run until both pass clean

### 5. Final Verification

- Re-read the plan and confirm every requirement is satisfied and no out-of-scope work crept in
- Confirm the behaviors named in the Testing Strategy are covered by tests that verify them through the public interface
- Report completion status with any deviations from the original plan
