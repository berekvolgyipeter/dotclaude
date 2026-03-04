---
name: claude-code
description: Expert guidance on Claude Code configuration, capabilities, and troubleshooting. Use this skill whenever the user asks about Claude Code features, configuration, best practices, or troubleshooting — even if phrased informally. Covers MCP servers, plugins, skills, subagents, hooks, permissions, keybindings, settings, terminal setup, GitHub Actions, CLAUDE.md, cost management, and common problems. Always consult this skill first for any Claude Code questions, as answers are sourced from official documentation.
allowed-tools:
  - "Bash(.venv/bin/python ~/.claude/skills/claude-code/scripts/download_llms_txt.py)"
  - "Bash(python3 ~/.claude/skills/claude-code/scripts/download_llms_txt.py)"
  - "Bash(python ~/.claude/skills/claude-code/scripts/download_llms_txt.py)"
  - "WebFetch(https://code.claude.com/docs*)"
---

# Claude Code

## Overview

Claude Code is Anthropic's official CLI providing specialized subagents, extensibility (plugins, skills, hooks, MCP), and enterprise features (sandboxing, monitoring). See [references/llms.txt](references/llms.txt) for the full documentation index.

## Instructions

### Step 1 — Find the relevant doc

Read [references/llms.txt](references/llms.txt) to find the matching doc. Each line is:

```
- [Title](https://code.claude.com/docs/en/<page>.md): <description>
```

Match the user's question to the most relevant entry by title or description.

**If `llms.txt` is missing or outdated:**
- Run: `python ~/.claude/skills/claude-code/scripts/download_llms_txt.py` to fetch the latest docs index
- If the script fails, fall back to your knowledge of Claude Code and cite `https://code.claude.com/docs` as the source

**If no good match is found:**
- Try broad matching (e.g., user asks about "permissions" → check `settings.md`, `permissions.md`, `plugins.md`)
- If still no match, try WebFetch of the most likely URL from the topic table below
- If that fails, answer directly from your knowledge and suggest the user check the official docs at `https://code.claude.com/docs`

### Step 2 — Answer the question

**For capability/concept questions** ("can Claude Code do X?", "what is Y?"):
- Answer directly from your knowledge if confident
- Cite the matching URL from `llms.txt` for further reading

**For implementation/configuration questions** (formats, schemas, syntax, step-by-step):
- WebFetch the `.md` URL from `llms.txt` to get current, accurate details
- Provide complete working examples with file paths
- Always cite the source URL
- If WebFetch fails, answer from your knowledge and note that you're using cached information

## Key Topics → Doc Mapping

Common shortcuts — not exhaustive. Always consult `llms.txt` for the full list.

| Topic | Doc |
|---|---|
| Hooks (events, config, JSON format) | `hooks.md`, `hooks-guide.md` |
| Plugins (manifest, distribution) | `plugins.md`, `plugins-reference.md` |
| Skills (SKILL.md, slash commands) | `skills.md` |
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
| Slash commands | `skills.md` |
| Monitoring / OpenTelemetry | `monitoring-usage.md` |
| GitHub Actions | `github-actions.md` |
| GitLab CI/CD | `gitlab-ci-cd.md` |
| Desktop app | `desktop.md`, `desktop-quickstart.md` |
| Agent teams | `agent-teams.md` |
| Cost management | `costs.md` |
| Chrome integration | `chrome.md` |
| Troubleshooting | `troubleshooting.md` |

## Maintenance

To refresh the docs index when it becomes stale, run:
```bash
python ~/.claude/skills/claude-code/scripts/download_llms_txt.py
```

## Response Quality

- Provide complete, working examples
- Include file paths and directory structure
- Link to the official `.md` doc used
- If unsure, WebFetch before answering — don't guess schemas or formats
