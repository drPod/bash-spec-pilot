"""Single-substitution negative controls applied to private copies of the frozen relay.c."""
from __future__ import annotations

MUTANTS = [
    {
        "name": "wrong_write_offset",
        "old": "write(1, buf + off, (size_t)n - off)",
        "new": "write(1, buf, (size_t)n - off)",
        "description": "resumes short writes from the buffer start instead of buf+off",
        "visible_when": "any short write (delivered bytes wrong, same length)",
    },
    {
        "name": "short_write_as_full",
        "old": "off = off + (size_t)w;",
        "new": "off = (size_t)n;",
        "description": "treats any positive write as having delivered the whole chunk",
        "visible_when": "short write (missing bytes, fewer write calls)",
    },
    {
        "name": "ignore_zero_write",
        "old": "if (w <= 0) return 2;",
        "new": "if (w < 0) return 2;",
        "description": "a zero-length write result is retried instead of fail-stop",
        "visible_when": "write action 0 (status 0/continues instead of 2)",
    },
    {
        "name": "ignore_write_error",
        "old": "if (w <= 0) return 2;",
        "new": "if (w == 0) return 2;",
        "description": "a write error is not detected; unsigned off decrements modulo size_t range (at zero it wraps and drops the chunk)",
        "visible_when": "write action -1",
    },
    {
        "name": "read_size_16",
        "old": "n = read(0, buf, 32);",
        "new": "n = read(0, buf, 16);",
        "description": "requests 16 bytes per read instead of 32",
        "visible_when": "input longer than 16 bytes with default reads (read_calls differ)",
    },
    {
        "name": "read_size_31",
        "old": "n = read(0, buf, 32);",
        "new": "n = read(0, buf, 31);",
        "description": "off-by-one request size",
        "visible_when": "input of >= 32 bytes with default reads",
    },
    {
        "name": "eof_as_error",
        "old": "if (n == 0) return 0;",
        "new": "if (n == 0) return 1;",
        "description": "reports EOF as a read error",
        "visible_when": "any run reaching EOF (status 1 instead of 0)",
    },
    {
        "name": "read_error_status_2",
        "old": "if (n < 0) return 1;",
        "new": "if (n < 0) return 2;",
        "description": "read error reported with the write-error status",
        "visible_when": "read action -1",
    },
    {
        "name": "no_offset_advance",
        "old": "off = off + (size_t)w;",
        "new": "off = off + 0 * (size_t)w;",
        "description": "never advances the write offset: non-terminating under successful writes",
        "visible_when": "any non-empty input; caught only by the driver's configurable call cap (status 3)",
    },
]


def apply_mutant(source: str, mutant: dict) -> str:
    count = source.count(mutant["old"])
    if count != 1:
        raise RuntimeError(f"mutant {mutant['name']}: pattern occurs {count} times, expected exactly 1")
    mutated = source.replace(mutant["old"], mutant["new"])
    if mutated == source:
        raise RuntimeError(f"mutant {mutant['name']}: substitution produced identical source")
    return mutated
