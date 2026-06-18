---
name: to-plan
description: Turn the current conversation context into a plan and save it under .claude/plans/. Use when the user wants to capture the current context as an implementation plan.
disable-model-invocation: true
---

# To Plan

Take the current conversation context and codebase understanding and produce a plan. Don't re-interview the user for design details you already have — synthesize what you know. The only check-ins are confirming the module decomposition and the test scope (step 3); derive everything else yourself.

This command is designed to run after a `grill-with-docs` session, where the design has already been stress-tested against the domain model and the conversation holds a well-specified context. If that grounding is missing, prefer running `grill-with-docs` first.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary (`CONTEXT.md`) vocabulary throughout the plan, and respect any ADRs in the area you're touching.

2. Sketch out the major modules you will need to build or modify to complete the implementation. Actively look for opportunities to extract deep modules that can be tested in isolation — a deep module (as opposed to a shallow one) encapsulates a lot of functionality behind a simple, testable interface that rarely changes.

3. Confirm with the user that these modules match their expectations, and ask which ones they want tests written for. These two check-ins are the exception to "don't re-interview" above — they pin the decisions the rest of the plan depends on.

4. Write the plan using the template at [~/.claude/templates/plan-template.md](~/.claude/templates/plan-template.md) and save it under `.claude/plans/`. Name the file with a zero-padded sequential number prefix followed by a short kebab-case slug of the goal, so plans sort in creation order when the directory is listed. Determine the next number by finding the highest existing `NN-` prefix in `.claude/plans/` and adding one (start at `01` if the directory is empty or has no numbered plans) — e.g. `01-add-oauth-login.md`, then `02-messaging.md`. Report the saved path back to the user when done.
