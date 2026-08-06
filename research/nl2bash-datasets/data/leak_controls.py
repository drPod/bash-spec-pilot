"""Adversarial checks on the +77.6pt leaked-vs-clean gap.

The gap is only evidence of memorization if the clean tasks are not simply harder.
"""
import json, statistics as st

EX = "extract/"
norm = lambda s: " ".join((s or "").split())

sft = json.load(open(EX + "data__sft__sft_command.json"))
SFT = {norm(r.get("input", "")) for r in sft}
res = json.load(open("testres/singleline_eval_20251222_022036.json"))
scored = [r for r in res if r.get("has_test_script")]
L = [r for r in scored if norm(r["input_task"]) in SFT]
C = [r for r in scored if norm(r["input_task"]) not in SFT]

print("=" * 78)
print("CHECK 1 — what do the 64 clean tasks actually look like?")
print("=" * 78)
for r in C[:12]:
    print(f"  [{'PASS' if r['func_pass'] else 'FAIL'}] {r['input_task'][:88]}")

print("\n" + "=" * 78)
print("CHECK 2 — are the clean tasks harder by any measurable proxy?")
print("=" * 78)


def stats(g, key, f):
    """Mean and median of f over a group, formatted for the side-by-side leaked/clean table."""
    v = [f(r) for r in g]
    return f"mean {st.mean(v):7.1f}   median {st.median(v):6.1f}"


for label, f in [("prompt length (chars)", lambda r: len(r["input_task"])),
                 ("reference code length", lambda r: len(r["reference_code"])),
                 ("reference code lines", lambda r: r["reference_code"].count("\n") + 1),
                 ("ref pipe/redirect count", lambda r: sum(r["reference_code"].count(c)
                                                           for c in ("|", ">", "&&", ";")))]:
    print(f"  {label:26s} leaked: {stats(L, label, f):42s}")
    print(f"  {'':26s} clean : {stats(C, label, f):42s}")

print("\n" + "=" * 78)
print("CHECK 3 — near-duplicate leakage: are the 'clean' 64 really unseen,")
print("          or just cosmetic variants of SFT entries?")
print("=" * 78)
low = {s.lower() for s in SFT}
tok = {frozenset(s.lower().split()) for s in SFT}
n_low = sum(1 for r in C if norm(r["input_task"]).lower() in low)
n_tok = sum(1 for r in C if frozenset(norm(r["input_task"]).lower().split()) in tok)
print(f"  match SFT after lowercasing        : {n_low}/64")
print(f"  match SFT as a bag of words        : {n_tok}/64")
print("  (any hits here mean the true clean set is even smaller, so the gap widens)")

print("\n" + "=" * 78)
print("CHECK 4 — the multi-line benchmark is 100% clean of SFT.")
print("          If 'clean' merely meant 'hard', it should score like the 64.")
print("=" * 78)
try:
    ml = json.load(open("testres_ml/multiline_eval_20251115_124953_20260123_033003.json"))
    mlr = [r for r in ml if r.get("has_test_script")]
    k = sum(bool(r.get("func_pass")) for r in mlr)
    print(f"  multi-line (all clean): {k}/{len(mlr)} = {100*k/len(mlr):.1f}% FuncRate")
except FileNotFoundError:
    print("  multi-line results not pulled yet")
