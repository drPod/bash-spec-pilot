"""Deterministic exhaustive, directed, and invalid-control cases using portable SHA-256 byte streams."""
from __future__ import annotations

import hashlib
import itertools
import json
from dataclasses import dataclass, field

from .schedule import MAX_ACTION, MAX_SCHEDULE, format_schedule


def byte_stream(n: int, seed: str) -> bytes:
    out = bytearray()
    i = 0
    while len(out) < n:
        out += hashlib.sha256(f"relaycheck:{seed}:{i}".encode()).digest()
        i += 1
    return bytes(out[:n])


@dataclass(frozen=True)
class Case:
    name: str
    category: str
    data: bytes
    reads: tuple = ()
    writes: tuple = ()
    reads_text: str | None = None  # raw CLI text overriding `reads` (reject cases)
    writes_text: str | None = None
    expect_reject: bool = False
    pass_flags: bool = True  # False => run with no --reads/--writes flags at all
    extra_argv: tuple | None = None  # full argument override (after executable)
    note: str = ""

    def reads_arg(self) -> str:
        return self.reads_text if self.reads_text is not None else format_schedule(list(self.reads))

    def writes_arg(self) -> str:
        return self.writes_text if self.writes_text is not None else format_schedule(list(self.writes))

    def argv(self) -> list[str]:
        if self.extra_argv is not None:
            return list(self.extra_argv)
        if not self.pass_flags:
            return []
        return ["--reads", self.reads_arg(), "--writes", self.writes_arg()]

    def manifest(self) -> dict:
        return {
            "name": self.name,
            "category": self.category,
            "data_len": len(self.data),
            "data_sha256": hashlib.sha256(self.data).hexdigest(),
            "argv": self.argv(),
            "expect_reject": self.expect_reject,
            "note": self.note,
        }


def corpus_manifest(cases: list[Case]) -> list[dict]:
    return [c.manifest() for c in cases]


def corpus_hash(cases: list[Case]) -> str:
    blob = json.dumps(corpus_manifest(cases), sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(blob).hexdigest()


def _schedules(alphabet: list[int], max_len: int):
    for L in range(max_len + 1):
        yield from itertools.product(alphabet, repeat=L)


def exhaustive_cases(tag: str, lengths: list[int], read_alpha: list[int], write_alpha: list[int], sched_len: int,
                     category: str) -> list[Case]:
    cases = []
    for n in lengths:
        data = byte_stream(n, f"exh-{tag}-{n}")
        for r in _schedules(read_alpha, sched_len):
            for w in _schedules(write_alpha, sched_len):
                rn = format_schedule(list(r)) or "_"
                wn = format_schedule(list(w)) or "_"
                cases.append(Case(f"{category}/n{n}/r{rn}/w{wn}", category, data, tuple(r), tuple(w)))
    return cases


def directed_cases() -> list[Case]:
    C = []

    def add(name, data, reads=(), writes=(), note="", cat="directed", **kw):
        C.append(Case(f"{cat}/{name}", cat, data, tuple(reads), tuple(writes), note=note, **kw))

    for n in (31, 32, 33):
        d = byte_stream(n, f"buf{n}")
        add(f"buf{n}/default", d, note="buffer boundary, default schedules")
        add(f"buf{n}/w31", d, writes=(31,), note="short write of 31 then default")
        add(f"buf{n}/w1", d, writes=(1,), note="short write of 1 then default")
        add(f"buf{n}/w33", d, writes=(33,), note="over-request write is clamped")
        add(f"buf{n}/r31", d, reads=(31,), note="short read of 31 then default")
        add(f"buf{n}/r33", d, reads=(33,), note="over-request read clamped to 32")
        add(f"buf{n}/r1w1", d, reads=(1,), writes=(1,))
    for n in (64, 65, 96, 100, 257, 1000, 4096, 65536, 100000):
        add(f"multibuf/n{n}", byte_stream(n, f"mb{n}"), note="multi-buffer binary input")
    add("multibuf/n1000/r7", byte_stream(1000, "mb1000"), reads=(7,) * 10, note="ten short reads then default")
    add("multibuf/n1000/w5", byte_stream(1000, "mb1000"), writes=(5,) * 10, note="ten short writes then default")
    add("multibuf/n1000/r7w5", byte_stream(1000, "mb1000"), reads=(7,) * 10, writes=(5,) * 10)
    every = bytes(range(256))
    add("every256/forward", every)
    add("every256/reverse", every[::-1])
    add("every256/r1", every, reads=(1,), note="first read 1 byte, then default")
    add("every256/w1x3", every, writes=(1, 1, 1))
    add("every256/werr_after_partial", every, writes=(32, 32, 5, -1), note="write error mid third buffer")
    add("every256/wzero_after_partial", every, writes=(32, 32, 5, 0))
    add("every256/rerr_after_2", every, reads=(32, 32, -1))
    add("every256/n257", every + b"\x00", note="256 + 1 trailing NUL")
    add("every256/twice", every * 2)
    add("unterminated/no_newline", b"hello world")
    add("unterminated/inner_newline", b"line1\nline2")
    add("unterminated/nul_bytes", b"a\x00b\x00\x00")
    add("unterminated/only_newlines", b"\n\n\n")
    add("unterminated/utf8_partial", "héllo wörld".encode()[:-1], note="cut inside a UTF-8 sequence")
    add("unterminated/exactly_32_no_newline", b"x" * 32)
    d40 = byte_stream(40, "d40")
    add("rerr/before_data", d40, reads=(-1,), note="status 1, nothing consumed")
    add("rerr/before_data_empty_input", b"", reads=(-1,), note="error takes precedence over EOF")
    add("rerr/double", d40, reads=(-1, -1))
    add("rerr/after_first_buffer", d40, reads=(32, -1))
    add("rerr/after_5", d40, reads=(5, -1))
    add("rerr/after_all_consumed", byte_stream(64, "d64"), reads=(32, 32, -1), note="error at the EOF position -> status 1 not 0")
    add("rerr/after_default_reads", byte_stream(100, "d100"), reads=(32, 32, -1))
    add("rerr/late_never_reached", d40, reads=(32, 8, -1), note="EOF read consumes -1? no: 3rd call IS the -1 -> status 1")
    add("rerr/unreached", d40, reads=(32, 8, 32, -1), note="EOF on 3rd call, -1 never consumed")
    add("werr/before_delivery", d40, writes=(-1,))
    add("wzero/before_delivery", d40, writes=(0,))
    add("werr/empty_input_no_write", b"", writes=(-1,), note="no write occurs on empty input")
    add("werr/after_partial_5", d40, writes=(5, -1))
    add("wzero/after_partial_5", d40, writes=(5, 0))
    add("werr/second_buffer", d40, writes=(32, -1))
    add("wzero/second_buffer", d40, writes=(32, 0))
    add("werr/after_short_short", d40, writes=(1, 1, -1))
    add("wzero/then_error_unreached", d40, writes=(0, -1))
    add("werr/then_zero_unreached", d40, writes=(-1, 0))
    d10 = byte_stream(10, "d10")
    add("short/w1x4_n10", d10, writes=(1, 1, 1, 1), note="4 short + 1 default = 5 write calls")
    add("short/w7x4_n32", byte_stream(32, "buf32"), writes=(7, 7, 7, 7), note="7,7,7,7 then 4")
    add("short/w1x32_n32", byte_stream(32, "buf32"), writes=(1,) * 32, note="exactly 32 single-byte writes")
    add("short/w1x33_n32", byte_stream(32, "buf32"), writes=(1,) * 33, note="33rd action never consumed")
    add("short/w31_n32", byte_stream(32, "buf32"), writes=(31,))
    add("short/w16_16_n32", byte_stream(32, "buf32"), writes=(16, 16))
    add("short/w16_15_n32", byte_stream(32, "buf32"), writes=(16, 15), note="16+15 then default 1")
    add("short/r5_w2_2", d10, reads=(5,), writes=(2, 2), note="read 5; writes 2,2,default 1")
    add("exhaust/r1_n100", byte_stream(100, "d100"), reads=(1,), note="1,32,32,32,3,EOF = 6 reads")
    add("exhaust/r1x3_n3", byte_stream(3, "d3"), reads=(1, 1, 1), note="then default read hits EOF")
    add("exhaust/w1_n3", byte_stream(3, "d3"), writes=(1,))
    add("exhaust/r_cap_len", byte_stream(5000, "d5000"), reads=(1,) * MAX_SCHEDULE, note="schedule at length cap")
    add("exhaust/w_cap_len", byte_stream(4096, "d4096"), writes=(1,) * MAX_SCHEDULE)
    add("exhaust/rw_cap_len", byte_stream(3000, "d3000"), reads=(2,) * MAX_SCHEDULE, writes=(1,) * MAX_SCHEDULE)
    add("clamp/r33", d40, reads=(33,))
    add("clamp/r_max", d40, reads=(MAX_ACTION,), note="value at cap is clamped to request")
    add("clamp/w_max", d40, writes=(MAX_ACTION,))
    add("clamp/r1_2_3", d10, reads=(1, 2, 3))
    add("empty/default", b"")
    add("empty/r5", b"", reads=(5,), note="read at EOF consumes action, returns 0")
    add("empty/r5_rerr", b"", reads=(5, -1), note="EOF first -> -1 unreached")
    add("noflags/n40", d40, pass_flags=False, cat="noflags", note="no --reads/--writes at all")
    add("noflags/empty", b"", pass_flags=False, cat="noflags")
    add("noflags/n32", byte_stream(32, "buf32"), pass_flags=False, cat="noflags")
    add("emptyflags/n40", d40, reads_text="", writes_text="", cat="noflags")
    add("separate_flags/n40", d40, reads=(5, -1), writes=(2,), cat="noflags")
    return C


def reject_cases() -> list[Case]:
    C = []
    d = byte_stream(40, "d40")

    def rj(name, reads_text="", writes_text="", extra_argv=None, note=""):
        C.append(Case(f"reject/{name}", "reject", d, reads_text=reads_text, writes_text=writes_text,
                      expect_reject=True, extra_argv=extra_argv, note=note))

    bad_reads = {
        "r_zero": "0", "r_neg2": "-2", "r_one_zero": "1,0", "r_empty_item": "1,,2", "r_alpha": "a",
        "r_trailing_comma": "1,", "r_leading_comma": ",1", "r_space": " 1", "r_plus": "+1",
        "r_leading_zero": "01", "r_float": "1.0", "r_hex": "0x10", "r_dash": "-", "r_double_dash": "--1",
        "r_huge": "99999999999999999999", "r_cap_plus_1": str(MAX_ACTION + 1), "r_neg_pair": "-1-1",
        "r_inner_space": "1 2", "r_lone_comma": ",", "r_semicolon": "1;2", "r_neg_zero": "-0",
        "r_unicode_digit": "١", "r_tab": "1\t", "r_newline": "1\n", "r_int64_overflow": "9223372036854775808",
        "r_uint64_overflow": "18446744073709551616",
    }
    for k, v in bad_reads.items():
        rj(k, reads_text=v)
    bad_writes = {
        "w_neg2": "-2", "w_empty_item": "1,,0", "w_leading_zero": "01", "w_cap_plus_1": str(MAX_ACTION + 1),
        "w_alpha": "a", "w_neg_zero": "-0", "w_plus": "+0", "w_trailing_comma": "0,", "w_huge": "1" * 40,
    }
    for k, v in bad_writes.items():
        rj(k, writes_text=v)
    rj("r_too_many", reads_text=",".join(["1"] * (MAX_SCHEDULE + 1)), note="4097 entries")
    rj("w_too_many", writes_text=",".join(["0"] * (MAX_SCHEDULE + 1)))
    rj("argv_unknown_option", extra_argv=("--foo", "1"))
    rj("argv_duplicate_reads", extra_argv=("--reads", "1", "--reads", "2"))
    rj("argv_missing_value", extra_argv=("--reads",))
    rj("argv_positional", extra_argv=("1,2",))
    rj("argv_bad_max_calls", extra_argv=("--max-calls", "x"))
    return C


TIERS = {
    # (lengths, read_alpha, write_alpha, sched_len) for the two exhaustive families
    "quick": dict(a=([0, 1, 2], [-1, 1, 32], [-1, 0, 1], 1), b=([33], [-1, 1, 32], [-1, 0, 1], 1)),
    "standard": dict(a=([0, 1, 2, 3, 4], [-1, 1, 3, 32], [-1, 0, 1, 2], 2), b=([33], [-1, 1, 32], [-1, 0, 1, 32], 2)),
    "full": dict(a=([0, 1, 2, 3, 4, 5], [-1, 1, 2, 3, 32, 33], [-1, 0, 1, 2, 5, 33], 2),
                 b=([31, 32, 33, 65], [-1, 1, 31, 32], [-1, 0, 1, 31, 32], 2)),
}


def build_corpus(tier: str = "standard") -> list[Case]:
    if tier not in TIERS:
        raise ValueError(f"unknown tier {tier!r}; choose from {sorted(TIERS)}")
    t = TIERS[tier]
    cases: list[Case] = []
    cases += exhaustive_cases("a", *t["a"], category="exhaustive_small")
    cases += exhaustive_cases("b", *t["b"], category="exhaustive_buffer")
    cases += directed_cases()
    from pathlib import Path
    vectors = json.loads((Path(__file__).resolve().parents[1] / 'independent_vectors.json').read_text())
    cases += [Case('independent/' + v['name'], 'independent_vectors', bytes.fromhex(v['input_hex']),
                   tuple(v['reads']), tuple(v['writes']), note='Astra hand-calculated; oracle checked by unit test')
              for v in vectors]
    cases += reject_cases()
    names = [c.name for c in cases]
    from collections import Counter
    dup = {n for n, count in Counter(names).items() if count > 1}
    if dup:
        raise RuntimeError(f"duplicate case names: {sorted(dup)[:5]}")
    return cases
