# Behavioral Rules

## Do Only What Is Requested

Do exactly what was asked — no extra items, files, or changes. Quantity and scope come from the request.

❌ BAD: Asked to "add a trivia", adding three related bullets
✅ GOOD: Adding the one bullet asked for; offering more in one line if useful

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

## Dedicated File Tools Over Bash

Read, edit and create files with the Read, Edit and Write tools — never with `cat`, `head`, `tail`, `sed`, `awk`, `echo` or heredocs, even when the harness allows Bash for file work. Bash is for running commands and for searching with `grep` and `find`.

❌ BAD: `cat notes.md` to read, `cat >> notes.md <<'EOF'` to append
✅ GOOD: Read `notes.md`, then Edit it to add the line

## Check Before Implementing

Before planning or implementing anything, always audit what already exists:

1. Search the codebase for existing implementations, utilities, or patterns that address the same need
2. Implement the least possible — reuse what's there before writing new code
3. When something new must be added, identify the established pattern and place it accordingly

❌ BAD: Writing a new helper without checking if one already exists
✅ GOOD: `grep`/`find` for related code first, reuse or extend what's found, only create new files/functions when truly needed

## Keep Documentation Up-to-Date

Before finishing any change to behavior, interfaces, configuration, or dependencies, grep the repo's docs (README, `docs/`, CLAUDE.md) for the names you changed and fix every stale mention. Do not wait to be asked. When the change touches many docs, delegate to the `documentation-manager` agent with the list of changed files.

Treat documentation as part of the work, not an afterthought: READMEs, inline docs, and other project docs must always reflect the current state of the code.

❌ BAD: Finishing a feature and moving on, leaving the README describing the old behavior
✅ GOOD: Grepping the docs for the renamed flag and updating the README section that still shows the old one

## Rules Awareness

When the user asks about rules, coding standards, or conventions — list `~/.claude/rules/` for user-level rules, and check `.claude/rules/` and `.claude/CLAUDE.md` in the current project for project-level rules. Use each rule's filename, H1 and `paths:` frontmatter to identify which rules are relevant, then read and answer from those files. Do not guess at rule content from memory.
