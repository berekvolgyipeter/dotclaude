---
name: learn
description: Analyze conversation and update CLAUDE.md, rule files, any skills, commands, or agents that were used, and permission settings — based on user feedback vs agent behavior and on the permission prompts the user had to answer. Use this skill at the end of any conversation where corrections, misunderstandings, or new patterns emerged, especially when a skill, command, or agent underperformed or needed repeated guidance, or when Claude kept asking for permission for harmless actions. Also use when the user says things like "save what we learned", "remember this for next time", "update the rules", "stop asking me for this", "let's wrap up and capture this", or any variation of wanting to persist lessons from the current session.
---

## Triage first

Before diving into analysis, check if there's anything to learn. Most conversations have zero learnings; a few have one or two. Fabricating learnings from uneventful interactions creates noise that drowns out real insights — say so and stop if the conversation was routine.

A single offhand correction in an otherwise smooth conversation may not warrant a rule. Focus on patterns that would recur across future sessions.

## Analysis Process

Learnings live at two levels:
- **User-level** (`~/.claude/`) — shared across all projects (rules, skills, commands, agents, hooks, output styles)
- **Project-level** (`.claude/`) — specific to the current project (CLAUDE.md, rules, skills, commands, agents)

### Step 1: Scan for Learnings

Examine the conversation for learning signals and identify rule gaps in a single pass:

- **User corrections**: "Actually, you should...", "No, the correct way is...", "Don't do X, do Y instead" — includes cases where the user had to repeat themselves or rephrase
- **Agent mistakes**: Repeated errors, wrong assumptions, misunderstandings, or violations of existing rules (needs new rule or emphasis/clarification of existing one)
- **Emergent patterns**: Something worked well that should be documented, or a workflow crystallized that future sessions would benefit from. Positive learnings go to the same target files as fixes — add them as recommended patterns rather than corrective rules.
- **Tool invocations**: Instances of `Skill` tool calls (skills/commands) and `Agent` tool calls (agents) — these feed into Step 2
- **Permission friction**: Prompts the user approved, actions auto mode blocked, or remarks like "you could have just done that" — these feed into Step 3

### Step 2: Evaluate Used Skills, Commands, and Agents

Scan the conversation for any invocations of custom tools:

**Skills** — `Skill` tool calls where the `skill` parameter matches a name in `~/.claude/skills/` or `.claude/skills/`

**Commands** — slash command invocations like `/delta-review`, `/write-plan`, etc., which expand via the `Skill` tool

**Agents** — `Agent` tool calls where `subagent_type` matches a name in `~/.claude/agents/` or `.claude/agents/`

Also consider skills that the user *expected* to use but didn't trigger — a missing trigger is itself a learning (update the description to cover the missed context).

For each one found (or expected but missing), read its current definition file, then ask:
- Did the instructions lead to clear, correct behavior?
- Did the agent improvise steps that should be documented?
- Were there steps that were unnecessary or slowed things down?
- Did the user correct the output in a way that reveals a missing instruction?
- Did the description cause it to trigger at the wrong time (or fail to trigger)?

### Step 3: Review Permission Prompts

The prompts the user approved are not visible in the conversation — read them from the session transcript, the newest file under `~/.claude/projects/`. Each tool result there records how its permission was decided: `user_temporary` means the user approved a prompt once, `user_permanent` means they chose "don't ask again". Run `scripts/permission-prompts.sh` to list those calls; pass a transcript path to read another session.

Also take from the conversation itself the calls auto mode blocked (the notice names the matched rule in brackets, e.g. `[Data Exfiltration]`) and the calls the user declined.

For each recurring or plainly harmless prompt, find why it prompted — an `ask` rule that matched (often too broadly), no `allow` rule outside auto mode, or a classifier block — then pick the narrowest fix:

| Cause | Fix |
|-------|-----|
| An `ask` pattern catches a harmless call | Narrow or drop that `ask` entry |
| A fixed, safe command with no rule | `permissions.allow` entry for that exact command shape |
| Auto mode blocks a routine action | Prose rule in `autoMode.allow`, written as a description for a new engineer |
| Auto mode treats a destination you trust as external | `autoMode.environment` entry naming the host, repo, or bucket |

Guardrails — propose none of these:

- Loosening a `deny` entry, or anything that reads credentials or secrets
- An `autoMode` list without the literal `"$defaults"` entry — omitting it discards the built-in rules
- Broad allows like `Bash(*)` or a bare interpreter — auto mode drops them anyway
- Allowing a call the user declined, or one that changes system settings, git history, or a remote beyond what the user approved

Permission changes go to the user's settings file `~/.claude/settings.json` — `autoMode` is read only there. A permission that fits only the current project goes to `.claude/settings.local.json`. Keep machine-specific paths out of a settings file that is shared.

### Step 4: Determine Target File(s)

Decide whether a learning is **universal** (applies to all projects → user-level `~/.claude/`) or **project-specific** (→ project-level `.claude/`).

**Rule files (user-level `~/.claude/`):** list `~/.claude/rules/` — each file's name and H1 name its topic, and its `paths:` frontmatter (if any) names the files it applies to. Pick the rule whose topic and paths fit the learning.

**Rule files (project-level `.claude/`):**
- **Project specific details** → `.claude/CLAUDE.md`
- **Project-specific rules** → `.claude/rules/<topic>.md`

**Automation definition files** (at either level):
- **Skill** → `skills/<name>/SKILL.md`
- **Command** → `commands/<name>.md`
- **Agent** → `agents/<name>.md`
- **Output style** → `output-styles/<name>.md` — only when an output style was active and the learning is about its communication contract (verbosity, tone, default response/comment format). Generic communication preferences with no active style belong in a rule file instead.

This includes the learn skill itself — if the learning process was suboptimal, update its SKILL.md.

**New user-level files:** each entry under `~/.claude/<dir>/` is a symlink into the dotclaude repo, so edits to existing files through `~/.claude/` land in the repo, but a newly created top-level file would not. Create new user-level files at the repo path instead — the repo root is two levels above `readlink -f ~/.claude/skills/learn` — then run `make install` in the repo.

### Step 5: Formulate Updates

For substantial rewrites of skill, command, or agent instructions, invoke the `prompt-engineering` skill to ensure the new content follows best practices for AI prompt design. For simple additions like a single rule line in CLAUDE.md, just match the existing style — the overhead of invoking another skill isn't worth it for small changes.

For each learning, create a clear, actionable update:
- **Match content to scope**: General rules (`~/.claude/`) must use universally applicable text and examples — **never use actual class, function, variable, or file names from the current project**. Fabricate minimal generic names (e.g. `is_valid`, `has_items`, `MyClass`). Project-specific learnings (`.claude/`) may use domain terms and reference actual code patterns. When a learning is general, extract the universal principle and craft a fully generic example. **Self-check before writing**: re-read every proposed example and verify no name from the current project leaked in.
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

### Permission Updates

1. [Command or action that prompted] — [count] prompts
   - Cause: [matching `ask` rule, missing `allow`, or auto mode rule name]
   - Change: [exact entry to add, narrow, or drop]
   - File: [settings file]
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

1. /pr-review — Add diff-size gate
   - Context: User ran /pr-review on a 2000-line PR; the command tried to review every file and hit context limits
   - Issue: No guidance on handling large diffs — should summarize by file first, then deep-dive on request
   - File: `~/.claude/commands/review/pr-review.md`

### Permission Updates

1. `mycli api` reads with a path containing `-f` — 12 prompts
   - Cause: `ask` entry `Bash(mycli api *-f*)` meant for a write flag also matches `-f` inside a path
   - Change: drop it; let auto mode judge API writes
   - File: `~/.claude/settings.json`
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
5. **Verify the whole document stays consistent after the edit** — re-read the surrounding rules and confirm the change introduced no contradiction, no duplicated guidance, and no diverging terminology. A refinement that conflicts with a neighbouring rule, or repeats it in different words, is worse than no edit. If the new wording supersedes an existing rule, update or remove that rule too so the document speaks with one voice.

## Handling Existing Content

**Default to refining existing rules, not adding new ones.** Adding a fresh section or bullet on every invocation bloats rule files until they overflow context and degrade performance. Before writing anything new, genuinely analyze the target document: most learnings belong *inside* an existing rule — as a sharpened wording, an added example, or a broadened scope — not as a standalone addition. Only add a new rule when the learning is truly distinct from everything already there. Adding a new section is the exception, refinement is the norm.

Rule files accumulate institutional knowledge that's hard to reconstruct, so treat existing content carefully:

- **Find the closest existing rule first** — read the whole section the learning relates to and ask "does an existing rule or section already cover this?" Merge into or generalize the closest match rather than appending a near-sibling beside it; this is what keeps you from creating a near-duplicate.
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
- Target: The relevant language-specific rule (e.g., `~/.claude/rules/<language>-code.md`)
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
