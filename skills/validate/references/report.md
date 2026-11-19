# Validation Report Template

The shape of `validation.md` (or `validation-<repo>.md`), read by the developer before the diff review. Keep the
Evidence, Risk and Deferred headings and the Branch line exactly as shown.

<report-template>

# Validation — <goal in a few words>

**Branch:** `<branch>` · **Base:** `<diff base commit>` · **Date:** <YYYY-MM-DD>

## Verdict

<Goal reached | Goal partly reached | Goal not reached> — one or two sentences on why, naming any scenario that failed
or was blocked.

## Evidence

One block per scenario, as the run check reported it:

#### <scenario> — <Pass|Fail|Blocked>
**How real:** <real app | command line | script through the interface>
**Ran:** <command or steps>
**Output:** <trimmed output, secrets and personal data `<redacted>`>

**Working tree:** <unchanged | the files the runs changed>

## Risk

- **Reversible?** <reversible by reverting the commit | one-way, because …>
- **Who else it affects:** <other callers, users, teams, stored data — or "only this repo's own users of X">
- **Safe because:** <the one fact the change is safe because of> — <how far that was proven: a scenario, a test, a
  read of the code, or not proven>

## Reading Order

**Read**

1. `<path>:<line>` — ⚠ <why a passing test does not make this safe>

**Skim**

- `<path>` — <what it changed> — safe because <the test or scenario that covers it>

## Findings

Every finding the developer saw, with its outcome:

- #<n> <one line> — <fixed | deferred | deferred, fix failed: <what is still wrong> | as-is: <the developer's reason>>

Every finding dropped in sorting, with its reason:

- <one line> — <misread: … | trade-off: <what accepted it> | noise: …>

## Deferred

- [ ] <finding> — `<path>:<line>`

</report-template>

Leave out Deferred when nothing was deferred. When nothing needs a careful read, replace the Read list with
"Nothing needs a careful read."
