"""Does BashBench 2026's self-contamination actually inflate its headline number?

The audit established that 709 of the 773 scored single-line benchmark tasks appear
byte-identically in the SFT file shipped in the same release. This splits the authors'
own released per-task scores by that line and compares pass rates.
"""
import json, math, sys

EX = "extract/"
TR = "testres/singleline_eval_20251222_022036.json"

norm = lambda s: " ".join((s or "").split())

# ---- the leaked / clean partition, rebuilt exactly as in the audit -------------------------
sft = json.load(open(EX + "data__sft__sft_command.json"))
grpo = json.load(open(EX + "data__grpo__grpo_command.json"))
SFT = {norm(r.get("input", "")) for r in sft}
GRPO = {norm(r.get("input", "")) for r in grpo}
print(f"SFT inputs {len(SFT):,} | GRPO inputs {len(GRPO):,}")

# ---- the authors' own scored results -------------------------------------------------------
res = json.load(open(TR))
scored = [r for r in res if r.get("has_test_script")]
print(f"scored tasks with a test script: {len(scored)}  (paper: 773)\n")


def wilson(k, n):
    """95% Wilson interval — the right one for proportions near the boundary at small n."""
    if n == 0:
        return (0.0, 0.0)
    p, z = k / n, 1.959963985
    d = 1 + z * z / n
    c = p + z * z / (2 * n)
    m = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))
    return (100 * (c - m) / d, 100 * (c + m) / d)


groups = {
    "LEAKED into SFT": [r for r in scored if norm(r["input_task"]) in SFT],
    "clean of SFT": [r for r in scored if norm(r["input_task"]) not in SFT],
    "LEAKED into SFT or GRPO": [r for r in scored
                                if norm(r["input_task"]) in SFT or norm(r["input_task"]) in GRPO],
    "clean of both": [r for r in scored
                      if norm(r["input_task"]) not in SFT and norm(r["input_task"]) not in GRPO],
}

out = {}
print(f"{'group':28s} {'n':>5s} {'FuncRate':>21s} {'FullRate':>21s}")
print("-" * 78)
for name, g in groups.items():
    n = len(g)
    row = {"n": n}
    cells = []
    for metric in ("func_pass", "full_pass"):
        k = sum(bool(r.get(metric)) for r in g)
        lo, hi = wilson(k, n)
        row[metric] = {"k": k, "pct": round(100 * k / n, 2) if n else None,
                       "ci95": [round(lo, 1), round(hi, 1)]}
        cells.append(f"{k:>4}/{n:<4} {100*k/n:5.1f}% [{lo:4.1f},{hi:4.1f}]" if n else "  n/a")
    print(f"{name:28s} {n:>5} {cells[0]:>21s} {cells[1]:>21s}")
    out[name] = row

# ---- the gap, with a Fisher exact test ------------------------------------------------------
def fisher(a, b, c, d):
    """two-sided Fisher exact on [[a,b],[c,d]]"""
    from math import comb
    n = a + b + c + d
    r1, c1 = a + b, a + c
    def p(x):
        """Hypergeometric probability of exactly x in the cell, under independence."""
        return comb(r1, x) * comb(n - r1, c1 - x) / comb(n, c1)
    p0 = p(a)
    lo = max(0, c1 - (n - r1))
    hi = min(r1, c1)
    return sum(p(x) for x in range(lo, hi + 1) if p(x) <= p0 * (1 + 1e-9))


print()
for metric in ("func_pass", "full_pass"):
    for leak, clean in (("LEAKED into SFT", "clean of SFT"),
                        ("LEAKED into SFT or GRPO", "clean of both")):
        L, C = groups[leak], groups[clean]
        lk = sum(bool(r.get(metric)) for r in L)
        ck = sum(bool(r.get(metric)) for r in C)
        gap = 100 * lk / len(L) - 100 * ck / len(C)
        pv = fisher(lk, len(L) - lk, ck, len(C) - ck)
        star = "***" if pv < 0.001 else "**" if pv < 0.01 else "*" if pv < 0.05 else "(n.s.)"
        print(f"{metric:10s} {leak:24s} - {clean:14s}: "
              f"{gap:+6.1f} pts   Fisher p = {pv:.4f} {star}")
        out.setdefault("gaps", []).append(
            {"metric": metric, "leaked_group": leak, "clean_group": clean,
             "gap_pts": round(gap, 1), "fisher_p": pv})

json.dump(out, open("leak_effect.json", "w"), indent=1)
print("\nwrote leak_effect.json")
