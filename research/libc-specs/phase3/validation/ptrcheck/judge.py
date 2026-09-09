"""Compare trace events and final observations; classify how negative controls differ."""
from __future__ import annotations

from .trace_format import EVENT_FIELDS, FINAL_FIELDS

STATUS_ABORT = 3
STATUS_USAGE = 64


def compare_documents(expected: dict, actual: dict, max_problems: int = 20) -> dict:
    ev_p: list[str] = []
    fin_p: list[str] = []
    ee, ae = expected["events"], actual["events"]
    if len(ee) != len(ae):
        ev_p.append(f"event count {len(ae)} != expected {len(ee)}")
    for i, (x, y) in enumerate(zip(ee, ae)):
        for k in EVENT_FIELDS:
            if x[k] != y[k]:
                ev_p.append(f"event {i} ({x['kind']}): {k} {y[k]!r} != expected {x[k]!r}")
                if len(ev_p) >= max_problems:
                    break
        if len(ev_p) >= max_problems:
            break
    for i in range(len(ee), len(ae)):
        if len(ev_p) >= max_problems:
            break
        ev_p.append(f"event {i}: unexpected extra {ae[i]['kind']} (offset {ae[i]['offset']}, request {ae[i]['request']}, result {ae[i]['result']})")
    if len(ae) < len(ee) and len(ev_p) < max_problems:
        m = ee[len(ae)]
        ev_p.append(f"event {len(ae)}: missing expected {m['kind']} (offset {m['offset']}, request {m['request']})")
    for k in FINAL_FIELDS:
        if expected["final"][k] != actual["final"][k]:
            fin_p.append(f"final.{k} {actual['final'][k]!r} != expected {expected['final'][k]!r}")
    probe_p = []
    for i, e in enumerate(ae):
        flags = e.get("probe") or {}
        if flags.get("base_known") is False:
            probe_p.append(f"event {i}: call before any read fixed the array base")
        if flags.get("in_bounds") is False:
            probe_p.append(f"event {i}: pointer outside the 32-byte array")
        if flags.get("clamped") is True:
            probe_p.append(f"event {i}: transfer clamped to the array bounds")
        if len(probe_p) >= max_problems:
            break
    probe_p += list(actual.get("probe_problems") or [])[:max_problems]
    return {"event_problems": ev_p, "final_problems": fin_p, "probe_problems": probe_p}


def wire_problems(expected_final: dict, status: int, stdout: bytes, stderr: bytes, timed_out: bool) -> list[str]:
    """Phase2-style wire comparison (status, stdout bytes, stderr counters)."""
    p = []
    if timed_out:
        p.append("timed out")
    if status != expected_final["status"]:
        p.append(f"status {status} != {expected_final['status']}")
    if stdout.hex() != expected_final["output_hex"]:
        p.append(f"stdout ({len(stdout)} bytes) != expected output ({len(expected_final['output_hex']) // 2} bytes)")
    exp_err = (f"consumed={expected_final['consumed']}\nread_calls={expected_final['read_calls']}\n"
               f"write_calls={expected_final['write_calls']}\n").encode()
    if stderr != exp_err:
        p.append(f"stderr {stderr[:120]!r} != {exp_err!r}")
    return p


def classify_distinction(status: int, wire: list[str], cmp: dict) -> str | None:
    """Classify abort, final-output difference, event-only difference, or None for no distinction."""
    if status == STATUS_ABORT:
        return "abort"
    if wire:
        return "final"
    if cmp["event_problems"] or cmp["final_problems"] or cmp["probe_problems"]:
        return "event_only"
    return None
