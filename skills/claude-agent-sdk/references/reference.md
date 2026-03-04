# Claude Agent SDK Reference

Comprehensive documentation for the Claude Agent SDK.

## Table of Contents

**Getting Started**
- [Overview](#overview) - SDK overview and capabilities
- [Quickstart](#quickstart) - Getting started guide
- [Migration Guide](#migration-guide) - Migrate from Claude Code SDK

**Core Features**
- [Python SDK](#python-sdk) - Core API and basic usage
- [Streaming Input](#streaming-input) - Interactive vs one-shot modes
- [Streaming Output](#streaming-output) - Real-time response streaming
- [Session Management](#session-management) - Context and conversation branching

**Customization & Control**
- [Modifying System Prompts](#modifying-system-prompts) - Behavior customization
- [Custom Tools](#custom-tools) - Building extensions
- [Subagents](#subagents) - Task delegation
- [MCP in the SDK](#mcp-in-the-sdk) - External integrations

**Security & Configuration**
- [Handling Permissions](#handling-permissions) - Security controls
- [Hooks](#hooks) - Intercept and control agent behavior
- [User Input](#user-input) - Handle approvals and clarifying questions
- [Secure Deployment](#secure-deployment) - Security best practices
- [Structured Outputs](#structured-outputs) - Type-safe JSON results

**Monitoring & Debugging**
- [Stop Reasons](#stop-reasons) - Detect refusals and termination conditions
- [Tracking Costs and Usage](#tracking-costs-and-usage) - Usage monitoring

**Extensions & Operations**
- [Slash Commands](#slash-commands) - Custom workflows
- [Agent Skills](#agent-skills) - Capability packages
- [Plugins](#plugins) - Extension packages
- [File Checkpointing](#file-checkpointing) - Rewind file changes
- [Hosting the Agent SDK](#hosting-the-agent-sdk) - Production deployment
- [Todo Lists](#todo-lists) - Progress tracking

---

Each section below contains:
- A link to the official documentation
- A summary of what the section covers
- Guidance on when to use that particular feature

## [Overview](https://platform.claude.com/docs/en/agent-sdk/overview.md)

Introduces the Claude Agent SDK as a production-ready framework for building AI agents, covering the full range of built-in capabilities (file reading, command execution, web search, code editing), available tools, setup steps, and comparisons between the Agent SDK, the Anthropic Client SDK, and the Claude Code CLI. Also includes information on API key setup, third-party cloud provider authentication, branding guidelines, and changelog links.

Use this for a high-level understanding of what the Agent SDK offers, how it compares to other Claude tools, and how to get an agent running from scratch.

## [Quickstart](https://platform.claude.com/docs/en/agent-sdk/quickstart.md)

Walks step-by-step through installing Claude Code, setting up a Python or TypeScript project, creating a file with intentional bugs, and building an agent that autonomously reads, analyzes, and fixes the code using the `query()` function. Covers key concepts like tool selection, permission modes, and how the agentic loop works.

Use this as the first stop when starting with the SDK—it gets a working agent running in minutes and explains the core patterns you'll use throughout development.

## [Migration Guide](https://platform.claude.com/docs/en/agent-sdk/migration-guide.md)

Documents how to migrate from the old Claude Code SDK (`@anthropic-ai/claude-code` / `claude-code-sdk`) to the renamed Claude Agent SDK, including package installation commands, import changes, and breaking changes in v0.1.0 such as the renamed `ClaudeAgentOptions` type, the shift to an empty default system prompt, and settings sources no longer being loaded from the filesystem by default.

Use this when upgrading an existing project that was built on the previous Claude Code SDK, to ensure a smooth transition without introducing regressions.

## [Python SDK](https://platform.claude.com/docs/en/agent-sdk/python.md)

Covers the foundational Python API for interacting with Claude Code, including the `query()` function for one-off tasks and `ClaudeSDKClient` for maintaining conversation sessions, plus basic setup, installation, and simple usage examples.

Use this for getting started with the SDK, understanding the core client API, or implementing basic Claude integrations in Python applications.

## [Streaming Input](https://platform.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md)

Explains the difference between streaming input mode (interactive multi-turn conversations with image support, message queueing, and real-time response streaming) and single message mode (one-shot stateless queries), helping developers choose the appropriate interaction pattern for their use case.

Use this when deciding between persistent interactive sessions versus simple one-off queries, or when implementing image attachments and interruption capabilities.

## [Streaming Output](https://platform.claude.com/docs/en/agent-sdk/streaming-output.md)

Describes how to enable real-time token-level streaming of text and tool calls by setting `include_partial_messages` (Python) or `includePartialMessages` (TypeScript), detailing the `StreamEvent` type, the sequence of raw API events emitted, how to extract text deltas and track tool call progress incrementally, and how to build a streaming UI with live status indicators. Also covers known limitations with extended thinking and structured output.

Use this when building chat interfaces or progress displays that need to show Claude's output as it is generated, rather than waiting for each full response.

## [Session Management](https://platform.claude.com/docs/en/agent-sdk/sessions.md)

Describes how to create, resume, and fork conversation sessions to maintain context across multiple interactions, including techniques for linear continuation, branching conversations, and preserving original conversation threads while exploring alternatives.

Use this when implementing persistent conversations, conversation branching, or managing multiple conversation paths simultaneously.

## [Modifying System Prompts](https://platform.claude.com/docs/en/agent-sdk/modifying-system-prompts.md)

Explains four methods for customizing Claude's behavior (CLAUDE.md project files, output styles, system prompt append, and custom system prompts), helping developers tailor Claude's responses, interaction style, and capabilities for specific use cases while preserving or replacing built-in functionality.

Use this when creating specialized agent personas, adding project-specific instructions, customizing agent behavior per session, or building domain-specific assistants.

## [Custom Tools](https://platform.claude.com/docs/en/agent-sdk/custom-tools.md)

Shows how to create type-safe custom tools using in-process MCP servers with the `@tool` decorator and schema validation (Zod/Python types), register them via `mcpServers` configuration, and control tool access with `allowedTools` in streaming input mode.

Use this when building custom tool integrations with external APIs, databases, or services, implementing domain-specific operations, or extending Claude's capabilities with application-specific functionality.

## [Subagents](https://platform.claude.com/docs/en/agent-sdk/subagents.md)

Explains how to create specialized AI agents orchestrated by a primary agent with isolated contexts, concurrent execution capabilities, custom system prompts, and granular tool access control via programmatic definition or filesystem-based configuration.

Use this when implementing task delegation, parallel processing workflows, specialized domain experts within agents, or isolating complex operations to prevent main conversation context pollution.

## [MCP in the SDK](https://platform.claude.com/docs/en/agent-sdk/mcp.md)

Describes how Model Context Protocol (MCP) servers extend Claude Code with custom tools and resources through three transport options (stdio, HTTP/SSE, in-process), including configuration via `.mcp.json` files or inline options with environment variable support.

Use this when integrating external MCP servers, exposing custom tools or resources to Claude, configuring third-party MCP integrations, or building extensible agent applications with modular capabilities.

## [Handling Permissions](https://platform.claude.com/docs/en/agent-sdk/permissions.md)

Details four permission control mechanisms (permission modes, canUseTool callback, hooks, and permission rules) that determine which operations Claude can execute, including modes like `default`, `acceptEdits`, and `bypassPermissions` for controlling tool access globally or dynamically.

Use this when implementing security controls, restricting tool usage, or building approval workflows for agent operations.

## [Hooks](https://platform.claude.com/docs/en/agent-sdk/hooks.md)

Covers the full hooks system for intercepting agent execution at key lifecycle points—including `PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, `SessionEnd`, and more—to add validation, logging, security controls, input transformation, or human approval gates. Explains matcher patterns for targeting specific tools, callback input/output schemas, how to block or modify tool calls, and how to chain multiple hooks for layered logic.

Use this when you need to enforce security policies, audit all agent actions, redirect file writes to sandboxed paths, require approval for sensitive operations, or react to subagent activity and session lifecycle events.

## [User Input](https://platform.claude.com/docs/en/agent-sdk/user-input.md)

Explains how to surface Claude's tool approval requests and clarifying questions (`AskUserQuestion`) to end users via a `canUseTool` callback, how to parse the structured question-and-options format Claude generates, and how to return allow/deny/modify responses. Covers all response strategies including approving with changes, suggesting alternatives, and redirecting the agent entirely.

Use this when building applications where human oversight or interactive decision-making is required, such as approval workflows, guided setup wizards, or any agent that needs user input before proceeding with sensitive or ambiguous tasks.

## [Secure Deployment](https://platform.claude.com/docs/en/agent-sdk/secure-deployment.md)

Provides a comprehensive security guide for production agent deployments, covering threat models (prompt injection, unintended actions), Claude Code's built-in protections, and additional hardening strategies including container isolation with Docker, gVisor kernel-level isolation, Firecracker microVMs, the proxy pattern for credential management, filesystem access controls, and cloud-native network restrictions.

Use this when deploying agents to production environments that process untrusted content, handle sensitive data, or operate in multi-tenant contexts where stronger isolation and credential protection are required.

## [Structured Outputs](https://platform.claude.com/docs/en/agent-sdk/structured-outputs.md)

Explains how to obtain validated JSON results from agent workflows using JSON Schema, Zod (TypeScript), or Pydantic (Python) to ensure Claude returns data in precisely defined formats with type-safety and automatic validation.

Use this when you need Claude to return structured data matching specific schemas, require type-safe output parsing, or want to integrate agent results directly into strongly-typed applications.

## [Stop Reasons](https://platform.claude.com/docs/en/agent-sdk/stop-reasons.md)

Explains the `stop_reason` field available on every `ResultMessage`, detailing all possible values (`end_turn`, `max_tokens`, `refusal`, `tool_use`, etc.), how stop reasons propagate through error result variants like `error_max_turns`, and how to detect refusals without needing to parse raw stream events.

Use this when you need to programmatically handle different agent termination conditions, detect and respond to refusals, or distinguish between normal completion and error states in production pipelines.

## [Tracking Costs and Usage](https://platform.claude.com/docs/en/agent-sdk/cost-tracking.md)

Explains how to monitor token consumption and calculate API costs by tracking message usage data, implementing deduplication strategies using message IDs to prevent double-charging, and aggregating costs across multi-step conversations with separate pricing for input/output/cache tokens.

Use this when implementing billing systems, monitoring API costs, displaying usage metrics to users, or optimizing token consumption in agent applications.

## [Slash Commands](https://platform.claude.com/docs/en/agent-sdk/slash-commands.md)

Covers built-in commands (/compact, /clear, /help) and custom slash command creation with YAML frontmatter configuration, dynamic arguments, bash execution, and file references stored in `.claude/commands/` directories.

Use this when implementing custom workflows, creating reusable command shortcuts, managing conversation state, or building project-specific command palettes with configurable tool permissions.

## [Agent Skills](https://platform.claude.com/docs/en/agent-sdk/skills.md)

Describes filesystem-based specialized capabilities packaged as `SKILL.md` files in `.claude/skills/` that Claude autonomously invokes when relevant, requiring `settingSources` configuration for discovery and differing from slash commands (user-invoked) and subagents (support programmatic registration).

Use this when creating domain expertise packages, building reusable capability modules, implementing context-sensitive assistance, or providing Claude with specialized knowledge that should activate automatically based on task relevance.

## [Plugins](https://platform.claude.com/docs/en/agent-sdk/plugins.md)

Explains how plugins extend Claude Code with shareable packages containing commands, agents, skills, hooks, and MCP servers loaded from local directories with automatic namespacing to prevent conflicts.

Use this when creating reusable extension packages, sharing functionality across projects, building plugin ecosystems, or loading multiple custom extensions into agent sessions without global installation.

## [File Checkpointing](https://platform.claude.com/docs/en/agent-sdk/file-checkpointing.md)

Details the file checkpointing system that captures backups of files before they are modified by the Write, Edit, or NotebookEdit tools, allowing you to restore files to any prior state using checkpoint UUIDs captured from the response stream. Covers how to enable checkpointing, capture and store multiple restore points, rewind after session completion by resuming with an empty prompt, and patterns for undoing risky operations mid-stream.

Use this when building agent workflows that make potentially unwanted file modifications, enabling undo functionality in developer tools, or exploring multiple refactoring approaches with the ability to revert between them.

## [Hosting the Agent SDK](https://platform.claude.com/docs/en/agent-sdk/hosting.md)

Covers production deployment strategies for the Agent SDK including sandboxed container requirements, four deployment patterns (ephemeral, long-running, hybrid, and single-container sessions), infrastructure specs, security considerations, and hosting provider options.

Use this when deploying agents to production, setting up containerized agent environments, choosing deployment architectures, or configuring security sandboxing for agent workloads.

## [Todo Lists](https://platform.claude.com/docs/en/agent-sdk/todo-tracking.md)

Details the automatic todo list system that manages multi-step tasks through pending/in-progress/completed states, capturing updates via streaming `TodoWrite` tool calls to provide real-time progress visibility for complex workflows.

Use this when building progress indicators, tracking multi-step task execution, displaying workflow status to users, or monitoring agent task completion in real-time.
