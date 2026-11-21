# Retros Folder Formats

The files in `~/.claude/retros/`, read by the developer and by the next retro.

## Report

`<YYYY-MM-DD>-<scope>.md`, where scope is `task`, `session`, `change` or `full`; when that file exists, add `-2`,
`-3`… before `.md`. The file name without `.md` is the report's id. Write it for a glance: plain words, no
file-internal jargon in the TL;DR, every moment paraphrased.

<report-template>

# Retro — <scope in words> — <YYYY-MM-DD>

**Scope:** <scope> · **Sessions up to:** <ISO time the sessions were looked up> · **Status:** <awaiting decisions |
decided>
**Read:** <n> sessions

## TL;DR

Three lines: how the sessions went for the human, the worst problem found, and what the proposals would change.

## Last Time's Fixes

- <decision id> `<target>` — <worked | didn't: where it still shows | too early | not applied> — <fix present | fix
  missing>

## Proposals

### 1. <the problem, in a few words> <"— widens access" when the fix drops a guard>

**Evidence:** <the sessions and moments that show it, paraphrased>
**Cost:** <what it cost, added up across sessions>
**Fix:** <rung> — <what changes> in `<target file>`
**Success sign:** <what a later session or the tree shows if it worked>
**Decision:** <pending | accepted | rejected: reason | later>

## Dropped

- <one line> — <below the bar: why | rejected on <date> | below the top five | cause already gone>

## Noise

Reminders snoozed or dismissed since the last full retro: <n> · Proposals rejected since then: <n>

</report-template>

Leave out Last Time's Fixes when the decision log has no accepted items, and Dropped when nothing was dropped. With
no proposals, write "Nothing worth fixing." under Proposals.

## Decision Log

`decisions.md`, one line per decided proposal, appended:

```text
- <report id>#<n> · <accepted | rejected | later> · <target file> · <check> — <success sign | reason> — sessions: <ids>
```

`<check>` is the check that found it (intent, understanding, friction, procedure, review misses, automation,
security, usage). Applying an accepted fix appends ` · applied <YYYY-MM-DD>` to its line. An item answered "later"
gets a new line when it is decided.

## Reminder Date

`next-due`: the date on the first line, the snooze count on the second.

```text
2026-11-27
snoozed: 0
```
