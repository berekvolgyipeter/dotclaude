---
name: claude-agent-sdk
description: "Expert implementation guidance for the Claude Agent SDK. Use WHENEVER users mention: building AI agents, using Claude in Python, working with the SDK, creating custom tools, managing agent sessions, controlling permissions, streaming responses, integrating MCP servers, adding hooks, deploying agents, or anything Agent SDK-related. Also use for: architecture questions about multi-turn vs one-shot, deciding between query() vs ClaudeSDKClient, implementing permissions/approvals workflows, building MCP-based extensions, cost/usage tracking, session persistence, structured outputs, subagents, or any SDK feature. This skill provides implementation patterns, decision trees, and working code examples—not just documentation pointers."
allowed-tools:
  - "WebFetch(https://platform.claude.com/docs/en/agent-sdk*)"
  - "mcp__claude-context__search_code"
---

# Claude Agent SDK

## When to Use This Skill

Use this skill when:
- You're **building with the Agent SDK** in Python (one-off queries, persistent agents, multi-turn conversations)
- You need to **decide between API patterns** (e.g., `query()` vs `ClaudeSDKClient`, streaming vs buffered)
- You're **implementing features** like custom tools, session management, permissions, or hooks
- You're **architecting** agent applications (error handling, permissions, cost control, session branching)
- You want **working code examples** from real SDK code
- You need to **troubleshoot** Agent SDK issues or understand API behavior

## How to Answer SDK Questions

The SDK evolves frequently. **Do not rely solely on the patterns below** — they are stable conceptual guidance, but exact APIs may have changed. Always verify against the live source:

1. **Check official docs** for conceptual explanations: fetch from the URLs in [reference.md](references/reference.md).
2. **Search the indexed repo** for the feature in question:
   ```
   mcp__claude-context__search_code(
     path="~/.claude/skills-references/claude-agent-sdk/claude-agent-sdk-python",
     query="<feature name or concept>"
   )
   ```
3. **Browse examples** for working usage patterns:
   ```
   Glob(~/.claude/skills-references/claude-agent-sdk/claude-agent-sdk-python/examples/*.py)
   ```
4. **Read specific example files** when you find a relevant match — these are the source of truth.

## Core Concepts

These concepts are architecturally stable — the names and roles don't change, even if exact field names evolve.

### ClaudeAgentOptions — The Central Configuration Object

Almost everything in the SDK is configured through `ClaudeAgentOptions`. Key fields include:

- `system_prompt` — str or preset dict for customizing Claude's behavior
- `allowed_tools` — tool whitelist (e.g., `["Read", "Write", "Bash"]`)
- `max_turns` — limit agent turns
- `max_budget_usd` — cost cap
- `permission_mode` — `"default"` | `"acceptEdits"` | `"bypassPermissions"`
- `model` — model override
- `can_use_tool` — permission callback for dynamic allow/deny
- `hooks` — lifecycle hooks dict (`PreToolUse`, `PostToolUse`, etc.)
- `mcp_servers` — MCP server configuration dict
- `agents` — subagent definitions dict
- `cwd` — working directory

**To verify current fields**: search for `ClaudeAgentOptions` in the SDK source.

### Message Types — Processing SDK Responses

The SDK yields typed messages: `AssistantMessage`, `ResultMessage`, `UserMessage`, `SystemMessage`. Content blocks include `TextBlock`, `ToolUseBlock`, `ToolResultBlock`.

**To see the exact types and fields**: search the SDK source for these type names, or read `examples/quick_start.py` and `examples/streaming_mode.py` for handling patterns.

## Implementation Patterns

Each pattern below describes **when and why** to use an approach. For exact, up-to-date code, follow the "look up" pointer to the corresponding SDK example file.

### Pattern 1: One-Off Task — `query()`

**When**: Single task, no follow-up needed, fire-and-forget
**Why**: Simplest API — async generator that yields messages, no session management

Key shape:
- `async for message in query(prompt="...", options=ClaudeAgentOptions(...)):`
- Yields `AssistantMessage` (with `TextBlock` content) and `ResultMessage` (with cost/status)
- Without options, Claude has no tools and uses an empty system prompt

**Look up**: read `examples/quick_start.py` for basic, options, and tools usage.

### Pattern 2: Multi-Turn Conversation — `ClaudeSDKClient`

**When**: Multi-turn workflows, context preservation, interactive sessions, interrupts
**Why**: Maintains conversation history, supports streaming, session management

Key shape:
- `async with ClaudeSDKClient(options=...) as client:`
- Two-step per turn: `await client.query("...")` then `async for msg in client.receive_response():`
- Context is preserved across turns automatically

**Look up**: read `examples/streaming_mode.py` for multi-turn, concurrent, interrupt, and error handling patterns.

### Pattern 3: Streaming Partial Messages (Real-Time UI)

**When**: Chat UI, progress display, long-running tasks
**Why**: See tokens and tool calls as they happen, build real-time experiences

Key shape:
- Set `include_partial_messages=True` in `ClaudeAgentOptions`
- `StreamEvent` messages arrive interspersed with regular messages
- Known limitations with extended thinking and structured output

**Look up**: read `examples/include_partial_messages.py`.

### Pattern 4: Custom Tools via MCP (Extend Claude)

**When**: Claude needs domain-specific capabilities (APIs, business logic)
**Why**: Type-safe in-process MCP tools with the `@tool` decorator

Key shape:
- `@tool(name, description, schema)` decorator defines individual tools
- `create_sdk_mcp_server(name, version, tools=[...])` bundles them into a server
- Register via `ClaudeAgentOptions(mcp_servers={"name": server})`
- Tool names follow `mcp__<server>__<tool>` pattern for `allowed_tools`

**Look up**: read `examples/mcp_calculator.py` for a complete custom tools example.

### Pattern 5: Permission Controls (Security)

**When**: Production agents, untrusted input, approval workflows
**Why**: Prevent unintended tool use with typed allow/deny responses

Key shape:
- `ClaudeAgentOptions(can_use_tool=callback)` with typed returns (`PermissionResultAllow` / `PermissionResultDeny`)
- Callback signature: `(tool_name, input_data, context) -> Allow | Deny`
- `PermissionResultAllow(updated_input=...)` can modify tool inputs
- `PermissionResultDeny(message="...")` blocks with explanation

**Options** (most restrictive to most permissive):
1. `allowed_tools=["Read", "Grep"]` — Whitelist specific tools only
2. `can_use_tool=callback` — Dynamic allow/deny/modify per tool call
3. `permission_mode="acceptEdits"` — Auto-accept file edits
4. `permission_mode="bypassPermissions"` — Allow everything (dev only)

**Look up**: read `examples/tool_permission_callback.py`.

### Pattern 6: Hooks (Lifecycle Interception)

**When**: Logging, validation, security gates, error recovery
**Why**: Intercept agent behavior at key lifecycle points without changing the task prompt

Key shape:
- `ClaudeAgentOptions(hooks={"PreToolUse": [HookMatcher(matcher="Bash", hooks=[callback])]})`
- Callback signature: `(input_data: HookInput, tool_use_id, context: HookContext) -> HookJSONOutput`
- Return `hookSpecificOutput` with `permissionDecision: "allow"/"deny"` to control execution

**Available hook events**:
- `PreToolUse` — Before Claude calls a tool (can allow/deny/modify)
- `PostToolUse` — After tool execution (can add context, stop execution)
- `UserPromptSubmit` / `SessionStart` / `SessionEnd` — Session lifecycle
- `Stop` — Before agent stops (can add context to continue)

**Look up**: read `examples/hooks.py` for PreToolUse, PostToolUse, permission decisions, and stop control.

### Pattern 7: Subagents (Task Delegation)

**When**: Parallel tasks, isolated contexts, specialized domain agents
**Why**: Delegate to focused agents with their own tools, prompts, and models

Key shape:
- Define via `AgentDefinition(description, prompt, tools, model)`
- Register in `ClaudeAgentOptions(agents={"name": definition})`
- Invoke by asking the main agent to "use the <name> agent to..."

**Look up**: read `examples/agents.py` for single and multi-agent patterns.

### Pattern 8: Cost Control

**When**: Production budgets, dev experimentation limits
**Why**: Hard-stop agent execution when cost exceeds threshold

Key shape:
- `ClaudeAgentOptions(max_budget_usd=0.10)`
- `ResultMessage.subtype == "error_max_budget_usd"` when exceeded
- Cost checked after each API call, so final cost may slightly exceed budget

**Look up**: read `examples/max_budget_usd.py`.

### Pattern 9: System Prompt Customization

**When**: Custom personas, project-specific instructions, domain assistants
**Why**: Control Claude's behavior and knowledge base

Four methods:
1. **String** — Full replacement: `system_prompt="You are a pirate."`
2. **Preset** — Use built-in: `system_prompt={"type": "preset", "preset": "claude_code"}`
3. **Preset + append** — Extend built-in: `system_prompt={"type": "preset", "preset": "claude_code", "append": "Extra instructions."}`
4. **Empty** (default) — No system prompt, vanilla Claude

**Look up**: read `examples/system_prompt.py`.

## Decision Trees

### Q: Should I use `query()` or `ClaudeSDKClient`?

- **`query()`** if: Single task, no follow-up, simple pipeline
- **`ClaudeSDKClient`** if: Multi-turn, conversation history, streaming UI, interrupts, session management

### Q: How do I handle approvals and permissions?

1. **Whitelist** (`allowed_tools`) — Fast, predictable, best for production
2. **Permission callback** (`can_use_tool`) — Dynamic logic, can modify inputs
3. **Hooks** (`PreToolUse`) — Lifecycle-level control, chainable
4. **Permission mode** — Global setting for dev vs production
5. **Combination** — Whitelist + callback for defense in depth

## Learning Resources

- **Official docs**: [reference.md](references/reference.md) — TOC with links to every platform.claude.com page
- **Semantic search** — Use `mcp__claude-context__search_code` on the indexed repo for any concept
- **Browse examples**: `Glob(~/.claude/skills-references/claude-agent-sdk/claude-agent-sdk-python/examples/*.py)`
- **Fetch latest docs**: Use `WebFetch` on URLs from [reference.md](references/reference.md) for up-to-date details
