# Plan Template

The shape of a plan saved in a change folder — one plan per repo.

Two rules govern the whole document:

- **Sections earn their place.** Keep a section only if this plan has real content for it. A section padded with placeholder prose is worse than an absent one. Every plan opens with TL;DR, Goal, Requirements, and Module Map — these are the floor; the rest appear when material.
- **No file paths, no stale code.** Paths and snippets rot fast. Two exceptions: the origin line below, and a snippet that pins a decision more precisely than prose can (a schema, type shape, state machine, or reducer). Inline such a snippet, trimmed to the decision-rich part.

Use the glossary's vocabulary throughout, and respect the ADRs in the area being touched.

When the plan builds on a design, it links the design docs for the goal, background and set-aside options instead of restating them, and carries what they don't: modules, code-level decisions, testable requirements, tests to mirror, and what the executor needs to start.

<plan-template>

**Origin:** <links to the design docs next to this plan — only when the plan builds on a design>

## TL;DR

A fast, human-first digest of the whole plan — written so a reader grasps it at a glance. Three or four tight bullets, leading with the outcome and dropping the jargon:

- **What** — what's being built, in one line.
- **Why** — the outcome it unlocks or the problem it kills.
- **How** — the shape of the approach, not the steps.
- **Scope/risk** — anything a reader must know up front (a big trade-off, a blast radius, a hard dependency). Include only when material.

## Goal

The problem and the solution in 1–3 lines, from the user's perspective. What does this let someone do that they couldn't before?

## Before You Start

Include when material. What the executor must know before writing code: the branch and what it starts from, how the work ships (one commit, one MR, several), and constraints on rollout such as older clients that must keep working or a deploy order.

## Requirements

A short, numbered checklist of what must be true once the work ships — observable outcomes, not implementation steps. Keep each item testable and keep the list tight (cover the feature, don't enumerate every conceivable case).

1. <As an actor, I can …> / <The system does … when …>

## Module Map

The heart of the plan: the modules to build or modify, each described by its **interface** — everything a caller must know to use it (operations, key types, invariants, error modes, ordering). The interface is the test surface; design it before the implementation.

For each module:

- **Module** — its name, in domain-glossary vocabulary.
- **Interface** — what callers depend on. Describe the contract, not the code.
- **Depth** — one line on the deletion test: if this module vanished, what complexity reappears across its callers? A deep module concentrates a lot behind a small interface. If a module is deliberately shallow, say why it still earns its seam.

## Phases

Include only when the work ships in several commits or MRs. One numbered line per phase: what it delivers, which phases it depends on, and that the system still works after it.

## Key Decisions

The load-bearing choices that constrain implementation, each as `<decision>: <rationale>`. Include only what shapes the work: schema changes, API contracts, architectural decisions, a developer's clarification, an existing pattern being mirrored. Respect documented ADRs; flag and justify any decision that reopens one. Link an ADR recorded for this change instead of restating it.

## Testing Strategy

Which modules get tested and the behaviors to verify *through their public interface* — a good test reads like a specification and survives an internal refactor. Name the behaviors that matter (critical paths, complex logic), not every edge case. Cite prior art: similar tests already in the codebase to mirror.

## Out of Scope

Include when scope is contested or there are tempting non-goals worth pinning. What this plan deliberately does not do.

## Notes & Sources

Include when material. Research URLs and library gotchas (the *why*, not just the *what*), and any open questions that block implementation.

## Execution Record

Left out when planning; written during execution. Each deviation from the plan with its reason, and the results of gating or manual tests.

</plan-template>
