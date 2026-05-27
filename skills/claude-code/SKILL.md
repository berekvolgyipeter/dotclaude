---
name: claude-code
description: Expert guidance on Claude Code configuration, capabilities, and troubleshooting. Use this skill whenever the user asks about Claude Code features, configuration, best practices, or troubleshooting — even if phrased informally. Covers MCP servers, plugins, skills, subagents, hooks, permissions, keybindings, settings, terminal setup, GitHub Actions, CLAUDE.md, cost management, and common problems. Answers are sourced from official Claude Code product documentation.
allowed-tools:
  - "Bash(bash ~/.claude/skills/claude-code/scripts/fetch-claude-code-urls.sh*)"
  - "WebFetch(https://code.claude.com/docs*)"
---

# Claude Code

## Overview

Claude Code is Anthropic's official CLI providing specialized subagents, extensibility (plugins, skills, hooks, MCP), and enterprise features (sandboxing, monitoring). See [references/claude-code-urls.md](references/claude-code-urls.md) for the full documentation index.

## Instructions

### Step 0 — Refresh the doc index when fetching docs

If you need to consult the official docs to answer (i.e. you'll hit step 1 or step 2 below), run `bash ~/.claude/skills/claude-code/scripts/fetch-claude-code-urls.sh` first to rewrite `references/claude-code-urls.md` from Anthropic's current `llms.txt`. Skip the refresh for purely conceptual answers or when the existing snapshot is sufficient.

### Step 1 — Find the relevant doc

Read [references/claude-code-urls.md](references/claude-code-urls.md) to find the matching doc. Each line is:

```
- [Title](https://code.claude.com/docs/en/<page>.md): <description>
```

Match the user's question to the most relevant entry by title or description.

**If no good match is found:**
- Try broad matching (e.g., user asks about "permissions" → check `settings.md`, `permissions.md`, `plugins.md`)
- If still no match, try WebFetch of the most likely URL from the topic table below
- If that fails, answer directly from your knowledge and suggest the user check the official docs at `https://code.claude.com/docs`

### Step 2 — Answer the question

**For capability/concept questions** ("can Claude Code do X?", "what is Y?"):
- Answer directly from your knowledge if confident
- Cite the matching URL from `claude-code-urls.md` for further reading

**For implementation/configuration questions** (formats, schemas, syntax, step-by-step):
- WebFetch the `.md` URL from `claude-code-urls.md` to get current, accurate details
- Provide complete working examples with file paths
- Always cite the source URL
- If WebFetch fails, answer from your knowledge and note that you're using cached information

## Key Topics → Doc Mapping

Common shortcuts — not exhaustive. Always consult `claude-code-urls.md` for the full list.

| Topic | Doc |
|---|---|
| Hooks (events, config, JSON format) | `hooks.md`, `hooks-guide.md` |
| Plugins (manifest, distribution) | `plugins.md`, `plugins-reference.md` |
| Skills & slash commands | `skills.md` |
| Subagents | `sub-agents.md` |
| MCP servers | `mcp.md` |
| Settings & permissions | `settings.md`, `permissions.md` |
| Headless / SDK / programmatic | `headless.md` |
| Sandboxing | `sandboxing.md` |
| Memory (CLAUDE.md) | `memory.md` |
| Terminal setup | `terminal-config.md` |
| Model selection | `model-config.md` |
| Status line | `statusline.md` |
| CLI flags | `cli-reference.md` |
| Monitoring / OpenTelemetry | `monitoring-usage.md` |
| GitHub Actions | `github-actions.md` |
| GitLab CI/CD | `gitlab-ci-cd.md` |
| Desktop app | `desktop.md`, `desktop-quickstart.md` |
| Agent teams | `agent-teams.md` |
| Cost management | `costs.md` |
| Chrome integration | `chrome.md` |
| Troubleshooting | `troubleshooting.md` |

## Response Quality

- Provide complete, working examples
- Include file paths and directory structure
- Link to the official `.md` doc used
- If unsure, WebFetch before answering — don't guess schemas or formats
