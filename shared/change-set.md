## Find the Change Set

Work on exactly one **Change set**: the changes in one Project repo or Project worktree. The working directory may be a Project repo, a Project worktree, or an Index repo (a folder whose direct children are Project repos), so find the candidates yourself — never assume the working directory is the repo.

### 1. Collect candidates

- The working directory's git root: `git rev-parse --show-toplevel` (skip if not in a repo).
- Each direct child of the working directory that is a git repo (has a `.git` file or directory).
- Every worktree of each repo found: `git -C <repo> worktree list --porcelain` — worktrees can live anywhere on disk.

Deduplicate by path.

### 2. Keep candidates with changes

- **Delta mode:** `git -C <root> status --porcelain` is non-empty.
- **PR mode:** the root is on a branch ahead of its base. The base is the branch named in the arguments, else the remote default branch (`git -C <root> symbolic-ref --short refs/remotes/origin/HEAD`, minus `origin/`), else whichever of `main`/`master` exists on `origin`. Ahead means `git -C <root> rev-list --count origin/<base>..HEAD` is above 0.

### 3. Pick one

- If the arguments name a candidate (path or directory name), use it.
- Otherwise, one candidate left → use it.
- Several → stop. Reply only with a numbered list of their paths (and branch), and ask the user to re-run the command with the path or name of the one they want.
- None → say there are no changes to work on, and stop.

### 4. Gather the overview

Run every command against the chosen root with `git -C <root>`; never `cd`.

- **CHANGE_SET_ROOT** — the chosen root path.
- **CURRENT_BRANCH** — `git -C <root> branch --show-current`.
- **DIFF_BASE**:
  - Delta mode: `HEAD`.
  - PR mode: first refresh the base with `git -C <root> fetch origin <base>` as its own Bash call (if it fails, say so and continue on local refs), then `git -C <root> merge-base HEAD origin/<base>`.
- **Changed files** — `git -C <root> diff --stat <DIFF_BASE>`.
- **Untracked files** — `git -C <root> ls-files --others --exclude-standard`.
- **Commits** (PR mode) — `git -C <root> log --oneline <DIFF_BASE>..HEAD`.

Read per-file diffs on demand with `git -C <root> diff <DIFF_BASE> -- <file>`; read untracked files directly.
