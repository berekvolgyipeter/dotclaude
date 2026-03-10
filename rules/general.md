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

## Tool Preferences

Prefer these tools in all projects:
- `Glob` tool over `find` — more intuitive pattern matching
- `Grep` tool over `rg`/`grep` — structured output, correct permissions
- `Read` tool over `cat` — structured output with line numbers
