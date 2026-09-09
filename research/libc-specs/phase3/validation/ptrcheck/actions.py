"""Independent implementation of phase2 PROTOCOL.md schedule rules."""
from __future__ import annotations

import re

MAX_ACTION = 1 << 20
MAX_SCHEDULE = 4096
MAX_INPUT = 16 << 20

_ITEM = re.compile(r"^(-1|0|[1-9][0-9]*)$", re.ASCII)


class ActionError(ValueError):
    """Control value the drivers must reject (status 64)."""


def check_actions(values, kind: str) -> list[int]:
    if kind not in ("reads", "writes"):
        raise ValueError(f"kind must be 'reads' or 'writes', got {kind!r}")
    values = list(values)
    if len(values) > MAX_SCHEDULE:
        raise ActionError(f"{kind}: {len(values)} entries exceed cap {MAX_SCHEDULE}")
    for v in values:
        if isinstance(v, bool) or not isinstance(v, int):
            raise ActionError(f"{kind}: non-integer action {v!r}")
        if v < -1:
            raise ActionError(f"{kind}: action {v} below -1")
        if v > MAX_ACTION:
            raise ActionError(f"{kind}: action {v} exceeds cap {MAX_ACTION}")
        if v == 0 and kind == "reads":
            raise ActionError("reads: 0 is not a read action")
    return values


def parse_actions(text: str, kind: str) -> list[int]:
    if not isinstance(text, str):
        raise ActionError(f"{kind}: schedule must be text")
    if text == "":
        return []
    items = text.split(",")
    if len(items) > MAX_SCHEDULE:
        raise ActionError(f"{kind}: {len(items)} entries exceed cap {MAX_SCHEDULE}")
    out = []
    for item in items:
        if not _ITEM.match(item):
            raise ActionError(f"{kind}: malformed item {item!r}")
        if len(item.lstrip("-")) > len(str(MAX_ACTION)):
            raise ActionError(f"{kind}: item {item!r} exceeds cap {MAX_ACTION}")
        out.append(int(item))
    return check_actions(out, kind)


def format_actions(values) -> str:
    return ",".join(str(v) for v in values)
