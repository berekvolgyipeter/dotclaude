# Report Format

A retro's report, written into `~/.claude/retros/` and read by the developer. The next full retro reads only its
`Sessions up to` time, and the reminder hook only its file name.

`<YYYY-MM-DD>-<scope>.md`, where scope is `task`, `session`, `change` or `full`; when that file exists, add `-2`,
`-3`… before `.md`. Write it for a glance: plain words, no file-internal jargon in the TL;DR, every moment paraphrased.

<report-template>

# Retro — <scope in words> — <YYYY-MM-DD>

**Scope:** <scope> · **Window:** <start ISO time, or "every retained session"> to now · **Sessions up to:** <ISO time
the sessions were looked up>
**Read:** <n> sessions · **Signals:** <n> prompts, <n> denials, <n> hook rejections, <n> failures, <n> sandbox blocks,
<n> interrupts (per session: <averages, same order>)

## TL;DR

Three lines: how the sessions went for the human, the worst problem found, and what the proposals would change.

## Proposals

### 1. <the problem, in a few words> <"— widens access" when the fix drops a guard>

**Evidence:** <the sessions and moments that show it, paraphrased>
**Cost:** <what it cost, added up across sessions>
**Fix:** <rung> — <what changes> in `<target file>`
**Success sign:** <what a later session or the tree shows if it worked>

## Dropped

- <one line> — <below the bar: why | below the top five | cause already gone>

</report-template>

Write **Window** only for a full scope. Leave out Dropped when nothing was dropped. With no proposals, write "Nothing
worth fixing." under Proposals. A full retro whose window holds no sessions writes the header lines, with `Read: 0
sessions` and no Signals, and "No sessions in the window." in place of the sections.
