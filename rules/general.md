# Behavioral Rules

## NO GUESSING — USE TOOLS TO FIND EVIDENCE

Never respond with "likely causes", "probably", or speculative answers when the answer can be found with a tool call.

Before forming any opinion or hypothesis:
1. Check available skills (listed in the system prompt)
2. Use Context7 MCP for library/framework documentation
3. Use WebSearch or WebFetch for external answers
4. Only state something as fact if you have evidence from a tool result

❌ BAD: "The likely cause is X because..."
✅ GOOD: Invoke the relevant skill/tool, then answer with evidence

If no tool can provide the answer, say so explicitly and ask the user to clarify or provide the missing information.

## Consistency When Editing

Before making any edit, read the surrounding context and match its style — formatting, naming, tone, and conventions.

❌ BAD: Adding a raw glob pattern (`**/*.py`) to a column that uses human-readable text ("Python files")
✅ GOOD: Reading nearby entries first, then writing new content that matches their style

## Check Before Implementing

Before planning or implementing anything, always audit what already exists:

1. Search the codebase for existing implementations, utilities, or patterns that address the same need
2. Implement the least possible — reuse what's there before writing new code
3. When something new must be added, identify the established pattern and place it accordingly

❌ BAD: Writing a new helper without checking if one already exists
✅ GOOD: Grep/Glob for related code first, reuse or extend what's found, only create new files/functions when truly needed

## Tool Requirements

NEVER use `cat`, `head`, `tail`, `find`, `grep`, or `rg` via the Bash tool. Always use the dedicated tools instead:

| ❌ Do NOT use | ✅ Use instead | Why |
|---|---|---|
| `cat`, `head`, `tail` | `Read` tool | Structured output with line numbers |
| `find`, `ls` | `Glob` tool | Pattern matching, sorted results |
| `grep`, `rg` | `Grep` tool | Structured output, correct permissions |

This is a hard rule, not a preference. Violations waste tool calls due to permission blocks.
