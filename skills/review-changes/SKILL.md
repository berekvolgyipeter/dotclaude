---
name: review-changes
description: Line-by-line code review of a change set — uncommitted changes against the last commit, a branch against its base (`pr [base]`), or everything since a ref (`since <ref>`) — run in the background by independent reviewers, one per focus (correctness, the user's coding rules and code smells, and security and tests when the change calls for them), at a depth sized to the change's risk; the calling session then judges and fixes the findings. Use for every code review the user asks for, or when a workflow skill calls it; never review with a generic agent and a hand-written prompt instead. A multi-agent review is too costly to start unprompted.
argument-hint: "[repo] [pr [base] | since <ref>] [depth:lite|standard|full] [focus]"
allowed-tools:
  - Agent
---

# Review Changes

<arguments>
$ARGUMENTS
</arguments>

Dispatch one `general-purpose` subagent in the background with exactly this prompt, and add nothing about this
session's work — the reviewer must judge the code independently, and anything you add anchors it to your reasoning:

> Arguments: `<the arguments above, verbatim>`. Read `~/.claude/skills/review-changes/references/review-protocol.md`
> and follow it exactly: find the change set, then review it. Your final reply is the review output it specifies.

Then say the review is running and stop; continue with whatever the user asks meanwhile.

When the review arrives:

- **Findings** — each has a severity and a kind (bug or judgement call), in the shape
  `~/.claude/skills/review-changes/references/finding.md` defines; whether to fix it is yours to decide, since you
  know the change's goal and scope and the reviewers do not. Judge each one against that: fix every bug that holds up, and give a one-line reason for each one you leave; list
  the judgement calls with your recommendation for the user to choose. Your caller may set its own policy or ask you
  to fix nothing — follow it.
- **Before the first fix**, run `git -C <reviewed root> stash create` and keep the commit it prints — the
  **snapshot**; when it prints nothing, the snapshot is `HEAD`. It only records the work as it was and leaves the
  working tree and index untouched. After fixing, report the snapshot and offer `review-changes <root> since
  <snapshot>`, which reviews only what the fixes changed; untracked files are not in a snapshot, so that review reads
  them in full again.
- **A list of candidates, no changes, an unresolved ref, a request to name the base branch, or a passed review** —
  relay it as is.
