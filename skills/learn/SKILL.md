---
name: learn
description: Analyze conversation and update CLAUDE.md, rule files, and/or any skills, commands, or agents that were used — based on user feedback vs agent behavior. Use this skill at the end of any conversation where corrections, misunderstandings, or new patterns emerged, especially when a skill, command, or agent underperformed or needed repeated guidance. Also use when the user says things like "save what we learned", "remember this for next time", "update the rules", "let's wrap up and capture this", or any variation of wanting to persist lessons from the current session.
---

## Triage first

Before diving into analysis, check if there's anything to learn. Most conversations have zero learnings; a few have one or two. Fabricating learnings from uneventful interactions creates noise that drowns out real insights — say so and stop if the conversation was routine.

A single offhand correction in an otherwise smooth conversation may not warrant a rule. Focus on patterns that would recur across future sessions.

## Analysis Process

Learnings live at two levels:
- **User-level** (`~/.claude/`) — shared across all projects (rules, skills, commands, agents, templates)
- **Project-level** (`.claude/`) — specific to the current project (CLAUDE.md, rules, skills, commands, agents)

### Step 1: Scan for Learnings

Examine the conversation for learning signals and identify rule gaps in a single pass:

- **User corrections**: "Actually, you should...", "No, the correct way is...", "Don't do X, do Y instead" — includes cases where the user had to repeat themselves or rephrase
- **Agent mistakes**: Repeated errors, wrong assumptions, misunderstandings, or violations of existing rules (needs new rule or emphasis/clarification of existing one)
- **Emergent patterns**: Something worked well that should be documented, or a workflow crystallized that future sessions would benefit from. Positive learnings go to the same target files as fixes — add them as recommended patterns rather than corrective rules.
- **Tool invocations**: Instances of `Skill` tool calls (skills/commands) and `Task` tool calls (agents) — these feed into Step 2

### Step 2: Evaluate Used Skills, Commands, and Agents

Scan the conversation for any invocations of custom tools:

**Skills** — `Skill` tool calls where the `skill` parameter matches a name in `~/.claude/skills/` or `.claude/skills/`

**Commands** — slash command invocations like `/fix-review`, `/generate-prp`, etc., which expand via the `Skill` tool

**Agents** — `Task` tool calls where `subagent_type` matches a name in `~/.claude/agents/` or `.claude/agents/`

Also consider skills that the user *expected* to use but didn't trigger — a missing trigger is itself a learning (update the description to cover the missed context).

For each one found (or expected but missing), read its current definition file, then ask:
- Did the instructions lead to clear, correct behavior?
- Did the agent improvise steps that should be documented?
- Were there steps that were unnecessary or slowed things down?
- Did the user correct the output in a way that reveals a missing instruction?
- Did the description cause it to trigger at the wrong time (or fail to trigger)?

### Step 3: Determine Target File(s)

Decide whether a learning is **universal** (applies to all projects → user-level `~/.claude/`) or **project-specific** (→ project-level `.claude/`).

**Rule files (user-level `~/.claude/`):** See `~/.claude/index/rules.md` for the full list of rule files and what each covers.

**Rule files (project-level `.claude/`):**
- **Project specific details** → `.claude/CLAUDE.md`
- **Project-specific rules** → `.claude/rules/<topic>.md`

**Automation definition files** (at either level):
- **Skill** → `skills/<name>/SKILL.md`
- **Command** → `commands/<name>.md`
- **Agent** → `agents/<name>.md`

This includes the learn skill itself — if the learning process was suboptimal, update its SKILL.md.

### Step 4: Formulate Updates

For substantial rewrites of skill, command, or agent instructions, invoke the `prompt-engineering` skill to ensure the new content follows best practices for AI prompt design. For simple additions like a single rule line in CLAUDE.md, just match the existing style — the overhead of invoking another skill isn't worth it for small changes.

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

**Example (filled in):**

```markdown
## Conversation Analysis

### Rule Updates

1. Test commands must run from project root
   - Context: Agent ran `pytest` from a subdirectory, tests failed with import errors, user corrected twice
   - Issue: No rule about working directory for test commands
   - File: `.claude/CLAUDE.md`

### Skill / Command / Agent Updates

1. /review — Add diff-size gate
   - Context: User ran /review on a 2000-line PR; the command tried to review every file and hit context limits
   - Issue: No guidance on handling large diffs — should summarize by file first, then deep-dive on request
   - File: `~/.claude/commands/review.md`
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

## Handling Existing Content

Rule files accumulate institutional knowledge that's hard to reconstruct, so treat existing content carefully:

- **Check for duplicates first** — before adding a new rule, search for similar existing ones. Enhancing an existing rule is better than creating a near-duplicate.
- **Exact duplicate** → Skip
- **Similar but incomplete** → Enhance with more detail
- **Conflicting** → Flag for user review. If a new learning directly supersedes an old rule, propose replacing the old one rather than adding alongside it — stale rules create confusion.
- **Complementary** → Add as a new distinct rule
- **Outdated** → If you notice a rule that's clearly no longer relevant while reading the file, mention it to the user as a cleanup candidate
- **File size** → If a rule file exceeds ~100 lines, suggest the user consolidate related rules or prune outdated ones
- **Be objective**: Focus on patterns observed in the conversation. User preferences expressed through corrections are valid learnings — capture them as preferences, not as universal rules

## Example Scenarios

**Scenario 1: Agent repeatedly used wrong import pattern**
- Learning: Agent imported from wrong module despite correction
- Target: The relevant language-specific rule file (e.g., `~/.claude/rules/<language>.md`)
- Update: Add specific import convention with correct example

**Scenario 2: Agent missed project-specific pattern**
- Learning: Project uses specific error handling pattern agent didn't follow
- Target: `.claude/CLAUDE.md`
- Update: Document the project-specific error handling pattern

**Scenario 3: Skill produced incomplete output**
- Learning: A skill's instructions didn't specify output format, causing the agent to improvise each time
- Target: The relevant `SKILL.md` (at `~/.claude/skills/` or `.claude/skills/`)
- Update: Add an explicit output format section so every invocation is consistent

**Scenario 4: Command missing a finalization step**
- Learning: A command didn't remind the agent to run linting after the last fix, and the user had to ask
- Target: The relevant command file (at `~/.claude/commands/` or `.claude/commands/`)
- Update: Add a "finalize" section at the end with the required lint/test commands

**Scenario 5: Agent over-scoped its work**
- Learning: An agent updated docs the user didn't want touched
- Target: The relevant agent definition file
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
