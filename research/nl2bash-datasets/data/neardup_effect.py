"""Does the near-duplicate tail explain the multi-line score?

neardup.py found the 179 multi-line tasks are prompt-side indistinguishable from generator
siblings, but have a fatter code-side tail (12.3% above the sibling p95 vs 5% expected). If
that tail is real leakage it should show up as a pass-rate gradient, the same way byte-identical
leakage did on the single-line half.

NOTE: the causal reading these numbers were collected for is WITHDRAWN. benchmark-validity.md
shows the harness never executes the candidate, so func_pass is a property of the released test
scripts, not of any model. Read every rate below as a test-script exit rate.
"""
import json, re
import numpy as np

norm = lambda s: " ".join((s or "").split())
sim = json.load(open("neardup.json"))
code_sim = np.array(sim["code_test"])
prompt_sim = np.array(sim["test"])

ml_eval = json.load(open("extract/data__evaluation__script__evaluation_multi-line_script.json"))
res = json.load(open("testres_ml/multiline_eval_20251115_124953_20260123_033003.json"))
if isinstance(res, dict):
    res = res.get("results", res.get("details", []))
print(f"multi-line result records: {len(res)}; keys: {sorted(res[0].keys())[:14]}")

by_prompt = {}
for r in res:
    key = norm(r.get("input_task") or r.get("input") or "")
    by_prompt[key] = r

passes, cs, ps, missing = [], [], [], 0
for i, t in enumerate(ml_eval):
    r = by_prompt.get(norm(t["input"]))
    if r is None:
        missing += 1
        continue
    fp = r.get("func_pass")
    if fp is None:
        fp = r.get("functional_pass", r.get("passed"))
    passes.append(bool(fp))
    cs.append(code_sim[i])
    ps.append(prompt_sim[i])

passes, cs, ps = np.array(passes), np.array(cs), np.array(ps)
print(f"matched {len(passes)}/179 tasks to a scored record ({missing} unmatched); "
      f"overall FuncRate {100*passes.mean():.1f}%\n")


def wilson(k, n, z=1.96):
    """95% Wilson score interval for k successes in n, as proportions."""
    if n == 0:
        return (0.0, 0.0)
    p = k / n
    d = 1 + z * z / n
    c = (p + z * z / (2 * n)) / d
    h = z * ((p * (1 - p) / n + z * z / (4 * n * n)) ** 0.5) / d
    return (100 * max(0, c - h), 100 * min(1, c + h))


def band(label, mask):
    """Print pass rate with its confidence interval for one similarity band.

    Splitting by band is what tests whether the near-duplicate tail explains the pass rate: if it
    did, the high-similarity band would score above the low one.
    """
    n = mask.sum()
    if n == 0:
        print(f"  {label:<42s} n=    0")
        return
    k = passes[mask].sum()
    lo, hi = wilson(k, n)
    print(f"  {label:<42s} n={n:>5d}  FuncRate {100*k/n:5.1f}%  [{lo:.1f}, {hi:.1f}]")


print("=" * 88)
print("Multi-line pass rate by code-side similarity to the released training scripts")
print("=" * 88)
csib_p95 = 0.372  # sibling p95 from neardup.py
band("above sibling p95 (candidate near-dups)", cs > csib_p95)
band("below sibling p95", cs <= csib_p95)
for lo, hi in [(0, .15), (.15, .25), (.25, .40), (.40, .60), (.60, 1.01)]:
    band(f"code sim {lo:.2f}-{hi:.2f}", (cs >= lo) & (cs < hi))

print("\n" + "=" * 88)
print("Top 12 code-side matches -- are these real near-duplicates?")
print("=" * 88)
for i in np.argsort(-code_sim)[:12]:
    r = by_prompt.get(norm(ml_eval[i]["input"]))
    fp = r and (r.get("func_pass") if r.get("func_pass") is not None else r.get("passed"))
    print(f"  code={code_sim[i]:.3f} prompt={prompt_sim[i]:.3f} pass={fp}  "
          f"{norm(ml_eval[i]['input'])[:96]}")

if len(set(passes.tolist())) > 1:
    r = np.corrcoef(cs, passes.astype(float))[0, 1]
    print(f"\npoint-biserial corr(code similarity, pass) = {r:+.3f}")
    print(f"mean code sim | passed  = {cs[passes].mean():.3f}")
    print(f"mean code sim | failed  = {cs[~passes].mean():.3f}  (n={(~passes).sum()})")
