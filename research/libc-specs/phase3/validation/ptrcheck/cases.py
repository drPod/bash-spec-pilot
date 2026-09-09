"""Bounded exhaustive, directed, hand-derived, and reject cases with portable SHA-256 payloads."""
from __future__ import annotations

import hashlib
import itertools
import json
from collections import Counter
from dataclasses import dataclass
from pathlib import Path

from .actions import MAX_ACTION, format_actions

HERE = Path(__file__).resolve().parent
HAND_TRACES_PATH = HERE.parent / "hand_traces.json"


def payload(n: int, seed: str) -> bytes:
    out = bytearray()
    i = 0
    while len(out) < n:
        out += hashlib.sha256(f"ptrcheck:{seed}:{i}".encode()).digest()
        i += 1
    return bytes(out[:n])


@dataclass(frozen=True)
class Case:
    name: str
    category: str
    data: bytes
    reads: tuple = ()
    writes: tuple = ()
    reads_text: str | None = None     # raw CLI text (reject cases only)
    writes_text: str | None = None
    expect_reject: bool = False
    pass_flags: bool = True           # False => no --reads/--writes flags at all
    extra_argv: tuple | None = None   # full schedule-argument override (reject cases)
    note: str = ""

    def schedule_argv(self) -> list[str]:
        if self.extra_argv is not None:
            return list(self.extra_argv)
        if not self.pass_flags:
            return []
        r = self.reads_text if self.reads_text is not None else format_actions(self.reads)
        w = self.writes_text if self.writes_text is not None else format_actions(self.writes)
        return ["--reads", r, "--writes", w]

    def as_case_dict(self) -> dict:
        return {"name": self.name, "input_hex": self.data.hex(), "reads": list(self.reads), "writes": list(self.writes)}

    def manifest(self) -> dict:
        return {"name": self.name, "category": self.category, "data_len": len(self.data),
                "data_sha256": hashlib.sha256(self.data).hexdigest(), "schedule_argv": self.schedule_argv(),
                "expect_reject": self.expect_reject, "note": self.note}


def corpus_manifest(cases: list[Case]) -> list[dict]:
    return [c.manifest() for c in cases]


def corpus_hash(cases: list[Case]) -> str:
    return hashlib.sha256(json.dumps(corpus_manifest(cases), sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def _schedules(alphabet, max_len):
    for L in range(max_len + 1):
        yield from itertools.product(alphabet, repeat=L)


def exhaustive_cases(lengths, read_alpha, write_alpha, sched_len, category="exhaustive") -> list[Case]:
    cases = []
    for n in lengths:
        data = payload(n, f"exh-{n}")
        for r in _schedules(read_alpha, sched_len):
            for w in _schedules(write_alpha, sched_len):
                rn = format_actions(r) or "_"
                wn = format_actions(w) or "_"
                cases.append(Case(f"{category}/n{n}/r{rn}/w{wn}", category, data, tuple(r), tuple(w)))
    return cases


def directed_cases() -> list[Case]:
    C: list[Case] = []

    def add(name, data, reads=(), writes=(), note="", cat="directed", **kw):
        C.append(Case(f"{cat}/{name}", cat, data, tuple(reads), tuple(writes), note=note, **kw))

    for n in (31, 32, 33, 65):
        d = payload(n, f"buf{n}")
        add(f"buf{n}/default", d, note="buffer boundary, default schedules")
        add(f"buf{n}/w31", d, writes=(31,), note="short write 31 then default retry")
        add(f"buf{n}/w1", d, writes=(1,), note="short write 1 then default retry at offset 1")
        add(f"buf{n}/w16_16", d, writes=(16, 16), note="two half writes")
        add(f"buf{n}/w16_15", d, writes=(16, 15), note="16+15 then default 1 at offset 31")
        add(f"buf{n}/w33", d, writes=(33,), note="over-request write clamped to the residual")
        add(f"buf{n}/r31", d, reads=(31,), note="short read 31 then default")
        add(f"buf{n}/r33", d, reads=(33,), note="over-request read clamped to 32")
        add(f"buf{n}/r1w1", d, reads=(1,), writes=(1,))
        add(f"buf{n}/r32_rerr", d, reads=(32, -1), note="read error after the first chunk")
        add(f"buf{n}/w5_werr", d, writes=(5, -1), note="write error after 5 bytes: pending residual retained")
        add(f"buf{n}/w5_wzero", d, writes=(5, 0), note="zero write after 5 bytes")
        add(f"buf{n}/wzero", d, writes=(0,), note="zero write first: whole chunk pending")
        add(f"buf{n}/w1x8", d, writes=(1,) * 8, note="eight single-byte retries, then default")
    d33 = payload(33, "buf33")
    add("cross33/r32_1", d33, reads=(32, 1), note="32 then 1 then EOF")
    add("cross33/r31_2", d33, reads=(31, 2), note="31 then 2 then EOF; second chunk overwrites 2 stale cells")
    add("cross33/r16x3", d33, reads=(16, 16, 16), note="16,16,1(clamped by unread) then EOF")
    d65 = payload(65, "buf65")
    add("cross65/r33_33", d65, reads=(33, 33), note="both clamped to 32; 1-byte tail")
    add("cross65/w32_32_1", d65, writes=(32, 32, 1))
    add("cross65/r1_w1", d65, reads=(1,), writes=(1,), note="1-byte chunk then 32,32 with default writes")
    d64 = payload(64, "buf64")
    add("cross64/default", d64, note="exactly two full chunks then EOF")
    add("cross64/w31_1_31_1", d64, writes=(31, 1, 31, 1))
    every = bytes(range(256))
    add("every256/forward", every)
    add("every256/reverse_w1x5", every[::-1], writes=(1,) * 5)
    add("every256/werr_third_chunk", every, writes=(32, 32, 5, -1), note="pending = 27 bytes of chunk 3")
    add("every256/wzero_third_chunk", every, writes=(32, 32, 5, 0))
    add("every256/rerr_after_2", every, reads=(32, 32, -1))
    add("multi/n1000_default", payload(1000, "mb1000"))
    add("multi/n1000_r7x10_w5x10", payload(1000, "mb1000"), reads=(7,) * 10, writes=(5,) * 10)
    add("multi/n4096_default", payload(4096, "mb4096"), note="128 chunks + EOF")
    # zero-write looping (only mutants loop; the original fail-stops at the first 0)
    d40 = payload(40, "d40")
    add("loop/wzero_x8", d40, writes=(0,) * 8, note="original: status 2 after one call; zero-retry mutant hits the strict call cap")
    add("loop/w1_wzero_x8", d40, writes=(1,) + (0,) * 8)
    add("short/w1_1_werr", d40, writes=(1, 1, -1))
    add("short/w1_1_wzero", d40, writes=(1, 1, 0))
    add("short/w7x4_n32", payload(32, "buf32"), writes=(7, 7, 7, 7), note="7,7,7,7 then default 4 at offset 28")
    add("short/w1x32_n32", payload(32, "buf32"), writes=(1,) * 32, note="32 single-byte retries")
    add("short/w1x33_n32", payload(32, "buf32"), writes=(1,) * 33, note="33rd action never consumed")
    add("rerr/first", d40, reads=(-1,))
    add("rerr/first_empty", b"", reads=(-1,), note="error precedes the EOF test")
    add("rerr/after_5", d40, reads=(5, -1))
    add("rerr/after_32_8", d40, reads=(32, 8, -1), note="third call is the -1: status 1 at the EOF position")
    add("rerr/unreached", d40, reads=(32, 8, 32, -1), note="EOF on the third call; -1 never consumed")
    add("empty/default", b"")
    add("empty/r5", b"", reads=(5,))
    add("empty/werr_unused", b"", writes=(-1,))
    add("exhaust/r1_n100", payload(100, "d100"), reads=(1,), note="1,32,32,32,3,EOF = 6 reads")
    add("exhaust/r1x3_n3", payload(3, "d3"), reads=(1, 1, 1))
    add("exhaust/w1_n3", payload(3, "d3"), writes=(1,))
    add("clamp/r_max", d40, reads=(MAX_ACTION,))
    add("clamp/w_max", d40, writes=(MAX_ACTION,))
    add("clamp/r1_2_3", payload(10, "d10"), reads=(1, 2, 3))
    add("noflags/n40", d40, pass_flags=False, cat="noflags")
    add("noflags/empty", b"", pass_flags=False, cat="noflags")
    add("emptyflags/n33", d33, reads_text="", writes_text="", cat="noflags")
    return C


def reject_cases() -> list[Case]:
    d = payload(40, "d40")
    C = []

    def rj(name, reads_text="", writes_text="", extra_argv=None):
        C.append(Case(f"reject/{name}", "reject", d, reads_text=reads_text, writes_text=writes_text,
                      expect_reject=True, extra_argv=extra_argv))

    rj("r_zero", reads_text="0")
    rj("r_neg2", reads_text="-2")
    rj("r_leading_zero", reads_text="01")
    rj("r_plus", reads_text="+1")
    rj("w_neg2", writes_text="-2")
    rj("w_trailing_comma", writes_text="0,")
    rj("r_cap_plus_1", reads_text=str(MAX_ACTION + 1))
    rj("argv_unknown_option", extra_argv=("--foo", "1"))
    rj("argv_duplicate_reads", extra_argv=("--reads", "1", "--reads", "2"))
    return C


def hand_cases() -> list[Case]:
    obj = json.loads(HAND_TRACES_PATH.read_text())
    return [Case("hand/" + t["name"], "hand", bytes.fromhex(t["input_hex"]), tuple(t["reads"]), tuple(t["writes"]),
                 note="independently hand-derived event trace; see hand_traces.json") for t in obj["traces"]]


TIERS = {
    # lengths, read alphabet, write alphabet, max schedule length
    "quick": ([0, 1, 33], [-1, 1, 32], [-1, 0, 1, 31], 1),
    "standard": ([0, 1, 32, 33, 65], [-1, 1, 32], [-1, 0, 31], 2),
    "full": ([0, 1, 2, 31, 32, 33, 64, 65], [-1, 1, 32], [-1, 0, 1, 31], 2),
}
CASE_BUDGET = 1000


def build_cases(tier: str = "standard") -> list[Case]:
    if tier not in TIERS:
        raise ValueError(f"unknown tier {tier!r}; choose from {sorted(TIERS)}")
    cases = exhaustive_cases(*TIERS[tier]) + directed_cases() + hand_cases() + reject_cases()
    dup = {n for n, k in Counter(c.name for c in cases).items() if k > 1}
    if dup:
        raise RuntimeError(f"duplicate case names: {sorted(dup)[:5]}")
    return cases
