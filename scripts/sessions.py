#!/usr/bin/env python3
"""Finds Claude Code session transcripts for a scope and writes compact outlines of them.

Usage:
  sessions.py find --session ID | --root DIR --branch NAME | --folder DIR | --since ISO_TIME
      one "<id>\t<start time>\t<start folder>\t<transcript>" line per session, oldest first
  sessions.py outline --out DIR TRANSCRIPT...
      one "<outline path>\t<size in bytes>" line per transcript

Runs on Python 3.9+ with the standard library only.
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

KEY_INPUT_FIELDS = ("command", "file_path", "notebook_path", "pattern", "skill", "url", "query")
MAX_HUMAN_CHARS = 4000
MAX_REPLY_CHARS = 2000
MAX_TOOL_INPUT_CHARS = 200
MAX_FAILURE_CHARS = 300
EDITING_TOOLS = ("Edit", "Write", "NotebookEdit")
MIN_HUMAN_MESSAGES = 2
USER_ENTRY = "user"
ASSISTANT_ENTRY = "assistant"
ATTACHMENT_ENTRY = "attachment"
QUEUED_COMMAND_ATTACHMENT = "queued_command"
INTERRUPTION_PREFIX = "[Request interrupted by user"
HUMAN_ORIGIN = "human"
TEXT_BLOCK = "text"
TOOL_USE_BLOCK = "tool_use"
TOOL_RESULT_BLOCK = "tool_result"
ROUTINE_PERMISSION = ("config", "accept")
UNKNOWN_TOOL_LABEL = "unknown tool"


class SessionNotFoundError(Exception):
    pass


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
            is_under(str(entry.get("cwd", "")), root) and entry.get("gitBranch") == branch for entry in self.entries
        )

    def has_edited_under(self, folder: str) -> bool:
        return any(is_under(path, folder) for path in edited_paths(self.entries + self.subagent_entries))

    def has_activity_after(self, cutoff: datetime) -> bool:
        return any(parse_time(str(entry["timestamp"])) > cutoff for entry in self.entries if entry.get("timestamp"))

    @property
    def is_trivial(self) -> bool:
        return sum(1 for entry in self.entries if human_text(entry) is not None) < MIN_HUMAN_MESSAGES


@dataclass
class SessionOutliner:
    """Turns one transcript's entries into outline lines, remembering each tool call to label its result."""

    tool_labels: dict[str, str] = field(default_factory=dict)
    lines: list[str] = field(default_factory=list)

    def outline(self, entries: list[dict]) -> list[str]:
        for entry in entries:
            self._add_entry(entry)
        return self.lines

    def _add_entry(self, entry: dict) -> None:
        time = clock_time(entry)
        content = content_of(entry)
        message = human_text(entry)
        if message is not None:
            self.lines.append(f"[{time}] HUMAN: {indent_continuation(shorten(message, MAX_HUMAN_CHARS))}")
        elif is_interruption(entry):
            self.lines.append(f"[{time}] INTERRUPTED by human")
        elif entry.get("type") == ASSISTANT_ENTRY:
            self._add_assistant_content(time, content)
        elif entry.get("type") == USER_ENTRY and isinstance(content, list):
            self._add_tool_results(time, entry, content)

    def _add_assistant_content(self, time: str, content: str | list) -> None:
        reply = text_of(content)
        if reply:
            self.lines.append(
                f"[{time}] CLAUDE ({len(reply)} chars): {indent_continuation(shorten(reply, MAX_REPLY_CHARS))}"
            )
        for block in tool_use_blocks(content):
            label = label_tool_call(block)
            self.tool_labels[block.get("id", "")] = label
            self.lines.append(f"[{time}] TOOL {label}")

    def _add_tool_results(self, time: str, entry: dict, content: list) -> None:
        for block in content:
            if block.get("type") != TOOL_RESULT_BLOCK:
                continue
            label = self.tool_labels.get(block.get("tool_use_id", ""), UNKNOWN_TOOL_LABEL)
            if block.get("is_error"):
                failure = shorten(" ".join(text_of(block.get("content") or "").split()), MAX_FAILURE_CHARS)
                self.lines.append(f"[{time}] FAILED {label}: {failure}")
            self._add_permission(time, entry, label)
        if entry.get("sandboxViolations"):
            self.lines.append(f"[{time}] SANDBOX: {json.dumps(entry['sandboxViolations'])}")

    def _add_permission(self, time: str, entry: dict, label: str) -> None:
        decision = entry.get("permissionDecision") or {}
        source, verdict = decision.get("source", ""), decision.get("decision", "")
        if source and (source, verdict) != ROUTINE_PERMISSION:
            self.lines.append(f"[{time}] PERMISSION {source} {verdict}: {label}")
        elif entry.get("toolDenialKind"):
            self.lines.append(f"[{time}] DENIED ({entry['toolDenialKind']}): {label}")


def read_entries(transcript: Path) -> list[dict]:
    # Split on newlines only: JSON lines may hold raw U+2028 or U+2029, which str.splitlines() would split on.
    entries = (parse_entry(line) for line in transcript.read_text().split("\n") if line.strip())
    return [entry for entry in entries if entry is not None]


def parse_entry(line: str) -> dict | None:
    # A live session's transcript can end in a line still being written.
    try:
        return json.loads(line)
    except json.JSONDecodeError:
        return None


def human_text(entry: dict) -> str | None:
    """The text of a message the human typed — including one queued while Claude was working — else None."""
    if entry.get("type") == USER_ENTRY and not entry.get("isMeta"):
        is_human = (entry.get("origin") or {}).get("kind") == HUMAN_ORIGIN
        return text_of(content_of(entry)) if is_human else None
    attachment = entry.get("attachment") or {}
    is_queued_human = attachment.get("type") == QUEUED_COMMAND_ATTACHMENT and (
        (attachment.get("origin") or {}).get("kind") == HUMAN_ORIGIN
    )
    return (
        text_of(attachment.get("prompt") or "") if entry.get("type") == ATTACHMENT_ENTRY and is_queued_human else None
    )


def is_interruption(entry: dict) -> bool:
    return entry.get("type") == USER_ENTRY and text_of(content_of(entry)).startswith(INTERRUPTION_PREFIX)


def clock_time(entry: dict) -> str:
    """The HH:MM part of an entry's ISO timestamp."""
    return str(entry.get("timestamp", ""))[11:16]


def content_of(entry: dict) -> str | list:
    return (entry.get("message") or {}).get("content") or ""


def tool_use_blocks(content: str | list) -> list[dict]:
    return [block for block in content if block.get("type") == TOOL_USE_BLOCK] if isinstance(content, list) else []


def text_of(content: str | list) -> str:
    if isinstance(content, str):
        return content
    return "\n".join(block.get("text", "") for block in content if block.get("type") == TEXT_BLOCK)


def shorten(text: str, limit: int) -> str:
    return text if len(text) <= limit else f"{text[:limit]}… [{len(text) - limit} more chars]"


def indent_continuation(text: str) -> str:
    """Indents every line after the first, so quoted text can never pose as an outline line of its own."""
    return text.replace("\n", "\n    ")


def single_line(text: str) -> str:
    return " ".join(text.split())


def label_tool_call(block: dict) -> str:
    name = block.get("name", "?")
    tool_input = block.get("input") or {}
    if name == "Agent":
        agent_type = tool_input.get("subagent_type", "general-purpose")
        return f"Agent: {single_line(agent_type)} — {single_line(tool_input.get('description', ''))}"
    key_input = next((tool_input[key] for key in KEY_INPUT_FIELDS if key in tool_input), None)
    detail = str(key_input) if key_input is not None else json.dumps(tool_input)
    return f"{name}: {shorten(' '.join(detail.split()), MAX_TOOL_INPUT_CHARS)}"


def edited_paths(entries: list[dict]) -> list[str]:
    paths = []
    for entry in entries:
        if entry.get("type") != ASSISTANT_ENTRY:
            continue
        for block in tool_use_blocks(content_of(entry)):
            if block.get("name") in EDITING_TOOLS:
                tool_input = block.get("input") or {}
                paths.append(str(tool_input.get("file_path") or tool_input.get("notebook_path") or ""))
    return paths


def subagent_transcripts(transcript: Path) -> list[Path]:
    return sorted((transcript.parent / transcript.stem / "subagents").glob("agent-*.jsonl"))


def describe_subagent(subagent: Path) -> str:
    meta_path = subagent.with_name(f"{subagent.stem}.meta.json")
    meta = json.loads(meta_path.read_text()) if meta_path.exists() else {}
    agent_id = subagent.stem.removeprefix("agent-")
    description = single_line(meta.get("description", ""))
    return f"## Subagent {agent_id}: {description} ({single_line(meta.get('agentType', 'unknown type'))})"


def outline_session(transcript: Path) -> list[str]:
    lines = SessionOutliner().outline(read_entries(transcript))
    for subagent in subagent_transcripts(transcript):
        lines += ["", describe_subagent(subagent)]
        subagent_lines = "\n".join(SessionOutliner().outline(read_entries(subagent))).split("\n")
        lines += [f"  {line}" for line in subagent_lines]
    return lines


def write_outlines(transcripts: list[Path], out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    for transcript in transcripts:
        outline_path = out_dir / f"{transcript.stem}.md"
        outline_path.write_text("\n".join(outline_session(transcript)) + "\n")
        print(f"{outline_path}\t{outline_path.stat().st_size}")


def session_transcripts() -> list[Path]:
    return sorted((Path.home() / ".claude" / "projects").glob("*/*.jsonl"))


def load_sessions() -> list[Session]:
    sessions = [Session.load(transcript) for transcript in session_transcripts()]
    return sorted(sessions, key=lambda session: session.start)


def is_under(path: str, root: str) -> bool:
    root = root.rstrip("/")
    return path == root or path.startswith(f"{root}/")


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
    outline_parser.add_argument("transcripts", type=Path, nargs="+")
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
        else:
            write_outlines(arguments.transcripts, arguments.out)
    except SessionNotFoundError as error:
        print(f"sessions.py: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
