# Prompt Engineering Reference

Comprehensive documentation for prompt engineering techniques with Claude.

Each section below contains:
- A link to the official documentation
- A summary of what the section covers
- Guidance on when to use that particular feature

## [Overview](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview.md)

Introduces prompt engineering as an iterative practice for improving Claude's responses without model modification, covering prerequisites (defined success criteria, empirical testing methods, an initial draft prompt), advantages over fine-tuning (resource efficiency, cost savings, faster iteration, no retraining when models update, minimal data needs, preserved general knowledge, and human-readable transparency), and a recommended progression of nine techniques ordered from most to least broadly effective: prompt generator, clear instructions, multishot examples, chain of thought, XML tags, system prompts, response prefilling, prompt chaining, and long context strategies.

Use this when getting oriented on prompt engineering fundamentals, deciding whether to prompt-engineer vs. fine-tune, establishing evaluation criteria before starting optimization, or planning which techniques to try in sequence for a given use case.

## [Console prompting tools](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-tools.md)

Covers three tools in the Claude Console designed to be used in sequence: the **prompt generator**, which creates high-quality prompt templates from a task description to solve the blank-page problem; **prompt templates and variables**, which combine static instructions with `{{double bracket}}` placeholders for dynamic content (user inputs, RAG content, conversation history, tool results) to enable consistency, testability, and version control; and the **prompt improver**, which takes an existing template through a four-step automated process (example identification, initial draft, chain-of-thought refinement, example enhancement) to produce structured templates with explicit reasoning steps, XML tags, and standardized examples — at the cost of longer, slower responses.

Use this when starting a new prompt from scratch (generator), building reusable prompts with dynamic inputs (templates/variables), or needing to substantially improve accuracy on a complex task where latency and cost are secondary concerns (improver).

## [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.md)

Provides model-specific guidance for the latest Claude models (Opus, Sonnet, Haiku), covering general principles (be explicit rather than implicit, add motivating context behind instructions, use careful examples) and targeted advice for specific situations: balancing verbosity, steering tool-use behavior from suggestive to imperative phrasing, managing autonomy vs. safety for irreversible actions, reducing overthinking/overtriggering, controlling output formatting via positive instructions and XML tags, structuring complex research tasks, tuning subagent orchestration, leveraging adaptive thinking (the `effort` parameter), improving vision and parallel tool-call performance, preventing overengineering and test-hardcoding, avoiding hallucinations in agentic coding, suppressing LaTeX output, and multi-context-window state management with structured files and git.

Use this when tuning prompts for the latest Claude models, migrating from earlier Claude generations, debugging unexpected behaviors (overtriggering, overengineering, excessive thinking, bad formatting), or building agentic/long-horizon workflows that need precise control over autonomy, tool use, and state tracking.
