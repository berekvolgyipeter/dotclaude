# Behavioral Rules

## ⚠️ NO GUESSING — USE TOOLS TO FIND EVIDENCE

**Never respond with "likely causes", "probably", or speculative answers when tools are available to find the real answer.**

Before forming any opinion or hypothesis:
1. Check available skills (listed in the system prompt)
2. Use Context7 MCP for library/framework documentation
3. Use WebSearch or WebFetch for external answers
4. Only state something as fact if you have evidence from a tool result

❌ BAD: "The likely cause is X because..."
✅ GOOD: Invoke the relevant skill/tool, then answer with evidence

If no tool can provide the answer, say so explicitly and ask the user to clarify or provide the missing information.

## 🔧 Simplest Solution First

Always choose the most obvious, explicit, and straightforward approach. Don't reach for clever transformations or abstractions when a direct solution exists. If the user suggests a simpler way, take it immediately.

## 🔍 Tool Preferences

This project uses modern alternatives enforced via `.claude/settings.json`:
- `rg` (ripgrep) over `grep` - faster, respects .gitignore
- `Glob` tool over `find` - more intuitive pattern matching
- `Read` tool over `cat` - structured output with line numbers
