---
name: design-change
description: Design session for changing an existing (brownfield) system — turns a rough change idea into a sound, evidence-checked design the user fully understands, written down as plain-language design docs, before any implementation plan exists. Explains the current system, discusses the design one question at a time, then critiques its own design in a loop (goal met? weak spots? side effects? simpler alternative? premises true in the code?) until no open question is left. Use whenever the user wants to understand an existing system and decide how to change it before planning, asks for a "design doc", a "design doc in simple words", "explain it to me like a junior", or wants to stress-test a design across several repos or services — even if they don't name this skill. Not for greenfield projects with no code yet.
---

# Design Change

Drive a change from "I have an idea" to "the design is sound, checked against the code, and I understand every part
of it". The deliverable is one plain-language **design doc** per component the change touches, plus an **evidence**
file with the implementation facts, ready for whoever writes the implementation plan.

Write them where the conversation already keeps this work: a folder named or used in the conversation. If there is
none, create one change folder, named and laid out as the Change folder section of
`~/.claude/shared/planning-context.md` says.

The user should not have to be the critic. Every round, you do the criticism they would otherwise do: check the facts,
find the weak spots, question your own design, and offer a simpler one when it exists.

## The reader

Two readers, and they change differently over the session:

- **The user in chat.** Read `~/.claude/shared/meet-the-user.md` and follow it throughout the session.
- **The design doc's reader.** Always a human with no context — a junior developer or a teammate. This does not rise
  with the user's level: the design doc is written for people who were not in the conversation.

## How to answer in chat

- Answer first, then the support. Short. Bullets for three or more parallel points.
- When several questions are open, list them once, then take them one by one: ask a question only once the decisions
  it depends on are settled.
- Every factual claim comes from a tool result: code, docs, logs, data. Cite `file:line` in chat. If no tool can
  answer, say so and name who can (a person, a deployment, a measurement).
- Push back when the evidence says the user is wrong, with the evidence. When the user decides a trade-off, accept it,
  record it, and stop arguing it.
- When the user asks "are you sure?", re-check instead of defending: name what is verified and what is not.

## The loop

### 1. Understand the ask and the current system

Open with two questions, asked together: the domain-docs question in section 2 of
`~/.claude/shared/domain-docs.md`, and the goal behind the ask — what the user wants to be true once the change is
done, not only what they asked for, confirmed in one line. Every later step is judged against the goal.

Read the relevant code and docs, and follow the Glossary and ADRs section of
`~/.claude/shared/planning-context.md`; a recorded decision stays settled unless the user reopens it. Explain how
things work **today** before proposing anything: the user needs the current system in their head to judge a change.
Find the root cause of the problem, not only the symptom the user named — the best fix is often in another component
than the one the user started from.

### 2. Discuss the design

- Prefer what already exists: an existing mechanism, queue, setting or pattern beats a new one.
- Fix at the root cause, in the component that owns the problem, over a workaround in the caller.
- Look at how a well-known system solves the same problem (for example Claude / Anthropic's API, Kubernetes, a
  standard protocol) and say what to take from it and what not.
- Leave nothing open that an educated guess can close: give every value a default, say it is a guess, and name the
  measurement that would replace it.
- When the code cannot answer (runtime behaviour, team knowledge), draft short questions for the person who knows,
  in the language the user uses with them, and treat the answers as input to check, not as facts.

### 3. Write the design docs

Write when the user asks, or when the design has settled enough that writing it down helps. One design doc and one
evidence file per repo the change touches, named per the Change folder section, the design docs linked to each other.
Structure:

1. Goal (what must be true once the change is done, who it serves, what success looks like, the key constraints)
2. The pieces (a small diagram and a word table)
3. How it works today
4. The problem
5. How others do it (optional)
6. What we will change (decisions, each with its one-line why)
7. Not now (what was considered and set aside, and why)
8. What does not change
9. Open questions

Keep it for humans:

- Plain words, short sections, tables for values. No file names, line numbers, env-var internals, library internals
  or code identifiers unless the reader must type them (a CLI switch, a setting an operator sets).
- The word table defines the few terms this change's reader needs, even ones the glossary already has: copy those
  definitions from the glossary word for word. When a new domain term or a hard-to-reverse decision settles, record
  it in the domain docs only if the user said yes at the start.
- Every implementation detail found along the way goes into the evidence file of the repo it is about, with
  `file:line` evidence. Nothing found is lost; the design doc just does not carry it.
- Record each decision in the design doc when it is made, so the document is always current. Remove what a later
  decision made stale; do not leave both versions.
- When a design is dropped, move its documents to an `archived/` folder instead of deleting them.

### 4. Critique your own design — every round

After every design change, before the user has to ask, run this review and report it worst-first:

- **Goal:** what does the design achieve, and does it reach the user's actual goal? Say plainly what it does not do.
- **Weak spots:** where it breaks, under which load, input or deployment.
- **Side effects:** who else is affected — other callers of the same service, other teams, operators, monitoring,
  older clients. A change made for one caller often lands on all of them.
- **Simpler alternative:** is there a design with fewer moving parts that solves the same problem? Take it seriously;
  recommend it when it wins.
- **The fact it stands on:** name the one fact the design is safe because of and prove it — read the source, or run
  a small script — rather than listing many possible risks. A design usually fails on one unproven premise, not on
  ten listed ones.
- **Premises:** is every other "today the code does X" still true? Re-check the claims the design leans on.
- **Premortem:** "It is six months later and this failed. Why?" Name the most likely cause and the smallest check
  that would catch it now.
- **Coupling:** does it tie components' settings or behaviour together more than needed?
- **Architecture:** once, in the first round after the design has settled, invoke `improve-codebase-architecture` in
  scoped mode on the components the design touches, and treat its deepening opportunities as findings of that round.

For each finding give a fix and a recommendation. Let the user decide; record the decision; update the design doc.
Repeat until a round finds nothing worth fixing and the open-questions section is empty.

**Stop after three rounds** that each still find substantive issues. Hand the situation to the user instead of
looping: the design may be too big for one change and want splitting, or a trade-off needs their call.

### 5. Validate against the code

When the user asks, or before calling the design done: hand the design doc to an **independent subagent** with the
repo paths and ask it to check first whether the design reaches its stated goal, then fact-check every claim about
today's behaviour and every premise of each proposal, with `file:line` evidence, adversarially ("assume the author
is overconfident; do not validate"). Give it the design, its
constraints and any evidence against it — never your reasoning or conclusions: an unanchored reader finds what you
missed.

Sort each finding before acting on it:

- **misread** — the validator got the design wrong: no change, but check whether the design doc invited the
  misreading;
- **actionable** — a wrong or imprecise claim, or a broken premise: fix the design doc if it changes meaning,
  otherwise record it in the evidence file;
- **trade-off** — true, but already accepted: no change;
- **noise** — no change.

If two validation rounds bring findings but nothing actionable, stop validating.

### 6. Hand off

The design is ready when the design docs have no open questions, the last critique round found nothing to fix and the
validation is applied. Then check understanding: write back a short summary — goal, who it serves, what success
looks like, the key constraints, what is out of scope — and ask the user to confirm it. Only an explicit "yes"
counts; "sounds good" or "whatever you think" means something is still unclear, so ask which part. Write the
confirmed summary into each design doc's Goal section, so later stages read it there. The session ends there: the
design docs and the evidence file are the deliverable.

## Working practices

- Use subagents for wide searches, log or data mining and fact-checks, so the conversation keeps the conclusions, not
  the dumps. Brief them fully; they have no context.
