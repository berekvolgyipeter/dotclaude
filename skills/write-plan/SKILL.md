---
name: write-plan
description: Write an implementation plan from a change folder's design, the current conversation, or a short prompt, and save it in its change folder, one plan per repo
disable-model-invocation: true
argument-hint: "[feature description | @change-folder]"
effort: max
model: opus
---

# Write Plan

Turn the input below into an implementation plan: how the change is built in code.

<request>
$ARGUMENTS
</request>

## Step 1 — Pick the Input

Use the first that applies:

1. **A change folder with a design** — design docs plus evidence files, named in the request or written in this conversation. The design docs are the settled design: goals, background, decisions and what was set aside. The evidence file holds code facts to re-check, not settled fact.
2. **The conversation** — a design discussed and settled in this session. Synthesize it; don't re-interview the user for details you already have.
3. **The request alone** — a short, possibly vague feature description. Research the rest yourself.

If there is no input at all, ask what to plan and stop.

Plan one repo at a time. When the change spans several repos, plan only the repo the request names, or ask which one first, and work from that repo's design doc and evidence file.

Whatever the input, name its goal — what the user wants to be true once the work ships. Take it from the design docs' Goal section or the conversation; for a bare request, confirm it with the user in one line before researching. The plan is judged against it.

## Step 2 — Research

- Read `~/.claude/shared/planning-context.md` and follow its Glossary and ADRs and Rules sections.
- Explore the area the change targets: similar features and patterns, the modules you'll build or modify, the conventions to follow, and the test patterns already in use.
- With a design, re-check against the code every evidence fact the plan will rely on. The evidence is written mid-design; leave out any fact a later decision overtook.
- When the change involves an external library or unfamiliar API, use WebSearch and Context7 for documentation, examples and pitfalls, and note the URLs. Skip this for changes confined to existing internal code.
- Use AskUserQuestion only for what research cannot answer — e.g. which pattern to mirror, or product intent.

## Step 3 — Design

ULTRATHINK about the design. Sketch the modules to build or modify, looking actively for deep modules — a lot of behaviour behind a small interface that rarely changes. Apply the deletion test to each: if deleting it would make complexity reappear across its callers, it earns its keep; if complexity just vanishes, it was a pass-through. Name seams in the glossary's language and don't re-litigate ADRs.

Unless the plan builds on a design (which already had its architecture review), invoke the `improve-codebase-architecture` skill in scoped mode on the sketch, and fold its findings into the module split.

Then check in with the user once, following `~/.claude/shared/meet-the-user.md`: confirm the module split matches their expectations, ask which modules they want tests for, and for each of those confirm the main behaviors to test. These answers pin everything that follows.

## Step 4 — Write

Write the plan using the template in [plan-template.md](references/plan-template.md). Fold the research into it:

- **Module Map** — each module by its interface (the test surface): operations, key types, invariants, error modes, and its depth from the deletion test. Reference the real patterns you found.
- **Key Decisions** — schema changes, API contracts and architectural decisions as `<decision>: <rationale>`, respecting ADRs. Code-level reasons belong here.
- **Testing Strategy** — the behaviors the user confirmed, verified through public interfaces, not implementation details. Cite prior-art tests to mirror, and say which modules warrant integration-style tests and why.
- **Notes & Sources** — documentation URLs and library gotchas, with the *why*.

With a design, follow the template's rule for plans that build on one.

## Step 5 — Self-Review

Check the draft and fix every issue in place before saving:

1. **Goal** — the plan reaches the goal from the design or the conversation, not only the literal request.
2. **Coverage** — every requirement maps to a module or decision.
3. **Consistency** — TL;DR, Goal, Requirements, Module Map, Phases and Testing Strategy agree; the modules can be built in order without backtracking; nothing strays into Out of Scope.
4. **References exist** — every module, test, pattern and URL the plan names exists; verify with `grep`/`find`/Read.
5. **Rules** — nothing contradicts a rule, glossary term or ADR loaded in Step 2.
6. **No speculation** — no feature, abstraction, flag or fallback the requirements don't need.
7. **No repetition** — nothing restates the design docs.

## Step 6 — Save

Save the plan with the Write tool as `plan.md`, or `plan-<repo>.md` when the change spans several repos: in the change folder of the design it builds on, or else in a new change folder named per the Change folder section of `~/.claude/shared/planning-context.md`. Report the saved path.
