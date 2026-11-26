# Report Format

A retro's report, written into `~/.claude/retros/` and read by the developer and by the design session that designs
the fixes.

`<YYYY-MM-DD>-<scope>.md`, where scope is `task`, `session`, `change` or `full`; when that file exists, add `-2`,
`-3`… before `.md`. Write it for a glance: plain words, no file-internal jargon in the TL;DR. Quote only the
developer's own short phrases from their feedback and questions — never a whole message, pasted text or anything that
looks like a secret — and paraphrase everything else.

<report-template>

# Retro — <scope in words> — <YYYY-MM-DD>

**Scope:** <scope> · **Window:** <start ISO time, or "every retained session"> to now · **Sessions up to:** <ISO time
the sessions were looked up>
**Read:** <n> sessions · **Signals:** <n> prompts, <n> denials, <n> hook rejections, <n> failures, <n> sandbox blocks,
<n> interrupts (per session: <averages, same order>)

## TL;DR

Three lines: how the sessions went for the developer, the worst agreed problem, and how many problems were agreed,
rejected and not gone through.

## Problems

### 1. <the problem, in a few words> — <high | medium | low>

**Their words:** <the developer's short phrases, quoted> — feedback only; friction has **Cost:** <what it cost, added
up across sessions> instead
**What happened:** <paraphrased>
**Cause:** <where it lives, as today's text shows it>
**Tried before:** <what an earlier fix tried, when, and that it did not work; or a commit that deliberately removed
text a fix would put back>
**Sessions:** <session ids and times>
**Developer's correction:** <what the developer corrected when agreeing>

## Rejected

- <the problem, in a few words> — <the developer's reason>

## Not gone through

- <the problem, in a few words> — <high | medium | low>

## Dropped

- <one line> — <below the bar | cause already gone | rejected in an earlier report and not seen since>

Next step: a design session on this whole report.

</report-template>

Write **Window** only for a full scope. Write **Tried before** only when the history shows one, and **Developer's
correction** only when they made one. Leave out Rejected, Not gone through or Dropped when it has nothing. "Below the
bar" applies to friction only. With no problems, write "No problems found." under Problems and leave out the last
line. A full retro whose window holds no sessions writes the header lines, with `Read: 0 sessions` and no Signals, and
"No sessions in the window." in place of the sections.
