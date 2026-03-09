---
name: learn
description: Analyze conversation and update CLAUDE.md, rule files, and/or any skills, commands, or agents that were used — based on user feedback vs agent behavior. Use this skill at the end of any conversation where corrections, misunderstandings, or new patterns emerged, especially when a skill, command, or agent underperformed or needed repeated guidance.
---

Analyze the current conversation to identify patterns where:
1. The user provided feedback or corrections
2. The agent made mistakes or didn't follow existing rules
3. New patterns or best practices emerged
4. **Skills, commands, or agents were used and could be improved**

Then update the appropriate files with learnings. Files live at two levels:
- **User-level** (`~/.claude/`) — shared across all projects (rules, skills, commands, agents, templates)
- **Project-level** (`.claude/`) — specific to the current project (CLAUDE.md, rules, skills, commands, agents)

If the conversation contained no corrections, mistakes, or new patterns — say so and skip. Don't fabricate learnings from routine, smooth interactions.

## Analysis Process

### Step 1: Review Conversation History

Examine the entire conversation for:
- **User corrections**: "Actually, you should...", "No, the correct way is...", "Don't do X, do Y instead"
- **Agent mistakes**: Repeated errors, misunderstandings, rule violations
- **Feedback patterns**: User repeatedly asking for the same thing differently
- **Successful patterns**: What worked well that should be documented
- **Tool invocations**: Instances of `Skill` tool calls (skills/commands) and `Task` tool calls (agents)

### Step 2: Identify Rule Gaps

Look for situations where:
- Agent violated existing `CLAUDE.md` rules (needs emphasis/clarification)
- Agent made reasonable assumptions that were wrong (needs new rule)
- User had to explain something multiple times (needs documentation)
- A pattern emerged that would help future tasks (needs capture)

### Step 3: Detect Used Skills, Commands, and Agents

Scan the conversation for any invocations of custom tools:

**Skills** — `Skill` tool calls where the `skill` parameter matches a name in `~/.claude/skills/` or `.claude/skills/`
- User-level: `~/.claude/skills/<name>/SKILL.md`
- Project-level: `.claude/skills/<name>/SKILL.md`

**Commands** — slash command invocations like `/fix-review`, `/generate-prp`, etc., which expand via the `Skill` tool
- User-level: `~/.claude/commands/<name>.md`
- Project-level: `.claude/commands/<name>.md`

**Agents** — `Task` tool calls where `subagent_type` matches a name in `~/.claude/agents/` or `.claude/agents/`
- User-level: `~/.claude/agents/<name>.md`
- Project-level: `.claude/agents/<name>.md`

Also consider skills that the user *expected* to use but didn't trigger — a missing trigger is itself a learning (update the description to cover the missed context).

For each one found (or expected but missing), read its current definition file, then ask:
- Did the instructions lead to clear, correct behavior?
- Did the agent improvise steps that should be documented?
- Were there steps that were unnecessary or slowed things down?
- Did the user correct the output in a way that reveals a missing instruction?
- Did the description cause it to trigger at the wrong time (or fail to trigger)?

### Step 4: Determine Target File(s)

Decide whether a learning is **universal** (applies to all projects → user-level `~/.claude/`) or **project-specific** (→ project-level `.claude/`).

**Rule files (user-level `~/.claude/`):**
- **General behaviour and philosophy** → `~/.claude/rules/general.md`
- **Coding Standards** → `~/.claude/rules/code.md`
- **Testing** → `~/.claude/rules/test.md`
- **Debugging** → `~/.claude/rules/debug.md`

**Rule files (project-level `.claude/`):**
- **Project specific details** → `.claude/CLAUDE.md`
- **Project-specific rules** → `.claude/rules/<topic>.md`

**Automation definition files:**
- **Skill** → `~/.claude/skills/<name>/SKILL.md` or `.claude/skills/<name>/SKILL.md`
- **Command** → `~/.claude/commands/<name>.md` or `.claude/commands/<name>.md`
- **Agent** → `~/.claude/agents/<name>.md` or `.claude/agents/<name>.md`

### Step 5: Formulate Updates

When updating skill descriptions, command prompts, or agent instructions, invoke the `prompt-engineering` skill first to ensure the new content follows best practices for AI prompt design.

For each learning, create a clear, actionable update:
- **Match content to scope**: General rules (`~/.claude/`) must use universally applicable text and examples — no project-specific names or domain concepts. Project-specific learnings (`.claude/`) may use domain terms and reference actual code patterns. When a learning is general, extract the universal principle and craft a generic example.
- **Be concise**: One clear point per rule
- **Be actionable**: The next agent running this skill/command/agent should know exactly what to do differently
- **Show examples**: Use ✅ GOOD / ❌ BAD format when helpful
- **Keep examples minimal**: Prefer simple 2-5 line snippets over verbose realistic ones
- **Prioritize by impact**: If you identify more than 3-4 learnings, present the highest-impact items first: rules that prevent repeated mistakes > rules that save significant time > nice-to-have documentation. Ask the user if they want the rest.

## Update Format

For 1-2 learnings, keep it brief — state what happened, what to change, and where.

For 3+ learnings, use this structured template:

```markdown
## Conversation Analysis

### Rule Updates

1. [Learning title]
   - Context: [What happened in the conversation]
   - Issue: [What went wrong or what pattern emerged]
   - File: [Target rule file]

### Skill / Command / Agent Updates

1. [skill-name | /command-name | agent-name] — [What to improve]
   - Context: [What happened when it ran]
   - Issue: [What was missing, wrong, or redundant in the instructions]
   - File: [`~/.claude/` or `.claude/` path to the definition file]
```

## Implementation

Before presenting the analysis:
1. Read all candidate target files to check for duplicates and understand current content
2. Verify the section exists or note where to add it
3. Ensure new content doesn't conflict with existing rules or instructions

After presenting the analysis:
1. Ask user to confirm the updates
2. Apply changes to the appropriate file(s)
3. Ensure formatting is consistent with existing content
4. Place new rules in the most logical section
5. Preserve all existing content

## Important Notes

- **Don't duplicate**: Check if a similar rule already exists before adding
- **Don't remove**: Only add or clarify; never remove existing content without explicit user request
- **Watch file size**: If a rule file is getting long (>100 lines), suggest the user consolidate related rules or prune outdated ones in a separate pass
- **Be objective**: Focus on patterns observed in the conversation. User preferences expressed through corrections are valid learnings — capture them as preferences, not as universal rules
- **Handling existing content**:
  - Exact duplicate → Skip
  - Similar but incomplete → Enhance with more detail
  - Conflicting → Flag for user review, don't auto-replace
  - Complementary → Add as a new distinct rule
- **Scope reference**:
  - **User-level (`~/.claude/`)** — universal rules, skills, commands, agents, templates shared across all projects:
    - `~/.claude/rules/general.md` — Behavioral rules, general philosophy, tool preferences
    - `~/.claude/rules/code.md` — Coding standards, error handling, style
    - `~/.claude/rules/test.md` — Testing best practices, fixtures, mocking
    - `~/.claude/rules/debug.md` — Debugging tools and techniques
    - `~/.claude/skills/<name>/SKILL.md` — Skill instructions, steps, examples, description
    - `~/.claude/commands/<name>.md` — Command prompt template and steps
    - `~/.claude/agents/<name>.md` — Agent role, responsibilities, working process
  - **Project-level (`.claude/`)** — project-specific config:
    - `.claude/CLAUDE.md` — Project-specific details, architecture, development patterns, dependencies, workflows
    - `.claude/rules/<topic>.md` — Project-specific rules
    - `.claude/skills/<name>/SKILL.md` — Project-specific skills
    - `.claude/commands/<name>.md` — Project-specific commands
    - `.claude/agents/<name>.md` — Project-specific agents
  - This includes the learn skill itself — if the learning process was suboptimal, update `~/.claude/skills/learn/SKILL.md`

## Example Scenarios

**Scenario 1: Agent repeatedly used wrong import pattern**
- Learning: Agent imported from wrong module despite correction
- Target: `~/.claude/rules/code.md`
- Update: Add specific import convention with correct example

**Scenario 2: Agent missed project-specific pattern**
- Learning: Project uses specific error handling pattern agent didn't follow
- Target: `.claude/CLAUDE.md`
- Update: Document the project-specific error handling pattern

**Scenario 3: Skill produced incomplete output**
- Learning: The `slither` skill instructions didn't specify output format, causing the agent to improvise each time
- Target: `~/.claude/skills/slither/SKILL.md` (or `.claude/skills/` if project-specific)
- Update: Add an explicit output format section so every invocation is consistent

**Scenario 4: Command missing a finalization step**
- Learning: `/fix-review` didn't remind the agent to run `make lint` after the last fix, and the user had to ask
- Target: `~/.claude/commands/fix-review.md` (or `.claude/commands/` if project-specific)
- Update: Add a "finalize" section at the end with the required lint/test commands

**Scenario 5: Agent over-scoped its work**
- Learning: The `documentation-manager` agent updated docs the user didn't want touched
- Target: `~/.claude/agents/documentation-manager.md` (or `.claude/agents/` if project-specific)
- Update: Add a scope constraint — only update docs for files explicitly passed as changed

**Scenario 6: Skill triggered in wrong context**
- Learning: A skill's description matched too broadly and triggered when another tool was more appropriate
- Target: The relevant `SKILL.md` description field
- Update: Tighten the description to exclude the false-trigger context

## Success Criteria

A good update should:
- ✅ Prevent the same mistake from happening again
- ✅ Be clear enough that any agent can follow it without extra context
- ✅ Include concrete examples when applicable
- ✅ Fit naturally into the existing file structure
- ✅ Not conflict with existing rules
- ✅ (For skill/command/agent updates) Improve how future invocations are guided
