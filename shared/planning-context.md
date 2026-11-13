## Planning Context

The project knowledge every design, planning and execution step works from. Follow only the sections your caller names; when it names none, follow them all.

### 1. Glossary and ADRs

- Read the glossary and the ADRs that touch the area, found where section 1 of `~/.claude/shared/domain-docs.md` says they live.
- Use the glossary's terms in everything you write; don't drift to synonyms.
- Treat a recorded decision as settled. If your work contradicts an ADR, say so explicitly and justify it — never override it silently.
- If none of these files exist, proceed silently.

### 2. Rules

Rules without `paths:` frontmatter are already loaded, and rules with `paths:` load when you read a file that matches them. Rules for file types the work will create or change but you have not read yet are missing — list `~/.claude/rules/` and the project's `.claude/rules/`, and read each rule whose `paths:` globs match those files.

### 3. Change folder

Each change gets one folder, even when it spans several repos. Put it in the plans location:

- **Working inside a repo or worktree the change touches** → its `.claude/plans/`.
- **Working from somewhere else** (a folder holding several repos, a home or notes folder) → wherever this workspace already keeps plans: a folder the conversation names, or one its `CLAUDE.md` or existing layout points to. If nothing points anywhere, ask once.

Name the folder with a zero-padded sequential number followed by a kebab-case slug of the goal, so changes sort in creation order — e.g. `01-add-oauth-login/`, then `02-messaging/`. The number is the highest existing `NN-` prefix in the plans location, files and folders alike, plus one, or `01` when there is none. The Write tool creates the folders.

Every file in it covers exactly one repo. When the change touches one repo:

- `design.md` — the design doc
- `evidence.md` — code facts with `file:line` evidence, gathered while designing
- `plan.md` — the implementation plan
- `archived/` — documents of a dropped design

When it touches several, each file is per repo, suffixed with the repo's name: `design-<repo>.md`, `evidence-<repo>.md`, `plan-<repo>.md`. The design docs link to each other.
