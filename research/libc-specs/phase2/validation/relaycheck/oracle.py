"""Independent relay oracle written from CONTRACT.md, not translated from C."""
from __future__ import annotations

from dataclasses import dataclass

from .schedule import BUF_SIZE, validate_schedule


@dataclass(frozen=True)
class Outcome:
    output: bytes
    remaining: bytes
    status: int
    read_calls: int
    write_calls: int
    input_len: int

    @property
    def consumed(self) -> int:
        return self.input_len - len(self.remaining)

    def stderr_text(self) -> str:
        return f"consumed={self.consumed}\nread_calls={self.read_calls}\nwrite_calls={self.write_calls}\n"


def run_relay(data: bytes, reads: list[int], writes: list[int], buf_size: int = BUF_SIZE) -> Outcome:
    """Positive reads consume input and positive writes advance the chunk; errors and zero writes stop."""
    reads = validate_schedule(list(reads), "reads")
    writes = validate_schedule(list(writes), "writes")
    data = bytes(data)
    pos = 0
    out = bytearray()
    ri = 0
    wi = 0
    read_calls = 0
    write_calls = 0

    def finish(status: int) -> Outcome:
        return Outcome(bytes(out), data[pos:], status, read_calls, write_calls, len(data))

    while True:
        read_calls += 1
        request = buf_size
        if ri < len(reads):
            action = reads[ri]
            ri += 1
        else:
            action = request
        if action == -1:
            return finish(1)
        q = min(action, request, len(data) - pos)
        if q == 0:
            return finish(0)  # only reachable when no input remains
        chunk = data[pos : pos + q]
        pos += q
        off = 0
        while off < q:
            write_calls += 1
            wrequest = q - off
            if wi < len(writes):
                waction = writes[wi]
                wi += 1
            else:
                waction = wrequest
            if waction == -1 or waction == 0:
                return finish(2)
            d = min(waction, wrequest)
            out += chunk[off : off + d]
            off += d
