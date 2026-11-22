"""Reads one Claude Code transcript's entries: the outline lines they make, how each tool call was decided, and the
files they edited.

Runs on Python 3.9+ with the standard library only.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path

KEY_INPUT_FIELDS = ("command", "file_path", "notebook_path", "pattern", "skill", "url", "query")
MAX_HUMAN_CHARS = 4000
MAX_REPLY_CHARS = 2000
MAX_TOOL_INPUT_CHARS = 200
MAX_FAILURE_CHARS = 300
EDITING_TOOLS = ("Edit", "Write", "NotebookEdit")
USER_ENTRY = "user"
ASSISTANT_ENTRY = "assistant"
ATTACHMENT_ENTRY = "attachment"
QUEUED_COMMAND_ATTACHMENT = "queued_command"
INTERRUPTION_PREFIX = "[Request interrupted by user"
HUMAN_ORIGIN = "human"
TEXT_BLOCK = "text"
TOOL_USE_BLOCK = "tool_use"
TOOL_RESULT_BLOCK = "tool_result"
UNKNOWN_TOOL_LABEL = "unknown tool"
ACCEPT_VERDICT = "accept"
REJECT_VERDICT = "reject"
HOOK_SOURCE = "hook"
CONFIG_SOURCE = "config"
RULE_REASON = "rule"
ROUTINE_PERMISSION = (CONFIG_SOURCE, ACCEPT_VERDICT)
USER_PERMISSION_SOURCES = ("user_temporary", "user_permanent", "user_reject")
USER_REJECTED_DENIAL = "user-rejected"


class LineKind(str, Enum):
    HUMAN = "human"
    REPLY = "reply"
    TOOL = "tool"
    FAILED = "failed"
    PERMISSION = "permission"
    DENIED = "denied"
    SANDBOX = "sandbox"
    INTERRUPTED = "interrupted"


class ToolOutcome(str, Enum):
    """Who stopped or questioned a tool call; each value is the signals column it counts toward."""

    PROMPT = "prompts"
    DENIAL = "denials"
    HOOK_REJECTION = "hook_rejections"
    FAILURE = "failures"


@dataclass(frozen=True)
class PermissionDecision:
    """How a tool call was approved; a rule match means a rule the user saved earlier decided, with no prompt."""

    source: str
    verdict: str
    is_rule_match: bool

    @classmethod
    def from_entry(cls, entry: dict) -> PermissionDecision:
        decision = entry.get("permissionDecision") or {}
        return cls(
            source=decision.get("source", ""),
            verdict=decision.get("decision", ""),
            is_rule_match=decision.get("reasonType") == RULE_REASON,
        )

    @property
    def is_shown(self) -> bool:
        is_routine = (self.source, self.verdict) == ROUTINE_PERMISSION
        return bool(self.source) and not is_routine and not (self.is_rule_match and self.verdict == ACCEPT_VERDICT)

    @property
    def decider(self) -> str:
        return RULE_REASON if self.is_rule_match else self.source


@dataclass(frozen=True)
class OutlineLine:
    kind: LineKind
    text: str
    tool_name: str = ""


@dataclass
class SessionOutliner:
    """Turns one transcript's entries into outline lines, remembering each tool call to label its result."""

    tool_labels: dict[str, str] = field(default_factory=dict)
    lines: list[OutlineLine] = field(default_factory=list)
    outcomes: list[ToolOutcome] = field(default_factory=list)

    def outline(self, entries: list[dict]) -> list[OutlineLine]:
        for entry in entries:
            self._add_entry(entry)
        return self.lines

    def _add_entry(self, entry: dict) -> None:
        time = clock_time(entry)
        content = content_of(entry)
        message = human_text(entry)
        if message is not None:
            text = f"[{time}] HUMAN: {indent_continuation(shorten(message, MAX_HUMAN_CHARS))}"
            self.lines.append(OutlineLine(LineKind.HUMAN, text))
        elif is_interruption(entry):
            self.lines.append(OutlineLine(LineKind.INTERRUPTED, f"[{time}] INTERRUPTED by human"))
        elif entry.get("type") == ASSISTANT_ENTRY:
            self._add_assistant_content(time, content)
        elif entry.get("type") == USER_ENTRY and isinstance(content, list):
            self._add_tool_results(time, entry, content)

    def _add_assistant_content(self, time: str, content: str | list) -> None:
        reply = extract_text(content)
        if reply:
            text = f"[{time}] CLAUDE ({len(reply)} chars): {indent_continuation(shorten(reply, MAX_REPLY_CHARS))}"
            self.lines.append(OutlineLine(LineKind.REPLY, text))
        for block in tool_use_blocks(content):
            label = label_tool_call(block)
            self.tool_labels[block.get("id", "")] = label
            self.lines.append(OutlineLine(LineKind.TOOL, f"[{time}] TOOL {label}", tool_name=block.get("name", "")))

    def _add_tool_results(self, time: str, entry: dict, content: list) -> None:
        for block in content:
            if block.get("type") != TOOL_RESULT_BLOCK:
                continue
            label = self.tool_labels.get(block.get("tool_use_id", ""), UNKNOWN_TOOL_LABEL)
            if block.get("is_error"):
                failure = shorten(single_line(extract_text(block.get("content") or "")), MAX_FAILURE_CHARS)
                self.lines.append(OutlineLine(LineKind.FAILED, f"[{time}] FAILED {label}: {failure}"))
            self._add_permission(time, entry, label)
            outcome = classify_tool_outcome(entry, block)
            if outcome is not None:
                self.outcomes.append(outcome)
        if entry.get("sandboxViolations"):
            text = f"[{time}] SANDBOX: {json.dumps(entry['sandboxViolations'])}"
            self.lines.append(OutlineLine(LineKind.SANDBOX, text))

    def _add_permission(self, time: str, entry: dict, label: str) -> None:
        decision = PermissionDecision.from_entry(entry)
        if decision.is_shown:
            text = f"[{time}] PERMISSION {decision.decider} {decision.verdict}: {label}"
            self.lines.append(OutlineLine(LineKind.PERMISSION, text))
        elif entry.get("toolDenialKind"):
            text = f"[{time}] DENIED ({entry['toolDenialKind']}): {label}"
            self.lines.append(OutlineLine(LineKind.DENIED, text))


def classify_tool_outcome(entry: dict, result_block: dict) -> ToolOutcome | None:
    """Classifies a tool result by who decided on the call, never by its text, which can quote anything."""
    decision = PermissionDecision.from_entry(entry)
    if decision.verdict == REJECT_VERDICT and decision.source == HOOK_SOURCE:
        return ToolOutcome.HOOK_REJECTION
    if decision.verdict == REJECT_VERDICT and (decision.source == CONFIG_SOURCE or decision.is_rule_match):
        return ToolOutcome.DENIAL
    is_human_answer = decision.source in USER_PERMISSION_SOURCES and not decision.is_rule_match
    if is_human_answer or entry.get("toolDenialKind") == USER_REJECTED_DENIAL:
        return ToolOutcome.PROMPT
    return ToolOutcome.FAILURE if result_block.get("is_error") else None


def read_entries(transcript: Path) -> list[dict]:
    # Split on newlines only: JSON lines may hold raw U+2028 or U+2029, which str.splitlines() would split on.
    entries = (
        parse_entry(line)
        for line in transcript.read_text(encoding="utf-8", errors="replace").split("\n")
        if line.strip()
    )
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
        return extract_text(content_of(entry)) if is_human else None
    attachment = entry.get("attachment") or {}
    is_queued_human = attachment.get("type") == QUEUED_COMMAND_ATTACHMENT and (
        (attachment.get("origin") or {}).get("kind") == HUMAN_ORIGIN
    )
    return (
        extract_text(attachment.get("prompt") or "")
        if entry.get("type") == ATTACHMENT_ENTRY and is_queued_human
        else None
    )


def is_interruption(entry: dict) -> bool:
    return entry.get("type") == USER_ENTRY and extract_text(content_of(entry)).startswith(INTERRUPTION_PREFIX)


def clock_time(entry: dict) -> str:
    """The HH:MM part of an entry's ISO timestamp."""
    return str(entry.get("timestamp", ""))[11:16]


def content_of(entry: dict) -> str | list:
    return (entry.get("message") or {}).get("content") or ""


def tool_use_blocks(content: str | list) -> list[dict]:
    return [block for block in content if block.get("type") == TOOL_USE_BLOCK] if isinstance(content, list) else []


def extract_text(content: str | list) -> str:
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
    return f"{name}: {shorten(single_line(detail), MAX_TOOL_INPUT_CHARS)}"


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
