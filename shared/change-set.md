## Find the Change Set

Work on exactly one change set: the changes in one git repo or worktree. The working directory may be a repo, a worktree, or a folder whose direct children are repos, so find the candidates yourself — never assume the working directory is the repo.

### 1. Collect candidates

- The working directory's git root: `git rev-parse --show-toplevel` (skip if not in a repo).
- Each direct child of the working directory that is a git repo (has a `.git` file or directory).
- Every worktree of each repo found: `git -C <repo> worktree list --porcelain` — worktrees can live anywhere on disk.

Deduplicate by path.

### 2. Read the arguments

Split the arguments into tokens:

- A token matching a candidate's path or directory name → the **repo** to use.
- In PR mode, a token naming a branch that exists on origin (`git -C <root> rev-parse --verify --quiet origin/<token>`) → the **base** branch.
- All remaining text → the **focus hint** (only commands that use one).

### 3. Keep candidates with changes

- **Delta mode:** `git -C <root> status --porcelain` is non-empty.
- **PR mode:** the root is on a branch with commits ahead of its base: `git -C <root> rev-list --count origin/<base>..HEAD` is above 0. The base is the one from the arguments, else the remote default branch (`git -C <root> symbolic-ref --short refs/remotes/origin/HEAD`, minus `origin/`), else whichever of `main`/`master` exists on origin (`git -C <root> rev-parse --verify --quiet origin/<name>`). If none resolves, stop and ask the user to name the base branch.

### 4. Pick one

- If the arguments name a candidate, use it.
- Otherwise, one candidate left → use it.
- Several → stop. Reply only with a numbered list of their paths (and branch), and ask the user to re-run the command with the path or name of the one they want.
- None → say there are no changes to work on, and stop.

### 5. Gather the overview

Address the chosen root with `git -C <root>`; never `cd`.

- **CHANGE_SET_ROOT** — the chosen root path.
- **CURRENT_BRANCH** — `git -C <root> branch --show-current`.
- **DIFF_BASE**:
  - Delta mode: `HEAD`.
  - PR mode: `git -C <root> merge-base HEAD origin/<base>`.
- **Changed files** — `git -C <root> diff --name-status -M <DIFF_BASE>`, so each file's status (added, modified, deleted, renamed) is known. In PR mode this compares the working tree, so uncommitted edits on the branch are included — the review covers what the PR will contain once they are committed.
- **Untracked files** — `git -C <root> ls-files --others --exclude-standard`.
- **Commits** (PR mode) — `git -C <root> log --oneline <DIFF_BASE>..HEAD`.

Read per-file diffs on demand with `git -C <root> diff -M <DIFF_BASE> -- <file>`; read untracked files directly. A deleted file has no current content — its diff is all there is.
