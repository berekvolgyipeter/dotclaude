---
name: generate-plan
description: Generate a plan from a short prompt by researching the target component, then save it under .claude/plans/. Use when the user describes a feature to build but there's no prior conversation to synthesize.
disable-model-invocation: true
argument-hint: "[feature description]"
effort: max
model: opus
---

# Generate Plan

Take the short, possibly vague feature description below and turn it into a complete plan by researching the codebase yourself.

<request>
$ARGUMENTS
</request>

## Step 1 — Research

### 1a. Codebase Analysis
- Explore the component the request targets. Use Glob and Grep to find similar features/patterns, and read the relevant modules to understand the current state.
- If present, locate and read the domain documentation for the target area: a root `CONTEXT.md` glossary (or, if a `CONTEXT-MAP.md` exists at the root, the per-context `CONTEXT.md` it points to), and any Architecture Decision Records under `docs/adr/`. Use that glossary's vocabulary throughout the plan and respect the documented decisions.
- Identify the modules you'll build or modify, the existing conventions to follow, and the test patterns already in use.

### 1b. External Research
- When the feature involves an external library or unfamiliar API, use WebSearch and Context7 to find documentation, implementation examples, best practices, and common pitfalls. Note specific URLs. Skip this for changes confined to existing internal code.

### 1c. User Clarification (only when blocked)
- Use AskUserQuestion for genuinely ambiguous requirements that research cannot resolve — e.g. which pattern to mirror, integration boundaries, or product intent. Do not interview for anything you can discover yourself.

## Step 2 — Plan

After completing research, ULTRATHINK about the design. Sketch the major modules to build or modify, actively looking for deep modules — ones that encapsulate a lot of functionality behind a simple, testable interface that rarely changes.

Invoke the `improve-codebase-architecture` skill to do this analysis with rigor: use its vocabulary exactly (module, interface, depth, seam, deepening) and apply the deletion test to each module you propose. Ground the analysis in the CONTEXT.md glossary and ADRs from Step 1a — name seams using the domain language and don't re-litigate documented decisions. Decide which modules warrant tests.

## Step 3 — Write the Plan

Write the plan using the template at [~/.claude/templates/plan-template.md](~/.claude/templates/plan-template.md).

Fold your research into the relevant sections:
- **Module Map** — describe each module by its interface (the test surface): operations, key types, invariants, error modes. Apply the deletion test to record each module's depth. Reference the real patterns you found.
- **Key Decisions** — record schema changes, API contracts, and architectural decisions as `<decision>: <rationale>`, respecting documented ADRs.
- **Testing Strategy** — cite prior-art tests in the codebase as the model to follow. Apply the `tdd` skill's philosophy: plan tests that verify behavior through public interfaces (the module's interface is the test surface), not implementation details. Note which modules warrant integration-style tests and why.
- **Notes & Sources** — capture documentation URLs and library gotchas (explain *why*, not just *what*).

## Step 4 — Save

Save the plan as a markdown file under `.claude/plans/`. Name the file with a zero-padded sequential number prefix followed by a kebab-case slug derived from the feature title, so plans sort in creation order when the directory is listed. Determine the next number by finding the highest existing `NN-` prefix in `.claude/plans/` and adding one (start at `01` if the directory is empty or has no numbered plans) — e.g. `01-add-oauth-login.md`, then `02-messaging.md`. Use the Write tool directly — it creates parent directories automatically.
