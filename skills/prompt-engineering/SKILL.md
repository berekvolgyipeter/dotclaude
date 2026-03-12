---
name: prompt-engineering
description: "Expert prompt engineering guidance with proven techniques and anti-patterns. Invoke this skill whenever writing, editing, reviewing, or refining any prompt that will be interpreted by an AI model — system prompts, agent instructions, tool-use prompts, command templates, multi-step task prompts, or agentic workflows. Use it even when the task doesn't explicitly mention 'prompt engineering' — if the output is instructions for an AI, this skill makes them significantly better. Trigger for both user-requested prompt work and when autonomously generating prompts as part of a larger task (e.g. creating skills, writing agent instructions, drafting review templates)."
allowed-tools:
  - "Bash(bash ~/.claude/skills/prompt-engineering/scripts/fetch-prompt-engineering-urls.sh)"
  - "WebFetch(https://platform.claude.com/docs/en/build-with-claude/prompt-engineering*)"
---

# Prompt Engineering

## Start here: what are you doing?

| Task | Go to |
|------|-------|
| Writing a prompt from scratch | [Crafting prompts](#crafting-prompts) |
| Reviewing or debugging an existing prompt | [Prompt review checklist](#prompt-review-checklist) |
| Building an agentic system or multi-step workflow | [Agentic prompt patterns](#agentic-prompt-patterns) |
| Need deeper detail on a specific technique | [Reference docs](#going-deeper) → WebFetch the relevant section |

## Crafting prompts

**The one principle that matters most:** explain *why*, not just *what*. Claude reasons better with context than rigid rules. Instead of `NEVER use ellipses`, write `Your response will be read aloud by a text-to-speech engine, so never use ellipses since the TTS engine can't pronounce them.` Claude generalizes from the reasoning.

**Structure for any non-trivial prompt:**
1. Role/context — who is Claude, what's the situation
2. Input — wrapped in descriptive XML tags (`<code>`, `<document>`, `<query>`)
3. Task — what to do, with success criteria
4. Output format — show one concrete example rather than describing the format in prose
5. Use `{{variables}}` for dynamic content to make prompts reusable and testable

**When adding examples (few-shot):** use 3–5 diverse examples wrapped in `<example>` tags. Cover edge cases. Ask yourself: would a pattern-matcher pick up unintended shortcuts from these examples?

## Prompt review checklist

Run through this when reviewing or debugging a prompt:

- [ ] **Over-constraining?** — Too many MUST/NEVER/ALWAYS makes prompts brittle. If you see a wall of rigid rules, rewrite them as reasoned guidance. One explained rationale outperforms five shouted commands.
- [ ] **Kitchen-sink?** — If the prompt handles discovery, analysis, and output in one block, break it into a chain. Each stage should have a clear input and output.
- [ ] **Missing examples?** — One concrete input/output example beats a paragraph of format description. If the prompt describes a format without showing it, add an example.
- [ ] **Telling what NOT to do?** — Reframe as positive instructions. "Don't use markdown" → "Write in flowing prose paragraphs." Claude steers better toward a destination than away from one.
- [ ] **Leftover aggressive language from older models?** — Phrases like "CRITICAL: You MUST use this tool" or "If in doubt, use [tool]" cause overtriggering on current Claude models. Dial back to normal phrasing: "Use this tool when..."
- [ ] **Prefills on the last assistant turn?** — Deprecated in Claude 4.6. Use direct instructions, structured outputs, or XML output tags instead. See the migration patterns in the [best practices doc](#going-deeper).
- [ ] **Vague action language?** — "Can you suggest changes?" makes Claude suggest rather than act. "Change this function to..." makes it act. Be explicit about whether you want analysis or action.

## Agentic prompt patterns

These are the non-obvious patterns from the official docs — things Claude wouldn't do by default without guidance.

**Autonomy/safety balance** — Without guidance, agents may take hard-to-reverse actions (deleting files, force-pushing, posting externally). Add a principle like: "Take local, reversible actions freely. For destructive or externally-visible actions, confirm first." List specific examples of what warrants confirmation.

**Subagent orchestration** — Current Claude models proactively spawn subagents. Watch for overuse: the model may spawn a subagent for a task that a single grep could handle. Add guidance: "Use subagents for parallel, independent workstreams. For simple tasks, sequential operations, or single-file edits, work directly."

**Overthinking and over-exploration** — Current models do significantly more upfront exploration than predecessors. If your prompt previously encouraged thoroughness ("always explore before acting", "when in doubt, research more"), dial it back. Replace blanket defaults ("Default to using [tool]") with targeted ones ("Use [tool] when it would enhance your understanding").

**Long-horizon state tracking** — For tasks spanning multiple context windows:
- First window: set up framework (tests, scripts, structured state files)
- Subsequent windows: iterate on a todo-list, discover state from filesystem and git
- Use structured formats (JSON) for status tracking, freeform text for progress notes
- Encourage git usage for state checkpoints

**Overeagerness / overengineering** — Current models tend to create extra files, add unnecessary abstractions, or build in unrequested flexibility. Counter with: "Only make changes that are directly requested or clearly necessary. The right amount of complexity is the minimum needed for the current task."

**Minimizing hallucinations in agentic coding** — Add: "Never speculate about code you haven't read. If a file is referenced, read it before answering."

## Going deeper

For technique-specific detail, consult [references/reference.md](references/reference.md) for URLs and a section-by-section map of what to WebFetch and when.
