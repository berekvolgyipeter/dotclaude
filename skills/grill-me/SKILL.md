---
name: grill-me
description: Grilling session that challenges your plan or design until we reach a shared understanding — sharpening terminology against the project's glossary and recording decisions in its domain docs as they crystallise. Use when user wants to stress-test a plan or design, or settle its language and decisions.
---

<what-to-do>

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.

Open with two questions, asked together: the domain-docs question in section 2 of `~/.claude/shared/domain-docs.md`, and the goal behind the plan. Check each later decision against the goal.

Read `~/.claude/shared/meet-the-user.md` and follow it for how you explain and ask. Follow `~/.claude/shared/domain-docs.md` for where the glossary and ADRs live and how to write them.

</what-to-do>

<supporting-info>

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in the glossary, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

</supporting-info>
