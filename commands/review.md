---
name: review
description: Technical code review for quality and bugs.
disable-model-invocation: true
---

Set `BASE_BRANCH` to `$ARGUMENTS` if provided, otherwise `main`.

Perform technical code review on recently changed files.

## Review Philosophy

- Simplicity is the ultimate sophistication - every line should justify its existence
- Code is read far more often than it's written - optimize for readability
- The best code is often the code you don't write
- Elegance emerges from clarity of intent and economy of expression

## Step 1: See What Changed

Fetch the latest remote state first:
```bash
git fetch origin $BASE_BRANCH
```

See which tracked files changed and how many lines were added/deleted:
```bash
git diff --stat origin/$BASE_BRANCH
```

See untracked files not covered by `.gitignore` — new files not yet staged:
```bash
git ls-files --others --exclude-standard
```

See commit history on this branch since it forked from `$BASE_BRANCH`:
```bash
git log origin/$BASE_BRANCH..HEAD --oneline
```

## Step 2: Load Standards

Read the codebase standards relevant to the changed files:

- `.claude/CLAUDE.md` — project-wide rules
- `~/.claude/rules/code.md` — linting, typing, logging, formatting standards
- `~/.claude/rules/test.md` — testing standards

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
   - Adherence to standards documented in CLAUDE.md
   - Linting, typing, logging, and formatting standards (see ~/.claude/rules/code.md)
   - Testing standards (see ~/.claude/rules/test.md)

## Verify Issues Are Real

- Run specific tests for issues found
- Confirm type errors are legitimate
- Validate security concerns with context

## Output Format

Save a new file to `.claude/.code-reviews/[current-branch-name]--yyyy-mm-dd.md`

**Stats:**

- Files Modified: 0
- Files Added: 0
- Files Deleted: 0
- New lines: 0
- Deleted lines: 0

**List issues ordered by severity: 🔴 CRITICAL first, then 🟠 HIGH, 🟡 MEDIUM, and 🔵 LOW last. Number them sequentially starting from 1. For each issue found, use this format:**

### #1 🔴 CRITICAL | `path/to/file.py:42` — One-line description

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
