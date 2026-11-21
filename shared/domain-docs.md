## Domain Docs

The project's lasting record of its vocabulary (the glossary) and its hard-to-reverse decisions (ADRs): where they live, when to write them, and their formats.

### 1. Where they live

Most repos have a single context:

```
/
├── GLOSSARY.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `GLOSSARY-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── GLOSSARY-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── GLOSSARY.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── GLOSSARY.md
│       └── docs/adr/
```

When multiple contexts exist, infer which one the current topic relates to. If unclear, ask.

### 2. When to write

- **Ask once, at the start.** Before any other work in a session that may settle terms or decisions, ask one question: should this session record settled terms in the glossary and hard-to-reverse decisions as ADRs? Say which of the two the project already keeps (section 1), and recommend yes for each it keeps. The answer holds for the whole session — never ask about domain docs again mid-session, so the session can run to the end unattended.
- **Yes** → update the glossary inline as each term settles (don't batch), and write an ADR for each decision that passes the test in section 4, creating `GLOSSARY.md` or `docs/adr/` when missing. **No** → write neither.
- **The glossary is a glossary and nothing else** — no implementation details, not a spec or a scratch pad.

### 3. Glossary format

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

## Example dialogue

> **Dev:** When a customer places an **Order**, do they get an **Invoice** right away?
> **Domain expert:** No — the **Invoice** goes out only after delivery.

## Flagged ambiguities

- "account" was used for both **Customer** and **User**. Resolved: these are distinct concepts.
```

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- **Flag conflicts explicitly.** If a term is used ambiguously, call it out under "Flagged ambiguities" with a clear resolution; leave the section out when there are none.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Show relationships.** Use bold term names and express cardinality where obvious.
- **Only terms specific to this project's context.** General programming concepts (timeouts, error types, utility patterns) don't belong even if the project uses them extensively.
- **Group terms under subheadings** when natural clusters emerge; a flat list is fine for one cohesive area.
- **Write an example dialogue** between a dev and a domain expert that shows how the terms interact and where related concepts part.

A `GLOSSARY-MAP.md` lists the contexts, where they live, and how they relate:

```md
# Glossary Map

## Contexts

- [Ordering](./src/ordering/GLOSSARY.md) — receives and tracks customer orders
- [Billing](./src/billing/GLOSSARY.md) — generates invoices and processes payments

## Relationships

- **Ordering → Billing**: Ordering emits `OrderPlaced` events; Billing consumes them to generate invoices
```

### 4. ADRs

**Write one only when all three are true:**

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why on earth did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

What qualifies: architectural shape, integration patterns between contexts, technology choices that carry lock-in, boundary and scope decisions (the explicit no-s too), deliberate deviations from the obvious path, constraints not visible in the code, and rejected alternatives when the rejection is non-obvious.

**Format** — sequentially numbered files in `docs/adr/` (`0001-slug.md`; next number = highest existing + 1):

```md
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

An ADR can be a single paragraph: the value is recording *that* a decision was made and *why*. Add these only when they earn their place: **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`), **Considered Options**, **Consequences**.
