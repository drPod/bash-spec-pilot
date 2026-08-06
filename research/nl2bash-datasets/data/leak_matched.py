"""Disentangle leakage from difficulty by matching on difficulty.

The clean tasks are much harder than the leaked ones (8x the pipes/redirects), so the raw
+77.6pt gap is confounded. If DIFFICULTY explains the gap, then leaked tasks at the same
complexity as the clean ones should also score ~22%. If LEAKAGE explains it, leaked tasks
should stay near 99% at every complexity level.
"""
import json, statistics as st

EX = "extract/"
norm = lambda s: " ".join((s or "").split())
sft = json.load(open(EX + "data__sft__sft_command.json"))
SFT = {norm(r.get("input", "")) for r in sft}
res = json.load(open("testres/singleline_eval_20251222_022036.json"))
scored = [r for r in res if r.get("has_test_script")]

cx = lambda r: sum(r["reference_code"].count(c) for c in ("|", ">", "&&", ";"))
for r in scored:
    r["_leak"] = norm(r["input_task"]) in SFT
    r["_cx"] = cx(r)

L = [r for r in scored if r["_leak"]]
C = [r for r in scored if not r["_leak"]]

print("=" * 82)
print("MATCHED ON COMPLEXITY (pipes + redirects + && + ; in the reference solution)")
print("=" * 82)
print(f"{'complexity band':>16s} {'leaked n':>9s} {'leaked pass':>12s} {'clean n':>8s} {'clean pass':>12s}")
print("-" * 82)
BANDS = [(0, 0), (1, 2), (3, 5), (6, 9), (10, 14), (15, 10**6)]
rows = []
for lo, hi in BANDS:
    lg = [r for r in L if lo <= r["_cx"] <= hi]
    cg = [r for r in C if lo <= r["_cx"] <= hi]
    lp = f"{100*sum(r['func_pass'] for r in lg)/len(lg):5.1f}%" if lg else "   --"
    cp = f"{100*sum(r['func_pass'] for r in cg)/len(cg):5.1f}%" if cg else "   --"
    band = f"{lo}-{hi}" if hi < 10**6 else f"{lo}+"
    print(f"{band:>16s} {len(lg):>9d} {lp:>12s} {len(cg):>8d} {cp:>12s}")
    rows.append({"band": band, "leaked_n": len(lg), "clean_n": len(cg),
                 "leaked_pass": lp.strip(), "clean_pass": cp.strip()})

print("\n" + "=" * 82)
print("THE DIRECT TEST: leaked tasks AS HARD AS the clean ones")
print("=" * 82)
med = st.median([r["_cx"] for r in C])
hardL = [r for r in L if r["_cx"] >= med]
hardC = [r for r in C if r["_cx"] >= med]
print(f"  clean-set median complexity = {med}")
for nm, g in (("leaked & complexity >= clean median", hardL),
              ("clean  & complexity >= clean median", hardC)):
    if g:
        k = sum(r["func_pass"] for r in g)
        print(f"  {nm:38s} n={len(g):>4d}  FuncRate {100*k/len(g):5.1f}%")

print("\n  Also matched on reference-solution LENGTH:")
medlen = st.median([len(r["reference_code"]) for r in C])
for nm, g in (("leaked & ref length >= clean median", [r for r in L if len(r["reference_code"]) >= medlen]),
              ("clean  & ref length >= clean median", [r for r in C if len(r["reference_code"]) >= medlen])):
    if g:
        k = sum(r["func_pass"] for r in g)
        print(f"  {nm:38s} n={len(g):>4d}  FuncRate {100*k/len(g):5.1f}%")

json.dump(rows, open("leak_matched.json", "w"), indent=1)
