---
name: delta-review
description: Technical code review comparing uncommitted local changes against the latest commit on the current branch
disable-model-invocation: true
---

Perform technical code review on uncommitted local changes (compared to the latest commit on the current branch).

## Review Philosophy

- Simplicity is the ultimate sophistication - every line should justify its existence
- Code is read far more often than it's written - optimize for readability
- The best code is often the code you don't write
- Elegance emerges from clarity of intent and economy of expression

## Step 1: See What Changed

See which tracked files changed and how many lines were added/deleted:
```bash
git diff --stat HEAD
```

See the full line-by-line diff of all tracked changes:
```bash
git diff HEAD
```

See untracked files not covered by `.gitignore` — new files not yet staged:
```bash
git ls-files --others --exclude-standard
```

## Step 2: Load Standards

Read `~/.claude/index/rules.md` and load the applicable rule files for the changed file types.

## Step 3: Run Static Analysis

Run these two commands separately and exactly as written before manual review — their output informs what to look for:

```bash
make lint
```

```bash
make test
```

Note any failures. These are objective findings to include in the review.

## Step 4: Read Changed Files

Read each changed and new file in its entirety (not just the diff) to understand full context.

## Step 5: Analyze

For each changed file or new file, analyze for:

1. **Logic Errors**
   - Off-by-one errors
   - Incorrect conditionals
   - Missing error handling
   - Race conditions

2. **Security Issues**
   - Insecure data handling
   - Exposed secrets or API keys

3. **Performance Problems**
   - Inefficient algorithms
   - Memory leaks
   - Unnecessary computations

4. **Code Quality**
   - Violations of DRY principle
   - Redundant variable access (e.g., calling `dict.get("key")` multiple times instead of reusing extracted variable)
   - Overly complex functions
   - Poor naming
   - Unnecessary intermediate variables

5. **Adherence to Codebase Standards**
   - Adherence to standards loaded in Step 2

## Verify Issues Are Real

- Run specific tests for issues found
- Confirm type errors are legitimate
- Validate security concerns with context

## Step 6: Check Documentation

For each changed file, check whether documentation needs to be updated:

- Look for `README.md`, `docs/`, `CHANGELOG.md`, or other documentation files in the repo
- If new public APIs, CLI flags, config options, environment variables, or user-facing behaviors were added/removed/renamed, check if the docs reflect them
- If any docs are stale or missing coverage of the changes, flag it as a 🟡 MEDIUM issue

## Output Format

Save a new file to `.claude/.code-reviews/[current-branch-name]--delta--yyyy-mm-dd--HH-MM.md`

**List issues ordered by severity: 🔴 CRITICAL first, then 🟠 HIGH, 🟡 MEDIUM, and 🔵 LOW last. Number them sequentially starting from 1. For each issue found, use this format:**

### #1 🔴 CRITICAL | [path/to/file.py:42](../../path/to/file.py#L42) — One-line description

**Why this is a problem:** Explanation of why this is a problem and what impact it has.

**Suggested fix:** How to fix it, with code examples if helpful.

---

Use severity indicators:
- 🔴 **CRITICAL** — Runtime crashes, security vulnerabilities, data loss
- 🟠 **HIGH** — Significant bugs that will cause incorrect behavior
- 🟡 **MEDIUM** — Issues that should be fixed but won't cause immediate failures
- 🔵 **LOW** — Minor improvements, style issues with functional impact

Separate each issue with a horizontal rule (`---`).

If no issues found: "Code review passed. No technical issues detected."

## Important

- Be specific (line numbers, not vague complaints)
- Focus on real bugs, not style
- Suggest fixes, don't just complain
- Flag security issues as CRITICAL
- Do not list recommendations - only report actual issues
