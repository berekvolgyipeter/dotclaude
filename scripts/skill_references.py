#!/usr/bin/env python3
"""Syncs and audits the reference repos listed in a skill's references/catalog.json.

Usage: skill_references.py {sync|audit} /path/to/skill

Each catalog entry has `github`, `local_path`, and an optional `sparse` list of
non-cone sparse-checkout patterns; without `sparse` the repo is checked out in full.
"""

import json
import re
import subprocess
import sys
from collections import Counter
from dataclasses import dataclass
from pathlib import Path

REFERENCES_ROOT = Path("~/.claude/skills-references").expanduser()


def git(dest: Path, *args: str) -> str:
    # quotePath=false keeps non-ASCII paths unescaped in ls-files/ls-tree output.
    return subprocess.run(
        ["git", "-C", str(dest), "-c", "core.quotePath=false", *args],
        check=True,
        capture_output=True,
        text=True,
    ).stdout


@dataclass(frozen=True)
class CatalogRepo:
    github: str
    local_path: Path
    sparse: tuple[str, ...]


def load_catalog(skill_dir: Path) -> list[CatalogRepo]:
    entries = json.loads((skill_dir / "references" / "catalog.json").read_text())
    return [
        CatalogRepo(
            github=e["github"],
            local_path=Path(e["local_path"]).expanduser(),
            sparse=tuple(e.get("sparse", ())),
        )
        for e in entries["repos"]
    ]


def sync_repo(repo: CatalogRepo) -> None:
    dest = repo.local_path
    url = f"https://github.com/{repo.github}.git"

    if (dest / ".git").is_dir():
        # An empty index means an earlier first sync stopped before its checkout.
        needs_checkout = not git(dest, "ls-files").strip()
        print(f"{'Resuming' if needs_checkout else 'Updating'} {repo.github}...")
        # Keeps clones working after an upstream rename.
        git(dest, "remote", "set-url", "origin", url)
        if not needs_checkout:
            git(dest, "pull", "--quiet")
    else:
        needs_checkout = True
        print(f"Cloning {repo.github}...")
        dest.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(
            [
                "git",
                "clone",
                "--quiet",
                "--depth=1",
                "--filter=blob:none",
                "--no-checkout",
                url,
                str(dest),
            ],
            check=True,
            capture_output=True,
            text=True,
        )

    # Reapplied on every run so pattern changes in the catalog reach existing clones.
    if repo.sparse:
        git(dest, "sparse-checkout", "set", "--no-cone", *repo.sparse)
    else:
        git(dest, "sparse-checkout", "disable")

    # Checking out after the patterns are set fetches only the blobs they select.
    if needs_checkout:
        git(dest, "checkout", "--quiet")


def sync(skill_dir: Path) -> None:
    failed = []
    for repo in load_catalog(skill_dir):
        try:
            sync_repo(repo)
        except subprocess.CalledProcessError as e:
            failed.append(repo.github)
            print(f"FAILED {repo.github}: {e.stderr.strip()}", file=sys.stderr)
    if failed:
        sys.exit(f"Sync failed for: {', '.join(failed)}")
    print("Done — all reference repos are synced.")


def pattern_regex(core: str) -> re.Pattern:
    tokens = re.split(r"(\*\*/|\*\*|\*|\?)", core)
    # `**/` also matches zero directories, as in gitignore syntax.
    wildcards = {"**/": "(?:.*/)?", "**": ".*", "*": "[^/]*", "?": "[^/]"}
    return re.compile("".join(wildcards.get(t, re.escape(t)) for t in tokens))


def pattern_matches(pattern: str, paths: list[str]) -> bool:
    """True if the sparse-checkout pattern matches at least one path in the tree."""
    pattern = pattern.lstrip("!")
    dir_only = pattern.endswith("/")
    core = pattern.strip("/")
    anchored = pattern.startswith("/") or "/" in core
    regex = pattern_regex(core)
    for path in paths:
        parts = path.split("/")
        # A directory pattern matches a proper prefix only; a file pattern may match the full path.
        last = len(parts) - 1 if dir_only else len(parts)
        if anchored:
            candidates = ["/".join(parts[:i]) for i in range(1, last + 1)]
        else:
            candidates = parts[:last]
        if any(regex.fullmatch(c) for c in candidates):
            return True
    return False


def top_level(path: str) -> str:
    head, sep, _ = path.partition("/")
    return head + "/" if sep else head


def checkout_counts(dest: Path) -> tuple[Counter[str], Counter[str]]:
    """Files per top-level entry: (checked out, excluded by the sparse checkout)."""
    included: Counter[str] = Counter()
    excluded: Counter[str] = Counter()
    # `S` marks index entries hidden by the sparse checkout.
    for line in git(dest, "ls-files", "-t").splitlines():
        tag, path = line.split(" ", 1)
        (excluded if tag == "S" else included)[top_level(path)] += 1
    return included, excluded


def print_entries(dest: Path, previous: list[str] | None) -> list[str]:
    included, excluded = checkout_counts(dest)
    entries = sorted(set(included) | set(excluded))
    print("- top-level entries (checked out / excluded files):")
    for entry in entries:
        mark = " NEW" if previous is not None and entry not in previous else ""
        print(f"  - {entry} {included[entry]}/{excluded[entry]}{mark}")
    for entry in sorted(set(previous or []) - set(entries)):
        print(f"  - {entry} REMOVED upstream")
    return entries


def audit_repo(repo: CatalogRepo, previous: list[str] | None) -> list[str] | None:
    dest = repo.local_path
    print(f"\n## {repo.github}")
    if not (dest / ".git").is_dir():
        print("- NOT CLONED — run sync first")
        return None

    print(f"- last upstream commit: {git(dest, 'log', '-1', '--format=%cs').strip()}")
    print(f"- checkout: {'sparse' if repo.sparse else 'FULL'}")
    if repo.sparse:
        paths = git(dest, "ls-tree", "-r", "--name-only", "HEAD").splitlines()
        for pattern in repo.sparse:
            if not pattern_matches(pattern, paths):
                print(f"- STALE pattern (matches nothing): {pattern}")
    return print_entries(dest, previous)


def print_orphans(skill: str, repos: list[CatalogRepo]) -> None:
    skill_root = REFERENCES_ROOT / skill
    if not skill_root.is_dir():
        return
    known = {r.local_path for r in repos}
    for clone in sorted(skill_root.iterdir()):
        if clone not in known:
            print(f"\nORPHAN clone not in catalog: {clone}")


def audit(skill_dir: Path) -> None:
    skill = skill_dir.resolve().name
    snapshot_path = REFERENCES_ROOT / ".audit" / f"{skill}.json"
    snapshot = json.loads(snapshot_path.read_text()) if snapshot_path.exists() else {}

    print(f"# Reference audit — {skill}")
    if not snapshot:
        print("(no previous audit — NEW/REMOVED markers start from the next run)")

    repos = load_catalog(skill_dir)
    new_snapshot = {}
    for repo in repos:
        previous = snapshot.get(repo.github)
        try:
            entries = audit_repo(repo, previous)
        except subprocess.CalledProcessError as e:
            print(f"- FAILED: {e.stderr.strip()}")
            # Keeping the old entries stops the next audit from marking everything NEW.
            entries = previous
        if entries is not None:
            new_snapshot[repo.github] = entries
    print_orphans(skill, repos)

    snapshot_path.parent.mkdir(parents=True, exist_ok=True)
    # Written via rename so an interrupted audit never leaves a corrupt snapshot.
    tmp_path = snapshot_path.with_suffix(".tmp")
    tmp_path.write_text(json.dumps(new_snapshot, indent=2))
    tmp_path.replace(snapshot_path)


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] not in ("sync", "audit"):
        sys.exit(__doc__)
    {"sync": sync, "audit": audit}[sys.argv[1]](Path(sys.argv[2]).expanduser())
