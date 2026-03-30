---
name: execute-prp
description: Execute PRP (Product Requirements Prompt)
disable-model-invocation: true
argument-hint: "@prp-file"
---

# Execute PRP (Product Requirements Prompt)

Implement the feature defined in the PRP below. Follow the PRP's task list, validation gates, and success criteria precisely.

<prp>
$ARGUMENTS
</prp>

## Execution Process

### 1. Load and Internalize

- Read every file listed in the PRP's "Key Files & Directories" section
- Identify every requirement, success criterion, and gotcha in the PRP
- If the PRP references documentation URLs, fetch them for additional context
- Extend the research if the PRP's context is insufficient to begin implementation

### 2. Plan — ULTRATHINK

ULTRATHINK about the PRP's task list, dependencies between tasks, and implementation order. Consider:
- Which tasks can be parallelized vs. which must be sequential
- Which existing patterns (referenced in the PRP) to mirror
- Where the gotchas and library quirks apply to your implementation
- Create a TodoWrite plan mapping each PRP task to specific file changes

### 3. Implement

- Work through each task from the PRP's Task List in order
- Mirror the existing patterns referenced in the PRP — do not invent new ones when the codebase already solves it
- Mark each todo item complete as you finish it

### 4. Validate

- Run `make lint` — fix any formatting, linting, or type errors before proceeding
- Run `make test` — fix failing tests by fixing code, not by modifying or removing tests
- If the PRP defines additional validation gates, run those too
- Re-run until all pass

### 5. Final Verification

- Re-read the PRP and check every success criterion is met
- Walk through the "Final Validation Checklist" in the PRP — confirm each item
- Report completion status with any deviations from the original plan
