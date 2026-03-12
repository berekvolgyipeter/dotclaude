# Prompt Engineering — Documentation Map

Quick-reference for navigating the official prompt engineering docs. Use this to find the right section to WebFetch when you need deeper detail.

## Best Practices (the main reference)

URL: `https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.md`

This is the single most useful page. It covers model-specific guidance for the latest Claude models. Sections:

| Section | What it covers | Fetch when... |
|---------|---------------|---------------|
| General principles | Clarity, context, examples, XML tags, roles, long context | Writing a prompt from scratch |
| Output and formatting | Verbosity control, markdown steering, LaTeX handling, prefill migration | Output doesn't look right |
| Tool use | Action vs. suggestion phrasing, parallel tool calling, explicit direction | Prompt involves tool use |
| Thinking and reasoning | Adaptive thinking, overthinking/overtriggering, effort parameter, interleaved thinking | Tuning reasoning behavior or migrating thinking config |
| Agentic systems | Long-horizon state tracking, autonomy/safety, subagent orchestration, research patterns, overeagerness, hallucination prevention | Building agent prompts or multi-step workflows |
| Capability-specific tips | Vision improvements, crop tool, frontend design aesthetics | Working with images or UI generation |
| Migration considerations | Claude 4.6 changes, effort settings, prefill deprecation | Updating prompts from older models |

## Overview

URL: `https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview.md`

Lightweight intro page. Covers prerequisites (success criteria, testing, first draft), when prompt engineering is the right approach vs. model selection, and links to the interactive tutorials. Fetch only if someone is brand new to prompt engineering.

## Console Prompting Tools

URL: `https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-tools.md`

Covers three Console-specific tools: prompt generator (bootstraps templates from task descriptions), prompt templates with `{{variables}}`, and prompt improver (4-step automated refinement). These are Console/API tools, not available in Claude Code directly — but the patterns they use (structured templates, chain-of-thought refinement, example enhancement) are applicable anywhere.
