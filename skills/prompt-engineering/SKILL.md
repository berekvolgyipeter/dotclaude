---
name: prompt-engineering
description: Expert guidance for crafting and optimizing prompts for AI agents. Use WHENEVER the user mentions writing, improving, or debugging prompts — including system prompts, agent instructions, tool-use prompts, or multi-step task prompts. Also use when the user asks about specific techniques like chain of thought, XML tags, few-shot examples, prompt chaining, response prefilling, or long context strategies — even if they don't say "prompt engineering" explicitly.
allowed-tools:
  - "Bash(bash .claude/skills/prompt-engineering/scripts/fetch_prompt_engineering_urls.sh)"
  - "WebFetch(https://platform.claude.com/docs/en/build-with-claude/prompt-engineering*)"
---

# Prompt Engineering

## Technique Reference

All prompt engineering techniques with URLs and usage guidance: [references/reference.md](references/reference.md)

For deeper detail on any technique, WebFetch from the three available documentation pages listed in the reference.

## Technique Selection

Pick the right technique for the problem:

| Problem | Technique |
|---------|-----------|
| Claude misunderstands the task | Be clear and direct — add context, constraints, success criteria |
| Output format is inconsistent | XML tags — structure input/output with tagged sections |
| Reasoning errors or skipped steps | Chain of thought — ask Claude to think step by step |
| Need consistent style or format | Few-shot examples — show 2-3 input/output pairs |
| Task too complex for one prompt | Prompt chaining — break into sequential stages |
| Need specific persona or expertise | System prompt — establish role and domain knowledge |
| Processing large documents | Long context — place documents before the query |
| Want to steer output start | Response prefilling — pre-fill the assistant turn |

When in doubt, start with clear instructions + XML tags. Add techniques one at a time and measure impact.

## Workflow

**Creating prompts:**
1. Start clear and direct with context and success criteria
2. Add XML tags for multi-part structure
3. Use templates with `{{variables}}` for reusability
4. Use the prompt generator tool to bootstrap from a task description

**Optimizing prompts:**
1. Read [references/reference.md](references/reference.md) to identify applicable techniques
2. WebFetch specific technique documentation as needed
3. Test incrementally: one technique at a time
4. Measure: accuracy, consistency, latency, cost

**Example — before/after optimization:**

Before (vague, no structure):
```
Review this code for issues.
```

After (clear role, structured output, chain of thought):
```xml
<system>You are a senior code reviewer. Think step by step.</system>

<code>{{source_code}}</code>

Review the code above for bugs, security issues, and maintainability problems.

For each finding:
1. Reason through why this is a problem
2. Classify severity: Critical / High / Medium / Low / Informational

<output_format>
## [Severity] Title
**Location**: function name and line
**Description**: what the issue is
**Impact**: what could go wrong
**Recommendation**: how to fix it
</output_format>
```

## Common Anti-Patterns

- **Over-constraining**: Too many MUST/NEVER/ALWAYS directives make prompts brittle. Explain the *why* instead — Claude reasons better with context than rigid rules
- **Kitchen-sink prompts**: Cramming everything into one prompt. If a task has distinct phases (scan, analyze, report), chain separate prompts instead
- **No examples**: Telling Claude what format you want without showing it. One concrete example beats a paragraph of description
- **Premature optimization**: Adding advanced techniques before the basic prompt is solid. Get clear instructions right first

## Agentic Prompt Patterns

**System prompts** — Establish the agent persona:
- Define the agent's role, expertise level, and focus areas
- Include scope boundaries (what's in and out of scope)
- Set the output standard (format, required fields, severity scales)

**Prompt chaining for multi-phase tasks:**
1. **Discovery phase**: Gather inputs, identify relevant context
2. **Analysis phase**: Feed discovery results into deeper reasoning
3. **Output phase**: Structure findings into a final deliverable

**XML tags for structured I/O:**
- Wrap inputs in descriptive tags (e.g. `<input>`, `<context>`, `<source>`)
- Use output tags for parseable results (e.g. `<findings>`, `<recommendation>`)
- Use attributes to disambiguate multiple inputs: `<source name="...">`

**Long context strategies:**
- Place reference material and source documents before the query
- For multi-document tasks, include an index/summary first, then full content
