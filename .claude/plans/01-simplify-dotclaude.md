# Simplify dotclaude

## TL;DR

- **What** — cut hooks, helper scripts and commands that duplicate native Claude Code features or the model's own ability; rewrite the few that earn their keep.
- **Why** — git-aware commands break in an **Index repo** (`!` injection dies outside a git repo), and every artifact multiplies sync rules, README rows and settings entries.
- **How** — six independently committable phases; two gating tests run first because later phases depend on them.
- **Scope/risk** — the review pipeline's forked mode depends on a forked command being able to spawn subagents; the rules migration depends on native user-level `paths:` rules loading on Write. Both are tested before anything is built on them.

## Goal

Every git-aware artifact works from any working directory — a **Project repo**, a **Project worktree**, or an **Index repo** — and the repo carries only artifacts that do something native features and the model can't.

## Requirements

1. In an **Index repo**, `/delta-review`, `/pr-review`, `/commit-msg` and `/pr-summary` find the **Change set** themselves; with several candidates they list them and ask.
2. `/delta-review` and `/pr-review` run forked from the implementer session: no tokens in that session, findings arrive there, numbered CRITICAL…LOW with the **Change set** root on top. Optional trailing text is a focus hint.
3. Reviews run `make lint` / `make test` in the **Change set** root when the targets exist.
4. The lint/test gate runs at Stop only for edits since the last user prompt, in each edited **Project repo**'s root (worktrees anywhere included), and blocks on failure; both env opt-outs still work.
5. Language rules (Python, TypeScript, docs, tests) load natively when a matching file is read, edited or created — if gating test 0a passes; otherwise the context-rules hook stays.
6. `make mcp` registers `claude-context` (OpenAI or Ollama, asked interactively) and `context7` at user scope; re-running is safe.
7. `/refresh-references` syncs, audits, curates and re-indexes without wrapper scripts or the custom indexer.
8. Before finishing a change to behavior, interfaces, config or dependencies, Claude greps the repo's docs for changed names and fixes stale mentions.
9. README, `.claude/CLAUDE.md` Rules for Changes, `consistency-review`, settings lists and the install targets match the remaining artifacts.

## Phases

Each phase is one commit (or a few), leaving the repo working.

0. **Gating tests** — record both results in this plan before phase 2/3.
   - **0a. Native path rule on Write:** one test rule in the user-level rules dir with `paths:`; new session; Write a new matching file; confirm load (log via an `InstructionsLoaded` hook). Open issue #21858 claims user-level `paths:` is ignored.
   - **0b. Fork + Agent:** a throwaway `context: fork` command that dispatches a subagent; confirm the `Agent` tool exists and the subagent runs. Critical for the review pipeline.
1. **Hooks** — delete the `block-git-mutations` hook (and the review commands' `hooks:` frontmatter), `sync-links`, `standalone-excluded-commands`; rewrite the lint/test gate; drop install concurrency handling; add `make test`.
2. **Rules** (only if 0a passes) — move the 5 context rules into the user rules dir with `paths:`; delete the context-rules hook, its dir, its env opt-out and the rules index; switch index consumers (`learn`, `refine-plan`, review protocol, "Rules Awareness") to listing the rules dir; remove `context-rules` from both linked-dir settings lists and the install targets.
3. **Review + git** — add Change-set discovery; rewrite `/delta-review`, `/pr-review` as forked thin commands over the review protocol; delete the `-diff` variants, `/fix-review`, `REVIEW_SCOPE:`, `code-reviewer-diff`, `diff-summarizer`, all review helper scripts and the saved-review-file convention; rewrite `/commit-msg`, `/pr-summary` as forked; remove `pr-diff.sh` from `sandbox.excludedCommands`.
4. **References + MCP** — add the MCP installer + `make mcp`; delete the repo-root `.mcp.json`, `enabledMcpjsonServers`, the custom indexer + its wrappers, the sync/audit wrappers, `python-dotenv`; move `index_codebase` from `ask` to `allow`; update `/refresh-references` and both skill READMEs.
5. **Cleanup** — delete `init-rules`, `refine-rules` and their shared fragments; fold the analyze-project fragment into `/explore:overview`; replace the docs-agent mandate in `general.md`; update `.claude/CLAUDE.md` Rules for Changes, `consistency-review`, README.

## Module Map

- **Lint/test gate** (Stop hook)
  - **Interface:** in — Stop event JSON (`transcript_path`, `stop_hook_active`), env `DOTCLAUDE_DISABLE_AUTO_LINT` / `DOTCLAUDE_DISABLE_AUTO_TEST`. Out — exit 0 when nothing to do or all passed; exit 2 with make output + one-line summary on stderr when any target failed. Invariants: only Edit/Write calls after the last real user message (tool-result entries are not prompts) count; gitignored files are ignored; each file maps to its git root; files outside a git repo are skipped; per root, `lint`/`test` run only when the Makefile at that root defines them; `stop_hook_active` → exit 0.
  - **Depth:** deep — transcript parsing, prompt boundary, root mapping and target probing behind one exit code. Without it every implementation skill re-states "run lint/test in each repo".
- **Change-set discovery** (shared prompt fragment)
  - **Interface:** produces exactly one **Change set** — root path, diff base, changed + untracked files, current branch — for a mode (delta: uncommitted vs HEAD; PR: merge-base with the default or given base branch, fetching it first). Candidates: cwd's git root, cwd's direct children that are git repos, and every `git worktree list` entry of those. One candidate with changes → use it; several → list and ask; none → say so and stop.
  - **Depth:** deep — hides **Index repo** / worktree / cwd layout from four commands.
- **Review pipeline** (`/delta-review`, `/pr-review`, review protocol, `code-reviewer` agent)
  - **Interface:** command + optional focus hint → forked, background review → findings only, numbered, CRITICAL…LOW, paths relative to the **Change set** root printed on top. Read-only. Standards: the user rules matching the changed paths, pasted verbatim into each batch reviewer. Docs-staleness check kept.
  - **Depth:** existing module made shallower on purpose — one scope, one agent, no scripts, no file handoff.
- **Change describers** (`/commit-msg`, `/pr-summary`)
  - **Interface:** forked, foreground (`background: false`) → one message per invocation for the chosen **Change set**; `/commit-msg` keeps `model: haiku` and its single-code-block output.
  - **Depth:** shallow by design; the fork replaces the summarizer agent as the context-isolation seam.
- **MCP installer** (`make mcp`)
  - **Interface:** interactive; asks embedding provider. OpenAI → key read at launch from this repo's `.env` via an absolute path written at install time (no key in config). Ollama → asks model and host (defaults `qwen3-embedding:4b`, `http://127.0.0.1:11434`). Both → `MILVUS_ADDRESS=localhost:19531`, `@latest`. Registers `claude-context` and `context7` with `claude mcp add --scope user`; removes an existing entry first (idempotent).
  - **Depth:** moderate — hides `claude mcp` invocation and per-provider env.
- **Path-scoped rules** (native, config only)
  - **Interface:** each user rule file carries `paths:` globs (or none = always loaded); filename + H1 name the topic. Consumers find rules by listing the rules dir.
  - **Depth:** replaces a hook, a registry and two sync rules with frontmatter.
- **Reference refresh** (`/refresh-references`)
  - **Interface:** unchanged steps; calls the sync/audit script with a skill path directly; indexes via `mcp__claude-context__index_codebase` then `get_indexing_status`.
  - **Depth:** existing; loses its wrappers and the custom MCP client.

## Key Decisions

- **Hooks only for silent or costly failures not covered by permissions/sandbox:** settles dropping the git-mutation guard, link sync and the compound-command guard; keeps the excluded-commands session notice.
- **Lint/test gate is a deliberate exception:** valued as a deterministic gate for unplanned work; opt-outs kept for never-linted monoliths.
- **Custom review over built-in `/code-review`:** used often, improvable via `learn`; the built-in is a bundled skill with no editable file.
- **One slash command per review target:** typing a target argument is the cost being avoided; `-diff` variants unused.
- **Reviewer stays blind to implementer context:** independent read; the implementer session triages with design context. A focus hint steers without anchoring.
- **One Change set per run:** keeps findings and messages one-to-one with a repo; several candidates → ask.
- **No saved review file, no `/fix-review`:** findings arrive in the implementer session, which decides what to fix.
- **Per-module intent rules removed:** unused for months; no community equivalent across 13 reference repos; intent lives in `grill-with-docs` glossary + ADRs.
- **Semantic search kept, installed globally:** value to be measured in a separate task; `@latest` deliberate.
- **Docs rule mandates the outcome, not the agent:** the old agent mandate fixed real under-triggering, so the trigger stays imperative.
- **Both `effortLevel` entries kept:** the per-model one is written by Claude Code.
- **Commands stay commands** unless rewritten anyway; `plan/*`, `explore/*`, `skill-review`, plan template unchanged.

## Testing Strategy

- **Lint/test gate — automated.** Bash test script run by a new `make test`; no prior test art in the repo. Each case builds temp git repos with Makefiles that record which targets ran, plus a transcript JSONL fixture, then pipes Stop JSON to the hook and asserts exit code and targets run. Behaviors:
  - edits only before the last user prompt → nothing runs, exit 0
  - edits in two **Project repos** → each repo's own targets run
  - edit in a **Project worktree** outside cwd → that worktree's targets run
  - gitignored file only → nothing runs
  - target missing → skipped; other target still runs
  - a target fails → exit 2, output on stderr
  - each opt-out env var skips its target; `stop_hook_active` → exit 0
- **Gating tests 0a, 0b — manual**, results recorded in this plan.
- **Change-set discovery, review, describers — manual scenarios:** an **Index repo** (plain folder) with two **Project repos**, one with a **Project worktree** outside it; run each command; verify the ask-when-several path, the forked review's findings arriving in-session, and lint/test output in the review.
- **MCP installer — manual:** run once per provider, check `claude mcp list` and a `search_code` call from a non-dotclaude cwd.

## Out of Scope

- Measuring semantic search vs. grep — separate task, prompt in `.scratch/measure-semantic-search.md`.
- Converting remaining commands to skills; packaging as a plugin.
- Collapsing the per-dir `Read(...)` / `allowRead` lists into one wildcard.

## Notes & Sources

- Baseline and full decision log: `.scratch/simplification-baseline.md` (Decisions 1–16).
- Command files accept skill frontmatter except `name`/`paths`, incl. `context: fork`, `background: false` — https://code.claude.com/docs/en/skills.md
- Subagents may nest up to 3 layers by default; fork-skill `Agent` access not documented — https://code.claude.com/docs/en/sub-agents.md
- Path rules load on Read/Write/Edit; Write/Edit fix in 2.1.288; user-level `paths:` concern #21858 — https://code.claude.com/docs/en/memory.md
- Built-in `/code-review` behavior compared — https://code.claude.com/docs/en/code-review-local.md
