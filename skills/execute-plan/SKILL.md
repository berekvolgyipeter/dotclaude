---
name: execute-plan
description: Execute a plan test-first — internalize, sequence the work, implement via the tdd red-green-refactor loop, validate, and verify
disable-model-invocation: true
argument-hint: "@plan-file"
---

# Execute Plan

Implement the feature defined in the plan below. Follow the plan's requirements and module map precisely, along with whichever of Before You Start, Phases, key decisions, testing strategy, and scope the plan includes.

<plan>
$ARGUMENTS
</plan>

Build it test-first. Invoke the `tdd` skill and follow its red-green-refactor loop — the user already confirmed the interface decisions (Module Map) and the behaviors to test (Testing Strategy) while the plan was written, so treat those as the approved inputs the skill asks for rather than re-interviewing the user.

## Execution Process

### 1. Load and Internalize

- Read the plan in full and identify every requirement, module, key decision, the behaviors the Testing Strategy calls for, and the setup and phases it sets out
- If the plan has an Origin line, read the design docs it links — they hold the goal and what was set aside
- Explore the codebase to locate the modules and interfaces the plan describes — the plan deliberately omits file paths, so map its decisions onto the real files yourself
- Read `~/.claude/shared/planning-context.md` and follow its Glossary and ADRs and Rules sections
- If the plan references documentation URLs, fetch them for additional context
- Extend the research if the plan's context is insufficient to begin implementation

### 2. Sequence the Work

ULTRATHINK about dependencies and implementation order:
- Set up what Before You Start asks for (branch, base) first
- With Phases, work phase by phase, leaving the system working after each; within a phase, order the modules so each is built on top of what it depends on — no backtracking
- For each module the Testing Strategy marks for testing, list the behaviors to drive out, smallest first; the module's interface is the test surface
- Note which existing patterns and prior-art tests to mirror, and where library gotchas apply
- Create a TodoWrite plan: one item per behavior cycle for tested modules, one per change for the rest

### 3. Implement Test-First

Before writing anything, study the prior art the plan points to — the existing tests and modules it names as patterns to mirror. Match them throughout: don't invent a new pattern when the codebase already solves the problem.

Work module by module in the order from step 2. Drive each module the Testing Strategy marks for testing through the `tdd` skill's loop, one behavior at a time, following the structure and conventions of the prior-art tests and mirroring the existing patterns in the code.

Modules the Testing Strategy does not mark for testing: implement directly, mirroring the codebase's existing patterns. Mark each todo complete as you finish it.

### 4. Validate

- Run the project's full test suite, including the tests you just wrote — `make test` if the project defines it, otherwise the project's documented runner (`pytest`, `npm test`, `cargo test`, etc.). Fix failures by fixing code, not by weakening or deleting tests
- Run the project's linter — `make lint` if defined, otherwise the documented lint/format/type-check commands — and fix any errors
- Re-run until both pass clean

### 5. Final Verification

- Re-read the plan's goal first and confirm the result reaches it, then confirm every requirement is satisfied and no out-of-scope work crept in
- Confirm the behaviors named in the Testing Strategy are covered by tests that verify them through the public interface
- Write each deviation from the plan, with its reason, and the results of any gating or manual tests into the plan's Execution Record section
- Report completion status with any deviations from the original plan
