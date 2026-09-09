"""Independent pointer-machine reference from PROTOCOL.md, not the Lean model or list oracle.

Writes load from the array at the retry pointer. The defined prefix retains stale cells
beyond the current chunk so snapshots expose frame violations."""
from __future__ import annotations

from . import CAPACITY, READ_FD, WRITE_FD
from .actions import check_actions
from .trace_format import make_document, make_event, make_final


class _Cursor:
    """Finite schedule; every call consumes one action, default = full request."""

    def __init__(self, values):
        self.values = list(values)
        self.i = 0

    def take(self, request: int):
        if self.i < len(self.values):
            v = self.values[self.i]
            self.i += 1
            return v, "schedule"
        return request, "default"


def run_pointer_machine(data: bytes, reads, writes, name: str = "", capacity: int = CAPACITY) -> dict:
    if capacity != CAPACITY:
        raise ValueError("this reference supports only the frozen 32-byte relay")
    reads = check_actions(reads, "reads")
    writes = check_actions(writes, "writes")
    data = bytes(data)

    mem = bytearray(capacity)   # cell contents; only mem[:defined] is meaningful
    defined = 0                 # defined prefix (bytes ever stored by a read)
    n = 0                       # valid chunk length
    off = 0                     # retry pointer offset within the chunk
    pos = 0                     # unread input position
    out = bytearray()
    rcur, wcur = _Cursor(reads), _Cursor(writes)
    read_calls = write_calls = 0
    events: list[dict] = []
    control = "read"
    status = None
    # Progress bound: each iteration consumes input, advances off, or terminates.
    guard = 2 * len(data) + len(reads) + len(writes) + 4

    def snapshot() -> str:
        return bytes(mem[:defined]).hex()

    while status is None:
        guard -= 1
        if guard < 0:  # pragma: no cover - would indicate a bug in this reference
            raise RuntimeError("pointer machine exceeded its progress bound")
        if control == "read":
            read_calls += 1
            init_before, defined_before = n, defined
            action, source = rcur.take(capacity)
            if action == -1:
                result, moved = -1, b""
            else:
                q = min(action, capacity, len(data) - pos)
                moved = data[pos:pos + q]
                mem[0:q] = moved
                defined = max(defined, q)
                pos += q
                n, off = q, 0
                result = q
            events.append(make_event(len(events), "read", READ_FD, 0, capacity, action, source, result,
                                     moved, init_before, n, defined_before, defined, snapshot()))
            if result < 0:
                status = 1
            elif result == 0:
                status = 0
            else:
                control = "drain"
        else:
            if off >= n:
                control = "read"
                continue
            write_calls += 1
            at, request = off, n - off
            action, source = wcur.take(request)
            if action <= 0:
                result, moved = action, b""
            else:
                k = min(action, request)
                moved = bytes(mem[at:at + k])
                out += moved
                off += k
                result = k
            events.append(make_event(len(events), "write", WRITE_FD, at, request, action, source, result,
                                     moved, n, n, defined, defined, snapshot()))
            if result <= 0:
                status = 2

    pending = bytes(mem[off:n]) if off < n else b""
    final = make_final(status, bytes(out), pos, pending, data[pos:], read_calls, write_calls)
    case = {"name": name, "input_hex": data.hex(), "reads": reads, "writes": writes}
    return make_document(case, events, final, producer="model", capacity=capacity)
