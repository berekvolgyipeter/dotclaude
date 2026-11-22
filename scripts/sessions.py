#!/usr/bin/env python3
"""Finds Claude Code session transcripts for a scope, writes compact outlines of them and counts their friction.

Usage:
  sessions.py find --session ID | --root DIR --branch NAME | --folder DIR | --since ISO_TIME
      one "<id>\t<start time>\t<start folder>\t<transcript>" line per session, oldest first
  sessions.py outline --out DIR [--view full|human|harness] TRANSCRIPT...
      one "<outline path>\t<size in bytes>" line per transcript; human keeps the main session's messages, replies,
      interruptions, skill and agent calls and file edits; harness keeps everything but the replies
  sessions.py signals TRANSCRIPT...
      a tab-separated header, one row per session (its subagents included), then total and average rows

Runs on Python 3.9+ with the standard library only.
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from dataclasses import dataclass
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path

from transcript import (
    EDITING_TOOLS,
    LineKind,
    OutlineLine,
    SessionOutliner,
    edited_paths,
    human_text,
    read_entries,
    single_line,
)

MIN_HUMAN_MESSAGES = 2
HUMAN_VIEW_TOOLS = ("Skill", "Agent", *EDITING_TOOLS)
SANDBOX_BLOCKS_COLUMN = "sandbox_blocks"
INTERRUPTS_COLUMN = "interrupts"
SIGNAL_COLUMNS = ("prompts", "denials", "hook_rejections", "failures", SANDBOX_BLOCKS_COLUMN, INTERRUPTS_COLUMN)


class SessionNotFoundError(Exception):
    pass


class OutlineView(str, Enum):
    """Which outline lines a reader gets: all of them, the human side, or the harness side."""

    FULL = "full"
    HUMAN = "human"
    HARNESS = "harness"

    def keeps(self, line: OutlineLine) -> bool:
        if self is OutlineView.HUMAN:
            is_human_side = line.kind in (LineKind.HUMAN, LineKind.REPLY, LineKind.INTERRUPTED)
            return is_human_side or line.tool_name in HUMAN_VIEW_TOOLS
        return self is OutlineView.FULL or line.kind is not LineKind.REPLY

    @property
    def keeps_subagents(self) -> bool:
        return self is not OutlineView.HUMAN


@dataclass
class Session:
    """One top-level session: its transcript, its entries and its subagents' entries."""

    transcript: Path
    entries: list[dict]
    subagent_entries: list[dict]

    @classmethod
    def load(cls, transcript: Path) -> Session:
        subagent_entries = [entry for path in subagent_transcripts(transcript) for entry in read_entries(path)]
        return cls(transcript=transcript, entries=read_entries(transcript), subagent_entries=subagent_entries)

    @property
    def start(self) -> str:
        return next((str(entry["timestamp"]) for entry in self.entries if entry.get("timestamp")), "")

    @property
    def start_folder(self) -> str:
        return next((str(entry["cwd"]) for entry in self.entries if entry.get("cwd")), "")

    def has_worked_in(self, root: str, branch: str) -> bool:
        return any(
            entry.get("gitBranch") == branch and is_under(str(entry.get("cwd", "")), root) for entry in self.entries
        )

    def has_edited_under(self, folder: str) -> bool:
        return any(is_under(path, folder) for path in edited_paths(self.entries + self.subagent_entries))

    def has_activity_after(self, cutoff: datetime) -> bool:
        return any(parse_time(str(entry["timestamp"])) > cutoff for entry in self.entries if entry.get("timestamp"))

    @property
    def is_trivial(self) -> bool:
        return sum(1 for entry in self.entries if human_text(entry) is not None) < MIN_HUMAN_MESSAGES


def subagent_transcripts(transcript: Path) -> list[Path]:
    return sorted((transcript.parent / transcript.stem / "subagents").glob("agent-*.jsonl"))


def describe_subagent(subagent: Path) -> str:
    metadata_path = subagent.with_name(f"{subagent.stem}.meta.json")
    metadata = json.loads(metadata_path.read_text()) if metadata_path.exists() else {}
    agent_id = subagent.stem.removeprefix("agent-")
    description = single_line(metadata.get("description", ""))
    return f"## Subagent {agent_id}: {description} ({single_line(metadata.get('agentType', 'unknown type'))})"


def outline_lines(transcript: Path, view: OutlineView) -> list[str]:
    return [line.text for line in SessionOutliner().outline(read_entries(transcript)) if view.keeps(line)]


def indent_subagent_line(text: str) -> str:
    return "\n".join(f"  {part}" for part in text.split("\n"))


def outline_session(transcript: Path, view: OutlineView) -> list[str]:
    lines = outline_lines(transcript, view)
    if not view.keeps_subagents:
        return lines
    for subagent in subagent_transcripts(transcript):
        lines += ["", describe_subagent(subagent)]
        lines += [indent_subagent_line(text) for text in outline_lines(subagent, view)]
    return lines


def write_outlines(transcripts: list[Path], out_dir: Path, view: OutlineView) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    for transcript in transcripts:
        outline_path = out_dir / f"{transcript.stem}.md"
        outline_path.write_text("\n".join(outline_session(transcript, view)) + "\n")
        print(f"{outline_path}\t{outline_path.stat().st_size}")


def count_signals(transcript: Path) -> Counter[str]:
    """The session's signals, its subagents' included, keyed by signals column."""
    counts: Counter[str] = Counter()
    for path in [transcript, *subagent_transcripts(transcript)]:
        outliner = SessionOutliner()
        lines = outliner.outline(read_entries(path))
        counts.update(outcome.value for outcome in outliner.outcomes)
        counts[SANDBOX_BLOCKS_COLUMN] += sum(1 for line in lines if line.kind is LineKind.SANDBOX)
        counts[INTERRUPTS_COLUMN] += sum(1 for line in lines if line.kind is LineKind.INTERRUPTED)
    return counts


def print_signals(transcripts: list[Path]) -> None:
    print("\t".join(["session", *SIGNAL_COLUMNS]))
    total: Counter[str] = Counter()
    for transcript in transcripts:
        counts = count_signals(transcript)
        total.update(counts)
        print("\t".join([transcript.stem, *(str(counts[column]) for column in SIGNAL_COLUMNS)]))
    print("\t".join(["total", *(str(total[column]) for column in SIGNAL_COLUMNS)]))
    print("\t".join(["average", *(f"{total[column] / len(transcripts):.1f}" for column in SIGNAL_COLUMNS)]))


def session_transcripts() -> list[Path]:
    return sorted((Path.home() / ".claude" / "projects").glob("*/*.jsonl"))


def load_sessions() -> list[Session]:
    sessions = [Session.load(transcript) for transcript in session_transcripts()]
    return sorted(sessions, key=lambda session: session.start)


def is_under(path: str, root: str) -> bool:
    # Resolving folds `..` segments and symlinks, such as `~/.claude/` links into the repo they point at.
    if not Path(path).is_absolute():
        return False
    resolved_path, resolved_root = Path(path).resolve(), Path(root).resolve()
    return resolved_path.is_relative_to(resolved_root)


def parse_time(text: str) -> datetime:
    moment = datetime.fromisoformat(text.replace("Z", "+00:00"))
    return moment if moment.tzinfo else moment.replace(tzinfo=timezone.utc)


def find_sessions_by_id(session_id: str) -> list[Session]:
    matches = [Session.load(transcript) for transcript in session_transcripts() if transcript.stem == session_id]
    if not matches:
        raise SessionNotFoundError(f"no session with id {session_id}")
    return matches


def find_task_sessions(root: str, branch: str) -> list[Session]:
    return [
        session
        for session in load_sessions()
        if session.has_worked_in(root, branch)
        or (not is_under(session.start_folder, root) and session.has_edited_under(root))
    ]


def find_change_sessions(folder: str) -> list[Session]:
    return [session for session in load_sessions() if session.has_edited_under(folder)]


def find_recent_sessions(cutoff: datetime) -> list[Session]:
    recent_transcripts = [transcript for transcript in session_transcripts() if last_written(transcript) > cutoff]
    sessions = sorted(
        (Session.load(transcript) for transcript in recent_transcripts), key=lambda session: session.start
    )
    return [session for session in sessions if session.has_activity_after(cutoff) and not session.is_trivial]


def last_written(transcript: Path) -> datetime:
    """When the session or one of its subagents last wrote to disk — an upper bound on its last activity."""
    newest_write_time = max(path.stat().st_mtime for path in [transcript, *subagent_transcripts(transcript)])
    return datetime.fromtimestamp(newest_write_time, tz=timezone.utc)


def non_empty_text(value: str) -> str:
    if not value.strip():
        raise argparse.ArgumentTypeError("must not be empty")
    return value


def absolute_path(value: str) -> str:
    return str(Path(non_empty_text(value)).expanduser().absolute())


def print_sessions(sessions: list[Session]) -> None:
    for session in sessions:
        print(f"{session.transcript.stem}\t{session.start}\t{session.start_folder}\t{session.transcript}")


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Find session transcripts and write outlines of them.")
    commands = parser.add_subparsers(dest="command", required=True)
    find_parser = commands.add_parser("find")
    scope = find_parser.add_mutually_exclusive_group(required=True)
    scope.add_argument("--session", type=non_empty_text)
    scope.add_argument("--root", type=absolute_path)
    scope.add_argument("--folder", type=absolute_path)
    scope.add_argument("--since", type=parse_time)
    find_parser.add_argument("--branch", type=non_empty_text)
    outline_parser = commands.add_parser("outline")
    outline_parser.add_argument("--out", type=Path, required=True)
    outline_parser.add_argument(
        "--view", type=OutlineView, choices=list(OutlineView), default=OutlineView.FULL, metavar="{full,human,harness}"
    )
    outline_parser.add_argument("transcripts", type=Path, nargs="+")
    signals_parser = commands.add_parser("signals")
    signals_parser.add_argument("transcripts", type=Path, nargs="+")
    arguments = parser.parse_args()
    if arguments.command == "find" and (arguments.root is None) != (arguments.branch is None):
        find_parser.error("--root and --branch go together")
    return arguments


def find_sessions(arguments: argparse.Namespace) -> list[Session]:
    if arguments.session is not None:
        return find_sessions_by_id(arguments.session)
    if arguments.folder is not None:
        return find_change_sessions(arguments.folder)
    if arguments.since is not None:
        return find_recent_sessions(arguments.since)
    return find_task_sessions(arguments.root, arguments.branch)


def main() -> int:
    arguments = parse_arguments()
    try:
        if arguments.command == "find":
            print_sessions(find_sessions(arguments))
        elif arguments.command == "outline":
            write_outlines(arguments.transcripts, arguments.out, arguments.view)
        else:
            print_signals(arguments.transcripts)
    except SessionNotFoundError as error:
        print(f"sessions.py: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
