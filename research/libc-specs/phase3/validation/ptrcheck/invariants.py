"""Check PROTOCOL.md pointer, memory, schedule, and conservation rules directly from trace events.

Independent of the Python reference model. R1-R10 labels identify violations in reports."""
from __future__ import annotations

from . import CAPACITY, READ_FD, WRITE_FD


def check_invariants(doc: dict, capacity: int = CAPACITY, max_problems: int = 40) -> list[str]:
    p: list[str] = []
    case = doc["case"]
    data = bytes.fromhex(case["input_hex"])
    reads, writes = list(case["reads"]), list(case["writes"])
    ri = wi = 0
    pos = 0            # unread input position
    n = off = 0        # chunk length and retry pointer
    chunk_start = 0    # input position where the current chunk began
    mem = b""          # defined prefix as last snapshotted
    out = b""
    control = "read"
    terminal = None    # (index, status)
    n_reads = n_writes = 0

    def add(msg):
        if len(p) < max_problems:
            p.append(msg)

    for i, e in enumerate(doc["events"]):
        if terminal is not None:
            add(f"event {i}: {e['kind']} after terminal event {terminal[0]} (fail-stop violated)")
            break
        before = mem
        if e["kind"] == "read":
            n_reads += 1
            if control != "read":
                add(f"event {i}: read while {n - off} chunk bytes are undelivered (read before drain)")
            if e["fd"] != READ_FD:
                add(f"event {i}: read on fd {e['fd']} != {READ_FD}")
            if e["offset"] != 0:
                add(f"event {i}: read pointer offset {e['offset']} != 0 (array must be reused at its base)")
            if e["request"] != capacity:
                add(f"event {i}: read request {e['request']} != {capacity}")
            if ri < len(reads):
                exp_action, exp_src = reads[ri], "schedule"
            else:
                exp_action, exp_src = e["request"], "default"
            ri += 1
            if (e["action"], e["action_source"]) != (exp_action, exp_src):
                add(f"event {i}: read action {e['action']}/{e['action_source']} != {exp_action}/{exp_src}")
            if e["init_before"] != n or e["defined_before"] != len(before):
                add(f"event {i}: init/defined before ({e['init_before']},{e['defined_before']}) != ({n},{len(before)})")
            if exp_action == -1:
                if e["result"] != -1:
                    add(f"event {i}: read error result {e['result']} != -1")
                if e["bytes_hex"] != "" or e["memory_hex"] != before.hex() or e["init_after"] != n:
                    add(f"event {i}: read error must transfer nothing and leave memory/chunk unchanged")
                terminal = (i, 1)
            else:
                q = min(exp_action, capacity, len(data) - pos)
                moved = data[pos:pos + q]
                if e["result"] != q:
                    add(f"event {i}: read result {e['result']} != min(action,{capacity},unread)={q}")
                if e["bytes_hex"] != moved.hex():
                    add(f"event {i}: read bytes are not the next {q} input bytes")
                mem = bytes.fromhex(e["memory_hex"])
                if len(mem) != max(len(before), q) or mem[:q] != moved or mem[q:] != before[q:]:
                    add(f"event {i}: memory after read must be bytes ++ untouched stale suffix (frame)")
                if e["init_after"] != q or e["defined_after"] != max(len(before), q):
                    add(f"event {i}: init/defined after ({e['init_after']},{e['defined_after']}) != ({q},{max(len(before), q)})")
                chunk_start, pos = pos, pos + q
                n, off = q, 0
                if q == 0:
                    terminal = (i, 0)
                else:
                    control = "drain"
        elif e["kind"] == "write":
            n_writes += 1
            if control != "drain":
                add(f"event {i}: write without a chunk to drain")
            if e["fd"] != WRITE_FD:
                add(f"event {i}: write on fd {e['fd']} != {WRITE_FD}")
            if e["offset"] != off:
                add(f"event {i}: write pointer offset {e['offset']} != retry offset {off}")
            residual = n - off
            if e["request"] != residual:
                add(f"event {i}: write request {e['request']} != residual n-off = {residual}")
            if e["offset"] < 0 or e["offset"] + e["request"] > e["init_before"]:
                add(f"event {i}: write range [{e['offset']},{e['offset'] + e['request']}) exceeds initialized chunk {e['init_before']}")
            if e["init_before"] != n or e["defined_before"] != len(before):
                add(f"event {i}: init/defined before ({e['init_before']},{e['defined_before']}) != ({n},{len(before)})")
            if wi < len(writes):
                exp_action, exp_src = writes[wi], "schedule"
            else:
                exp_action, exp_src = residual, "default"
            wi += 1
            if (e["action"], e["action_source"]) != (exp_action, exp_src):
                add(f"event {i}: write action {e['action']}/{e['action_source']} != {exp_action}/{exp_src}")
            if e["memory_hex"] != before.hex() or e["init_after"] != n or e["defined_after"] != len(before):
                add(f"event {i}: write must not change memory, chunk length or defined prefix (frame)")
            if exp_action <= 0:
                if e["result"] != exp_action or e["bytes_hex"] != "":
                    add(f"event {i}: write action {exp_action} must return {exp_action} with no transfer")
                terminal = (i, 2)
            else:
                k = min(exp_action, residual)
                if e["result"] != k:
                    add(f"event {i}: write result {e['result']} != min(action,residual)={k}")
                moved = bytes.fromhex(e["bytes_hex"])
                if moved != before[off:off + k]:
                    add(f"event {i}: write bytes differ from memory at [{off},{off + k})")
                if moved != data[chunk_start + off:chunk_start + off + k]:
                    add(f"event {i}: write bytes differ from the input bytes of this chunk range")
                out += moved
                off += k
                if off >= n:
                    control = "read"
        else:
            add(f"event {i}: unknown kind {e['kind']!r}")

    f = doc["final"]
    if terminal is None:
        add("trace has no terminal event (no EOF, read error, write error or zero write)")
    else:
        if f["status"] != terminal[1]:
            add(f"final status {f['status']} != {terminal[1]} implied by terminal event {terminal[0]}")
    if bytes.fromhex(f["output_hex"]) != out:
        add("final output != concatenation of delivered write bytes")
    if f["consumed"] != pos:
        add(f"final consumed {f['consumed']} != {pos} bytes read")
    exp_pending = mem[off:n] if off < n else b""
    if bytes.fromhex(f["pending_hex"]) != exp_pending:
        add("final pending != memory[off:n]")
    if bytes.fromhex(f["unread_hex"]) != data[pos:]:
        add("final unread != input suffix after consumed bytes")
    if out + exp_pending + data[pos:] != data:
        add("conservation violated: output ++ pending ++ unread != input")
    if f["read_calls"] != n_reads or f["write_calls"] != n_writes:
        add(f"final call counts ({f['read_calls']},{f['write_calls']}) != events ({n_reads},{n_writes})")
    if f["status"] == 0 and (out != data or data[pos:]):
        add("status 0 with output != input or unread input remaining")
    if f["status"] == 2 and not exp_pending:
        add("status 2 with empty pending residual")
    return p
