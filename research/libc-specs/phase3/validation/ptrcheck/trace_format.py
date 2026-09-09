"""Pointer-event document format; see TRACE_SCHEMA.md.

Canonical hashes cover case, core event fields, and final fields, excluding probe metadata."""
from __future__ import annotations

import hashlib
import json
import re

from . import CAPACITY, SCHEMA

EVENT_FIELDS = ("seq", "kind", "fd", "block", "offset", "request", "action", "action_source", "result",
                "bytes_hex", "init_before", "init_after", "defined_before", "defined_after", "memory_hex")
FINAL_FIELDS = ("status", "output_hex", "consumed", "pending_hex", "unread_hex", "read_calls", "write_calls")
HAND_COLUMNS = ("kind", "fd", "offset", "request", "action", "action_source", "result", "bytes_hex",
                "init_before", "init_after", "defined_before", "defined_after", "memory_hex")
_HEX = re.compile(r"^(?:[0-9a-f]{2})*$")


class TraceFormatError(ValueError):
    pass


def make_event(seq, kind, fd, offset, request, action, source, result, moved: bytes,
               init_before, init_after, defined_before, defined_after, memory_hex: str) -> dict:
    return {
        "seq": seq, "kind": kind, "fd": fd, "block": 0, "offset": offset, "request": request,
        "action": action, "action_source": source, "result": result, "bytes_hex": bytes(moved).hex(),
        "init_before": init_before, "init_after": init_after, "defined_before": defined_before,
        "defined_after": defined_after, "memory_hex": memory_hex,
    }


def make_final(status, output: bytes, consumed, pending: bytes, unread: bytes, read_calls, write_calls) -> dict:
    return {
        "status": status, "output_hex": bytes(output).hex(), "consumed": consumed,
        "pending_hex": bytes(pending).hex(), "unread_hex": bytes(unread).hex(),
        "read_calls": read_calls, "write_calls": write_calls,
    }


def make_document(case: dict, events: list, final: dict, producer: str, capacity: int = CAPACITY, **extra) -> dict:
    doc = {"schema": SCHEMA, "producer": producer, "capacity": capacity,
           "case": {"name": case["name"], "input_hex": case["input_hex"],
                    "reads": list(case["reads"]), "writes": list(case["writes"])},
           "events": events, "final": final}
    doc.update(extra)
    return doc


def event_core(ev: dict) -> dict:
    return {k: ev[k] for k in EVENT_FIELDS}


def core(doc: dict) -> dict:
    return {"case": doc["case"], "events": [event_core(e) for e in doc["events"]],
            "final": {k: doc["final"][k] for k in FINAL_FIELDS}}


def canonical_json(obj) -> bytes:
    return json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()


def trace_sha256(doc: dict) -> str:
    return hashlib.sha256(canonical_json(core(doc))).hexdigest()


def _is_int(x) -> bool:
    return isinstance(x, int) and not isinstance(x, bool)


def validate_document(doc, capacity: int = CAPACITY) -> list[str]:
    """Check structure and ranges; semantic checks live in invariants.py."""
    p: list[str] = []
    if not isinstance(doc, dict):
        return ["document is not an object"]
    if doc.get("schema") != SCHEMA:
        p.append(f"schema {doc.get('schema')!r} != {SCHEMA!r}")
    if doc.get("capacity") != capacity:
        p.append(f"capacity {doc.get('capacity')!r} != {capacity}")
    case = doc.get("case")
    if not isinstance(case, dict):
        return p + ["case missing"]
    for k in ("name", "input_hex"):
        if not isinstance(case.get(k), str):
            p.append(f"case.{k} must be a string")
    if isinstance(case.get("input_hex"), str) and not _HEX.match(case["input_hex"]):
        p.append("case.input_hex is not lowercase even-length hex")
    for k in ("reads", "writes"):
        v = case.get(k)
        if not isinstance(v, list) or not all(_is_int(x) for x in v):
            p.append(f"case.{k} must be a list of integers")
    events = doc.get("events")
    if not isinstance(events, list):
        return p + ["events missing"]
    for i, e in enumerate(events):
        if not isinstance(e, dict):
            p.append(f"event {i}: not an object")
            continue
        missing = [k for k in EVENT_FIELDS if k not in e]
        if missing:
            p.append(f"event {i}: missing {missing}")
            continue
        if e["seq"] != i:
            p.append(f"event {i}: seq {e['seq']} is not dense")
        if e["kind"] not in ("read", "write"):
            p.append(f"event {i}: kind {e['kind']!r}")
        if e["action_source"] not in ("schedule", "default"):
            p.append(f"event {i}: action_source {e['action_source']!r}")
        for k in ("fd", "block", "offset", "request", "action", "result", "init_before", "init_after",
                  "defined_before", "defined_after"):
            if not _is_int(e[k]):
                p.append(f"event {i}: {k} is not an integer")
        for k in ("bytes_hex", "memory_hex"):
            if not isinstance(e[k], str) or not _HEX.match(e[k]):
                p.append(f"event {i}: {k} is not hex")
        if p and p[-1].startswith(f"event {i}:"):
            continue
        if e["block"] != 0:
            p.append(f"event {i}: block {e['block']} != 0 (single allocation)")
        if e["result"] < -1:
            p.append(f"event {i}: result {e['result']} below -1")
        if len(e["bytes_hex"]) // 2 != max(e["result"], 0):
            p.append(f"event {i}: bytes_hex length {len(e['bytes_hex']) // 2} != max(result,0)")
        if len(e["memory_hex"]) // 2 != e["defined_after"]:
            p.append(f"event {i}: memory_hex length {len(e['memory_hex']) // 2} != defined_after")
        for k in ("init_before", "init_after", "defined_before", "defined_after"):
            if not 0 <= e[k] <= capacity:
                p.append(f"event {i}: {k}={e[k]} outside [0,{capacity}]")
        if e["defined_after"] < e["defined_before"]:
            p.append(f"event {i}: defined prefix shrank")
    final = doc.get("final")
    if not isinstance(final, dict):
        return p + ["final missing"]
    missing = [k for k in FINAL_FIELDS if k not in final]
    if missing:
        return p + [f"final: missing {missing}"]
    for k in ("status", "consumed", "read_calls", "write_calls"):
        if not _is_int(final[k]):
            p.append(f"final.{k} is not an integer")
    for k in ("output_hex", "pending_hex", "unread_hex"):
        if not isinstance(final[k], str) or not _HEX.match(final[k]):
            p.append(f"final.{k} is not hex")
    return p


def expand_hand_traces(obj: dict, capacity: int = CAPACITY) -> list[dict]:
    cols = tuple(obj["columns"])
    if cols != HAND_COLUMNS:
        raise TraceFormatError(f"hand columns {cols} != {HAND_COLUMNS}")
    docs = []
    for t in obj["traces"]:
        events = []
        for i, row in enumerate(t["events"]):
            if len(row) != len(cols):
                raise TraceFormatError(f"{t['name']}: event {i} has {len(row)} columns")
            e = dict(zip(cols, row))
            e["seq"] = i
            e["block"] = 0
            events.append({k: e[k] for k in EVENT_FIELDS})
        case = {"name": t["name"], "input_hex": t["input_hex"], "reads": t["reads"], "writes": t["writes"]}
        docs.append(make_document(case, events, dict(t["final"]), producer="hand", capacity=capacity,
                                  note=t.get("note", "")))
    return docs


def parse_probe_jsonl(data: bytes) -> dict:
    events, exit_rec, abort_rec, problems = [], None, None, []
    for lineno, raw in enumerate(data.split(b"\n"), 1):
        if not raw.strip():
            continue
        try:
            obj = json.loads(raw)
        except ValueError as e:
            problems.append(f"trace line {lineno}: invalid JSON ({e})")
            continue
        kind = obj.get("kind")
        if kind in ("read", "write"):
            if exit_rec is not None or abort_rec is not None:
                problems.append(f"trace line {lineno}: event after exit/abort")
            events.append(obj)
        elif kind == "exit":
            if exit_rec is not None:
                problems.append(f"trace line {lineno}: duplicate exit record")
            exit_rec = obj
        elif kind == "abort":
            abort_rec = obj
        else:
            problems.append(f"trace line {lineno}: unknown record kind {kind!r}")
    return {"events": events, "exit": exit_rec, "abort": abort_rec, "problems": problems}


def _pending_from_events(events: list, memory_hex: str) -> tuple[str, list[str]]:
    """Pending spans the retry pointer to the last read chunk end, reconstructed from events."""
    n = off = 0
    for e in events:
        if e["kind"] == "read":
            if e["result"] >= 0:
                n, off = e["offset"] + e["result"] if e["offset"] >= 0 else 0, 0
        elif e["result"] > 0:
            off += e["result"]
    mem = bytes.fromhex(memory_hex)
    if off > n or n > len(mem):
        return "", [f"pending range [{off},{n}) not inside the defined prefix of {len(mem)} bytes"]
    return mem[off:n].hex(), []


def document_from_probe(case: dict, parsed: dict, status: int, stdout: bytes, producer: str) -> dict:
    events = []
    problems = list(parsed["problems"])
    for i, e in enumerate(parsed["events"]):
        missing = [k for k in EVENT_FIELDS if k not in e]
        if missing:
            problems.append(f"event {i}: probe record missing {missing}")
            continue
        ev = {k: e[k] for k in EVENT_FIELDS}
        ev["probe"] = e.get("probe", {})
        events.append(ev)
    data = bytes.fromhex(case["input_hex"])
    ex = parsed["exit"]
    consumed = sum(e["result"] for e in events if e["kind"] == "read" and e["result"] > 0)
    if ex is not None and ex.get("consumed") != consumed:
        problems.append(f"exit consumed {ex.get('consumed')} != sum of read results {consumed}")
    memory_hex = ex["memory_hex"] if ex is not None else (events[-1]["memory_hex"] if events else "")
    pending_hex, pp = _pending_from_events(events, memory_hex)
    problems += pp
    final = make_final(status, stdout, consumed, bytes.fromhex(pending_hex), data[consumed:],
                       sum(1 for e in events if e["kind"] == "read"),
                       sum(1 for e in events if e["kind"] == "write"))
    return make_document(case, events, final, producer=producer, probe_exit=ex, probe_abort=parsed["abort"],
                         probe_problems=problems)
