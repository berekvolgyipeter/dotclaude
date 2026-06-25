# Plan Template

The shape of a plan artifact saved under `.claude/plans/`.

Two rules govern the whole document:

- **Sections earn their place.** Keep a section only if this plan has real content for it. A section padded with placeholder prose is worse than an absent one. Every plan opens with TL;DR, Goal, Requirements, and Module Map — these are the floor; the rest appear when material.
- **No file paths, no stale code.** Paths and snippets rot fast. The one exception: a snippet that pins a decision more precisely than prose can (a schema, type shape, state machine, or reducer). Inline it, trimmed to the decision-rich part, and note it came from a prototype.

Use the project's domain glossary (`CONTEXT.md`) vocabulary throughout, and respect any ADRs in the area being touched.

<plan-template>

## TL;DR

A fast, human-first digest of the whole plan — written so a reader grasps it at a glance. Three or four tight bullets, leading with the outcome and dropping the jargon:

- **What** — what's being built, in one line.
- **Why** — the outcome it unlocks or the problem it kills.
- **How** — the shape of the approach, not the steps.
- **Scope/risk** — anything a reader must know up front (a big trade-off, a blast radius, a hard dependency). Include only when material.

## Goal

The problem and the solution in 1–3 lines, from the user's perspective. What does this let someone do that they couldn't before?

## Requirements

A short, numbered checklist of what must be true once the work ships — observable outcomes, not implementation steps. Keep each item testable and keep the list tight (cover the feature, don't enumerate every conceivable case).

1. <As an actor, I can …> / <The system does … when …>

## Module Map

The heart of the plan: the modules to build or modify, each described by its **interface** — everything a caller must know to use it (operations, key types, invariants, error modes, ordering). The interface is the test surface; design it before the implementation.

For each module:

- **Module** — its name, in domain-glossary vocabulary.
- **Interface** — what callers depend on. Describe the contract, not the code.
- **Depth** — one line on the deletion test: if this module vanished, what complexity reappears across its callers? A deep module concentrates a lot behind a small interface. If a module is deliberately shallow, say why it still earns its seam.

## Key Decisions

The load-bearing choices that constrain implementation, each as `<decision>: <rationale>`. Include only what shapes the work: schema changes, API contracts, architectural decisions, a developer's clarification, an existing pattern being mirrored. Respect documented ADRs; flag and justify any decision that reopens one.

## Testing Strategy

Which modules get tested and the behaviors to verify *through their public interface* — a good test reads like a specification and survives an internal refactor. Name the behaviors that matter (critical paths, complex logic), not every edge case. Cite prior art: similar tests already in the codebase to mirror.

## Out of Scope

Include when scope is contested or there are tempting non-goals worth pinning. What this plan deliberately does not do.

## Notes & Sources

Include when material. Research URLs and library gotchas (the *why*, not just the *what*), and any open questions that block implementation.

</plan-template>
