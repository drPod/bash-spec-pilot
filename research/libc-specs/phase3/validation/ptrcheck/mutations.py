"""Single-substitution mutants applied to private frozen-source copies.

Replacing the drain while with if permits read-before-drain after a short write;
full writes hide this fault. Changing allocations requires more than a single substitution."""
from __future__ import annotations

MUTANTS = [
    {
        "name": "wrong_pointer",
        "old": "write(1, buf + off, (size_t)n - off)",
        "new": "write(1, buf, (size_t)n - off)",
        "fault": "retry writes resume from the array base instead of buf + off",
        "expected_signal": "write event offset 0 where offset off was due; delivered bytes repeat the chunk prefix",
    },
    {
        "name": "wrong_residual_request",
        "old": "write(1, buf + off, (size_t)n - off)",
        "new": "write(1, buf + off, (size_t)n)",
        "fault": "retry writes request the whole chunk length instead of the residual n - off",
        "expected_signal": "write event request n != n - off; the probe clamps the out-of-range window (probe.clamped) so stdout can stay identical: event-only distinction",
    },
    {
        "name": "request_one_byte",
        "old": "write(1, buf + off, (size_t)n - off)",
        "new": "write(1, buf + off, 1)",
        "fault": "every write requests exactly one byte",
        "expected_signal": "request 1 != residual on every multi-byte chunk; wire output identical under default schedules, write_calls differ",
    },
    {
        "name": "skipped_short_write_retry",
        "old": "off = off + (size_t)w;",
        "new": "off = (size_t)n;",
        "fault": "a positive short write is treated as having drained the chunk (no retry)",
        "expected_signal": "missing retry write event; output lacks the residual bytes",
    },
    {
        "name": "read_before_drain",
        "old": "while (off < (size_t)n) {",
        "new": "if (off < (size_t)n) {",
        "fault": "after one write the loop reads again even if chunk bytes remain undelivered",
        "expected_signal": "read event where a retry write was due (R9 read-before-drain); residual bytes lost",
    },
    {
        "name": "zero_write_retried",
        "old": "if (w <= 0) return 2;",
        "new": "if (w < 0) return 2;",
        "fault": "a zero write result is retried instead of fail-stop",
        "expected_signal": "extra write events after a 0 action; with several scheduled zeros it loops until the strict per-case call cap aborts it (status 3)",
    },
    {
        "name": "offset_never_advances",
        "old": "off = off + (size_t)w;",
        "new": "off = off + 0 * (size_t)w;",
        "fault": "the retry pointer never advances: repeated writes of the same range",
        "expected_signal": "repeated write events at offset 0 until the strict per-case call cap aborts it (status 3)",
    },
    {
        "name": "read_request_31",
        "old": "n = read(0, buf, 32);",
        "new": "n = read(0, buf, 31);",
        "fault": "off-by-one read request",
        "expected_signal": "read event request 31 != 32 on EVERY case including empty input; wire output identical for inputs shorter than 31 bytes: event-only distinction",
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
