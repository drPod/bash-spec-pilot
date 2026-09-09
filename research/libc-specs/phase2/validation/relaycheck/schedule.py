"""Strict ASCII read/write schedules from CONTRACT.md. Drivers must reject invalid controls with status 64."""
from __future__ import annotations

import re

MAX_ACTION = 1 << 20
MAX_SCHEDULE = 4096
MAX_INPUT = 16 << 20
BUF_SIZE = 32

_ITEM = re.compile(r"^(-1|0|[1-9][0-9]*)$", re.ASCII)


class ScheduleError(ValueError):
    """Raised for any control value the drivers must reject (status 64 on the C side)."""


def parse_schedule(text: str, kind: str) -> list[int]:
    if kind not in ("reads", "writes"):
        raise ValueError(f"kind must be 'reads' or 'writes', got {kind!r}")
    if not isinstance(text, str):
        raise ScheduleError(f"{kind}: schedule must be a str")
    if text == "":
        return []
    items = text.split(",")
    if len(items) > MAX_SCHEDULE:
        raise ScheduleError(f"{kind}: {len(items)} entries exceed cap {MAX_SCHEDULE}")
    values: list[int] = []
    for item in items:
        if not _ITEM.match(item):
            raise ScheduleError(f"{kind}: malformed item {item!r}")
        # Bounded before conversion: a cap of 2^20 has 7 digits.
        digits = item.lstrip("-")
        if len(digits) > len(str(MAX_ACTION)):
            raise ScheduleError(f"{kind}: item {item!r} exceeds cap {MAX_ACTION}")
        value = int(item)
        values.append(value)
    return validate_schedule(values, kind)


def validate_schedule(values: list[int], kind: str) -> list[int]:
    if kind not in ("reads", "writes"):
        raise ValueError(f"kind must be 'reads' or 'writes', got {kind!r}")
    if len(values) > MAX_SCHEDULE:
        raise ScheduleError(f"{kind}: {len(values)} entries exceed cap {MAX_SCHEDULE}")
    out: list[int] = []
    for v in values:
        if isinstance(v, bool) or not isinstance(v, int):
            raise ScheduleError(f"{kind}: non-integer action {v!r}")
        if v < -1:
            raise ScheduleError(f"{kind}: action {v} below -1")
        if v > MAX_ACTION:
            raise ScheduleError(f"{kind}: action {v} exceeds cap {MAX_ACTION}")
        if v == 0 and kind == "reads":
            raise ScheduleError("reads: 0 is not a read action (zero results come only from EOF)")
        out.append(v)
    return out


def format_schedule(values: list[int]) -> str:
    return ",".join(str(v) for v in values)
