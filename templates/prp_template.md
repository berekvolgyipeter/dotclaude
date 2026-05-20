# PRP Template

## Purpose
Template optimized for AI agents to implement features with sufficient context and self-validation capabilities to achieve working code through iterative refinement.

## Core Principles
1. **Context is King**: Include all necessary documentation, examples, and caveats
2. **Validation Loops**: Provide executable checks the AI can run and fix
3. **Information Dense**: Use keywords and patterns from the codebase
4. **Progressive Success**: Start simple, validate, then enhance
5. **Global rules**: Follow user-level rules — see `~/.claude/shared/rules-index.md` for the registry
6. **Project rules**: Follow project-level rules in `.claude/rules/` and `.claude/CLAUDE.md`

---

## Goal
[What needs to be built - be specific about the end state and desires]

## Why
- [Business value and user impact]
- [Integration with existing features]
- [Problems this solves and for whom]

## What
[User-visible behavior and technical requirements]

### Success Criteria
- [ ] [Specific measurable outcomes]

## All Needed Context

### Documentation & References
<!-- List all context needed to implement the feature -->
```yaml
- url: [Official API docs URL]
  why: [Specific sections/methods needed]

- file: [path/to/similar_implementation]
  why: [Pattern to follow, gotchas to avoid]

- doc: [Library documentation URL]
  section: [Specific section about common pitfalls]
  note: [Key insight that prevents common errors]

- docfile: [PRPs/ai_docs/file.md]
  why: [Docs that the user has pasted in to the project]
```

### Key Files & Directories
<!-- Curated list of files relevant to this feature — not a full tree dump -->
```yaml
- path: [src/relevant/module]
  role: [What this module does and why it matters for this feature]

- path: [src/pattern/to/follow]
  role: [Existing pattern to mirror]
```

### Desired File Changes
<!-- New or modified files and their responsibility -->
```yaml
- path: [src/new_or_changed_file]
  action: [CREATE | MODIFY]
  responsibility: [What this file does]
```

### Known Gotchas & Library Quirks
<!-- Explain the "why" so the agent generalizes correctly -->
- [Library name] requires [specific setup] because [reason — e.g., connections leak under load without pooling]
- [Framework] expects [constraint] — without this, [specific failure mode]
- Our codebase uses [convention] — see [path/to/example] for the pattern

## Implementation Blueprint

### Data Models & Structure (if applicable)
<!-- Include this section only if the feature introduces or modifies data structures -->
Define core data models here: types, schemas, validators, ORM models, etc.
Follow existing patterns in [path/to/existing/models].

### Task List
<!-- Ordered list of tasks to complete the feature -->
```yaml
Task 1:
  MODIFY src/existing_module:
    - FIND pattern: "class ExistingImplementation"
    - INJECT after line containing "def __init__"
    - PRESERVE existing method signatures

  CREATE src/new_feature:
    - MIRROR pattern from: src/similar_feature
    - MODIFY class name and core logic
    - KEEP error handling pattern identical

...(...)

Task N:
  ...
```

### Per-Task Pseudocode (as needed)
<!-- Sketch the non-obvious parts — don't write full implementations -->
```
# Task 1
# Focus on decisions and gotchas, not boilerplate

function new_feature(param):
    # Validate input first (see src/validators for the pattern)
    validated = validate_input(param)

    # This library requires connection pooling — without it, connections leak
    with get_connection() as conn:
        # Use existing retry decorator (see src/utils/retry)
        @retry(attempts=3, backoff=exponential)
        function _inner():
            # The external API returns 429 above 10 req/sec
            rate_limiter.acquire()
            return external_api.call(validated)

        result = _inner()

    # Follow standardized response format (see src/utils/responses)
    return format_response(result)
```

### Integration Points (if applicable)
```yaml
DATABASE:
  - migration: "Add column 'feature_enabled' to users table"
  - index: "CREATE INDEX idx_feature_lookup ON users(feature_id)"

CONFIG:
  - add to: [config file path]
  - pattern: "FEATURE_TIMEOUT from env var, default 30"

ROUTES:
  - add to: [router file path]
  - pattern: "Register feature_router at /feature prefix"
```

## Validation Loop

### Level 1: Lint & Type Check
```bash
# Format, lint, and type-check — fix any errors before proceeding
make lint
```

### Level 2: Unit Tests
<!-- Write tests following existing test patterns in the codebase -->
Test cases to cover:
- Happy path: valid input produces expected output
- Validation error: invalid input is rejected with a clear error
- Failure handling: external dependency failures are handled gracefully

Write tests mirroring the patterns in [path/to/existing/tests].

```bash
# Run and iterate until passing
make test
# If failing: read the error, understand root cause, fix code, re-run
```

### Level 3: Integration Test (if applicable)
[Describe how to manually verify the feature end-to-end.
 Include the specific command, endpoint, or UI flow to test.]

## Final Validation Checklist
- [ ] All tests pass: `make test`
- [ ] Code formatted and linted: `make lint`
- [ ] Manual test successful: [specific command or flow]
- [ ] Error cases handled gracefully
- [ ] Documentation updated if needed

---

## Anti-Patterns to Avoid
- Reuse existing patterns — don't invent new ones when the codebase already solves it
- Run validation at every level — don't skip because "it should work"
- Fix failing tests by fixing code — don't mock to make them pass
- Keep error handling specific — don't catch-all
- Use config for values that vary — don't hardcode
