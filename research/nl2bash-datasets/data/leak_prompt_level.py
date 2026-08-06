"""Robustness: the 773 tasks are only 606 distinct prompts, and the clean group is only 27.
Records within a repeated prompt are not independent, so redo the comparison per distinct prompt.
"""
import json, math, statistics as st
from collections import defaultdict

norm = lambda s: " ".join((s or "").split())
SFT = {norm(r.get("input", "")) for r in json.load(open("extract/data__sft__sft_command.json"))}
scored = [r for r in json.load(open("testres/singleline_eval_20251222_022036.json"))
          if r.get("has_test_script")]

by = defaultdict(list)
for r in scored:
    by[norm(r["input_task"])].append(r)

def wilson(k, n):
    """95% Wilson score interval for k successes in n, as percentages.

    Wilson rather than normal approximation because the clean subset is tiny (27 prompts) and
    lands near the ends of the scale, where the normal interval is badly wrong.
    """
    if not n: return (0, 0)
    p, z = k / n, 1.959963985
    d = 1 + z*z/n; c = p + z*z/(2*n)
    m = z*math.sqrt(p*(1-p)/n + z*z/(4*n*n))
    return (100*(c-m)/d, 100*(c+m)/d)

print("PROMPT-LEVEL (a prompt counts as passed if a majority of its records passed)\n")
for name, keys in (("leaked into SFT", [p for p in by if p in SFT]),
                   ("clean of SFT",    [p for p in by if p not in SFT])):
    n = len(keys)
    k = sum(1 for p in keys
            if sum(bool(r["func_pass"]) for r in by[p]) * 2 >= len(by[p]))
    lo, hi = wilson(k, n)
    print(f"  {name:18s} {k:>3d}/{n:<3d} = {100*k/n:5.1f}%  [{lo:.1f}, {hi:.1f}]")

print("\nThe x16 repeated clean prompt, on its own:")
big = max((p for p in by if p not in SFT), key=lambda p: len(by[p]))
g = by[big]
print(f"  '{big[:66]}'")
print(f"  {sum(bool(r['func_pass']) for r in g)}/{len(g)} records pass")

print("\nDrop it entirely and re-run the record-level comparison:")
rest = [r for r in scored if norm(r["input_task"]) != big]
L = [r for r in rest if norm(r["input_task"]) in SFT]
C = [r for r in rest if norm(r["input_task"]) not in SFT]
for nm, g in (("leaked", L), ("clean", C)):
    k = sum(bool(r["func_pass"]) for r in g)
    lo, hi = wilson(k, len(g))
    print(f"  {nm:8s} {k:>3d}/{len(g):<3d} = {100*k/len(g):5.1f}%  [{lo:.1f}, {hi:.1f}]")

print("\nLength-matched, prompt-deduplicated (one record per distinct prompt):")
dedup = [by[p][0] for p in by]
medlen = st.median([len(r["reference_code"]) for r in dedup if norm(r["input_task"]) not in SFT])
for nm, g in (("leaked", [r for r in dedup if norm(r["input_task"]) in SFT and len(r["reference_code"]) >= medlen]),
              ("clean",  [r for r in dedup if norm(r["input_task"]) not in SFT and len(r["reference_code"]) >= medlen])):
    k = sum(bool(r["func_pass"]) for r in g)
    lo, hi = wilson(k, len(g))
    print(f"  {nm:8s} {k:>3d}/{len(g):<3d} = {100*k/len(g):5.1f}%  [{lo:.1f}, {hi:.1f}]")
