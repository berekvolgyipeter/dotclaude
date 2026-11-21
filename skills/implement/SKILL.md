---
name: implement
description: Implement a plan, a change settled in the conversation, or a short instruction test-first — load the context, sequence the work, build via the tdd red-green loop, test, review, and verify against the goal. Use for a change that warrants a review and a final check against its goal; for a single behavior or bug, use tdd.
argument-hint: "[@plan-file | @change-folder | instruction]"
---

# Implement

Build the change below in code.

<request>
$ARGUMENTS
</request>

Read `~/.claude/shared/meet-the-user.md` and follow it whenever you ask the user something or report to them.

## 1. Pick the Input

Use the first that applies:

1. **A plan** — a plan file, or a change folder holding one, named in the request. When the folder holds one plan per repo, build only the one the request names; if it names none, ask which before anything else, since nothing can start without it. Work inside that plan's repo: test, lint and review all run there. Follow its Requirements and Module Map, and whichever of Before You Start, Phases, Key Decisions, Testing Strategy, Deferred to Implementation and Out of Scope it includes. The user confirmed its interfaces (Module Map) and the seams and behaviors to test (Testing Strategy) while it was written: treat those as approved and don't ask again. When the plan's Execution Record has entries but no `Complete` entry, an earlier run was cut short: read the record and the changes against the base (from Before You Start, else the branch's merge-base with the default branch), work out what is already built, and continue from there rather than starting over.
2. **The conversation** — a change discussed and settled in this session. Build from it; don't re-interview the user for what you already have.
3. **The request alone** — a short instruction.

If there is no input at all, ask what to build and stop.

Size a bare instruction before building: scan the area it touches, then pick its route. Whether behavior changes decides it, not the file count.

- **Trivial** — no behavior change (a typo, a rename, config that changes no behavior). Build it directly without asking anything, run step 5, and report as in step 7; skip the todo list, `tdd` and the review.
- **Large** — cross-cutting, architectural decisions, or touching auth, payments or migrations. Recommend planning it with `write-plan` first, in the opening message at the end of step 2; if the user chooses to plan, stop there.
- **Anything between** — go on as below.

Name the goal — what the user wants to be true once the work ships. Take it from the plan's Goal section or the conversation. Every later check is against it.

## 2. Load

- If the plan has an Origin line, read the design docs it links — they hold the goal and what was set aside.
- Read `~/.claude/shared/planning-context.md` and follow its Glossary and ADRs and Rules sections.
- Explore the codebase: the modules and interfaces the change touches — a plan names no file paths, so map it onto the real files — and the existing tests and patterns to mirror, starting with the prior art a plan names.
- Fetch the documentation URLs a plan references, and research further if the context is still not enough to start.

Now settle everything the input leaves open in one opening message, so the rest of the run needs no answers:

- for a large instruction, whether to plan it first;
- the goal, confirmed in one line, when it comes from a bare instruction or the conversation left it vague;
- when no seams are agreed yet (by a plan's Testing Strategy or in the conversation), the seams to test — each with a one-line note on what it catches and what it misses — and the main behaviors there, which the `tdd` skill would otherwise ask mid-build.

Once answered, treat them as approved, as with a plan. With nothing left open, ask nothing.

## 3. Sequence

ULTRATHINK about dependencies and order:

- Set up what Before You Start asks for (branch, base) first.
- With Phases, work phase by phase, leaving the system working after each; within a phase, order the modules so each builds on what it depends on — no backtracking. Where the dependencies leave a choice, take the riskiest work first, so a wrong assumption surfaces before much is built on it.
- For each seam to test, list the behaviors to drive out, smallest first.
- Create a TodoWrite list: one item per behavior at a tested seam, one per change for the rest.

## 4. Build

Invoke the `tdd` skill and drive each seam to test through its red-green loop, one behavior at a time. Build the rest directly. Throughout, mirror the existing tests and patterns rather than inventing new ones, and run the type checker and the test files you touched regularly; the full suite runs in step 5. A seam that appears mid-build — a module nobody agreed to test — gets no test now: build it and record it as an untested seam, with the test you recommend.

**Scope.** Build only what was asked. Add a guard, retry, fallback, option or abstraction that neither the plan nor the request names only when leaving it out lets real harm through, or when adding it later would be expensive — stored data or its format, a public interface, money, security. Record each one you weigh and leave out as considered, not built. When you replace code whose callers are all in this repo, update the callers and delete the old version rather than keeping it as a wrapper.

**Side effects.** Before marking a todo complete, trace what the change touches beyond its own files: callbacks, middleware, observers and hooks up to two levels out, and any other entry point that already exposes the changed behavior. Read the code, not the docs. What worked through those paths must still work, so run or update the tests that cover them. When no test goes through the real chain rather than mocks, and the chain is not a seam the user agreed to test, record the gap rather than writing an unagreed test. A change that touches none of them passes at once.

**Stuck.** When two fixes for the same failing check have not worked, stop patching: name the assumption both relied on and check it. If a third fails, treat it as a large mismatch.

**Mismatch.** When the code contradicts the plan or the settled input, size the mismatch:

- **Small** — a renamed function, a missing helper, an extra parameter. Adapt, and record it as a deviation.
- **Large** — it would change the goal, an agreed interface, a Key Decision or the scope. Stop and ask the user before going on: say what you found and recommend an answer.

**Record.** Record each call you make for the user the moment you make it — a deviation, the answer to a deferred item, a skipped review finding, something considered and not built, a finished phase — as `<what> — <why> — <cost if wrong>`: in the plan's Execution Record when there is a plan, otherwise in a list for the final report. The cost line tells the user which calls to double-check; with a plan, writing it straight away also keeps the record if the session is cut short.

## 5. Test and Lint

- Run the full test suite — `make test` if the project defines it, otherwise its documented runner (`pytest`, `npm test`, `cargo test`, etc.). Fix failures by fixing code, never by weakening or deleting tests.
- Run the linter — `make lint` if defined, otherwise the documented lint, format and type-check commands — and fix every error.
- Re-run until both pass clean.
- A failure that also happens without your change is pre-existing: record it and leave it alone. Check it at the base in a separate worktree, or by confirming it touches nothing you changed — never stash, reset or switch branches, since the uncommitted work is the user's to review. The one exception is the review's `git stash create` snapshot: it only records the work and leaves the working tree and index untouched.
- When the project has neither a test runner nor a linter, record that and carry it into the report.

## 6. Review

Review in at most two rounds, so the review cannot loop.

1. **First round.** Invoke the `review-changes` skill with the repo's root, then the first argument that applies, so phases already committed are included, and wait for its findings — it runs in the background:
   - `since <base>` with the base from Before You Start;
   - `since <merge-base>` — the branch's merge-base with the default branch — when earlier phases of this plan are already committed;
   - no argument: the uncommitted changes against the last commit.
2. **Fix.** Judge each finding against the goal and the plan. Fix every bug that holds up, taking the snapshot `review-changes` describes first. A judgement call you may skip — record it with a one-line reason. Then repeat step 5.
3. **Second round** — only when the first round brought fixes. Invoke `review-changes` with `<root> since <snapshot>`. Fix and repeat step 5 as in the first round, then stop reviewing: record every finding still open for the final report.

## 7. Verify and Report

- Re-read the goal first and confirm the result reaches it; then confirm every requirement is met and nothing out of scope crept in.
- Confirm each agreed behavior is covered by a test at its seam.
- Confirm each item the plan deferred to implementation got an answer.
- With a plan, close its Execution Record with a `Complete` entry: the final test and lint results, and whether the goal is reached.
- Report to the user whether the goal is reached, any untested seams with their recommended tests, the review findings still open after the second round, the other recorded calls with the costliest-if-wrong first, and anything left for them to do. End the report with "Run `validate` next" — it checks the change against its goal independently and runs it for real.
