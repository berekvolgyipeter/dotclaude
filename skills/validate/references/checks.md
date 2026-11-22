# Check Prompts

Each check runs in its own `general-purpose` helper. Send each one its prompt below with the placeholders filled in,
and nothing else: no summary of the session, no reasons behind the change, no hint of what you expect it to find. The
helper judges the change the way a reviewer who was not in the room would — that is the point of running it apart.

Placeholders — replace each with its value or text:

- `{{GOAL}}` — the goal, verbatim.
- `{{PLAN}}` — the plan file's path, or "None".
- `{{DESIGN}}` — the design docs' paths, or "None".
- `{{ROOT}}` — the change set's root.
- `{{DIFF_BASE}}` — the commit the change is compared against.
- `{{FILES}}` — the untracked files, as the change-set overview lists them, minus those under `.claude/plans/`; or
  "None".
- `<read-only rule>` — the goal-and-plan and design prompts carry this text, since running code writes caches and
  output into the developer's working tree, and running it is the third check's job:

  > Read the code; do not run it, its tests or any script against it.

- `<reply rule>` — every prompt ends with this text:

  > Skip files under `.claude/plans/`: they are documents, not the change. In the plan, ignore its Execution Record:
  > it is the author's notes, not the agreement. Write each finding in the shape
  > `~/.claude/skills/review-changes/references/finding.md` defines, and add no preamble and no summary of the
  > change. Before you report a finding, re-read the code or output behind it and drop it if you cannot confirm it.
  > With no findings, write "No findings."

## Goal and Plan

> You check whether a finished change does what was asked — no less and no more.
>
> <goal>{{GOAL}}</goal>
> Plan: {{PLAN}}. Design: {{DESIGN}}.
> Repo: `{{ROOT}}`. The change is `git -C {{ROOT}} diff -M {{DIFF_BASE}}` plus these untracked files, which you read
> directly: {{FILES}}.
>
> Read the goal, then the plan's Requirements and Out of Scope (when there is a plan), then the change. Report:
>
> 1. each requirement that is missing or only partly met — quote it;
> 2. each requirement that looks met but behaves wrongly — quote it and point at the code;
> 3. behaviour the change adds that nothing asked for.
>
> Without a plan, judge against the goal alone. A missing requirement is a bug; added behaviour is a judgement call
> unless it breaks something.
>
> <read-only rule>
>
> <reply rule>

## Design

> You check whether a finished change keeps the shape that was agreed for it.
>
> <goal>{{GOAL}}</goal>
> Plan: {{PLAN}}. Design: {{DESIGN}}.
> Repo: `{{ROOT}}`. The change is `git -C {{ROOT}} diff -M {{DIFF_BASE}}` plus these untracked files, which you read
> directly: {{FILES}}.
>
> For each module in the plan's Module Map, check that the built interface matches the agreed one — operations,
> inputs, outputs, error modes — and that each Key Decision and each design decision held. Report every place the
> code departs from them, quoting the agreed text, as a bug.
>
> <read-only rule>
>
> <reply rule>

## Run It for Real

> You run a finished change for real, the way its user would, and keep the output as evidence.
>
> <goal>{{GOAL}}</goal>
> Plan: {{PLAN}}. Design: {{DESIGN}}.
> Repo: `{{ROOT}}`. The change is `git -C {{ROOT}} diff -M {{DIFF_BASE}}` plus these untracked files: {{FILES}}.
>
> 1. Pick up to three scenarios that show the goal is reached, most important first; prefer the paths a user takes
>    over edge cases, which the tests already cover.
> 2. Record `git -C {{ROOT}} status --porcelain` before the first run.
> 3. Run each scenario. Invoke the `run` skill through the Skill tool to launch the real app when there is one.
>    Otherwise take the closest real run: the command line, or a short script that calls the module's interface the
>    way a caller would. Write scripts and output to a temporary directory outside the repo. When a run must write
>    inside the repo, copy the repo to a temporary directory and run there. Never stash, reset, check out or delete
>    in `{{ROOT}}`: its uncommitted work is the developer's.
> 4. Record `git -C {{ROOT}} status --porcelain` again. If it differs, name the files that changed.
>
> Each scenario ends in one state:
>
> - **Pass** — it did what the goal says.
> - **Fail** — it ran and did the wrong thing.
> - **Blocked** — even the closest real run was impossible (the sandbox refused it, it needs a credential or a device
>   you do not have); say what the developer must provide.
>
> Run inside the access you were given: when the sandbox or network refuses a run, the scenario is Blocked — do not
> ask for more network hosts or a way around the sandbox. Widening access is the developer's call, not the check's.
>
> Never run a scenario whose effect cannot be undone or reaches beyond this machine: a migration or deletion against a
> store that is not throwaway, sending messages, publishing, deploying, or calling paid or production services. Mark
> it Blocked and say what safe target it would need.
>
> In Ran and Output, replace secrets, tokens, credentials, connection strings and personal data with `<redacted>`:
> the run and its output go into a report that gets committed; name a secret by its variable, never its value.
>
> Reply first with one block per scenario:
>
> ```
> #### <scenario> — <Pass|Fail|Blocked>
> **How real:** <real app | command line | script through the interface>
> **Ran:** <command or steps>
> **Output:** <the lines that show the result, trimmed>
> ```
>
> Then the working tree line: "Working tree unchanged", or the files that changed. Then each Fail as a finding — the
> scenario blocks always come first, even when every scenario passed.
>
> <reply rule>
