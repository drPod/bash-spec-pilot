"""A memorization signature that needs no execution.

For a leaked task there are TWO reference answers: the one in the SFT training file and the
one in the benchmark. The audit found they are never identical (0 shared input+output pairs).
So if the model is reciting training data rather than solving the task, its generated code
should match the SFT answer specifically -- and match it much more often on leaked tasks than
its code matches the benchmark answer on clean tasks.
"""
import json, re, difflib
from collections import defaultdict

norm = lambda s: " ".join((s or "").split())


def extract(text):
    """Same order of preference as the shipped BashScriptExtractor, simplified.
    Returns code with newlines INTACT -- strip_sb must run before any normalization,
    or the shebang regex eats a single-line string whole."""
    if not text:
        return ""
    t = re.sub(r"<think>.*?</think>", "", text, flags=re.S)
    m = re.search(r"```(?:bash|sh|shell)?\s*\n(.*?)```", t, re.S)
    if m:
        return m.group(1).strip()
    m = re.search(r"<answer>(.*?)</answer>", t, re.S)
    if m:
        return m.group(1).strip()
    return t.strip()


strip_sb = lambda c: norm(re.sub(r"^#!.*$", "", c or "", flags=re.M))

sft = json.load(open("extract/data__sft__sft_command.json"))
SFT_ANS = defaultdict(list)
for r in sft:
    SFT_ANS[norm(r.get("input", ""))].append(extract(r.get("output", "")))

scored = [r for r in json.load(open("testres/singleline_eval_20251222_022036.json"))
          if r.get("has_test_script")]

sim = lambda a, b: difflib.SequenceMatcher(None, a, b).ratio()

rows = {"leaked": [], "clean": []}
for r in scored:
    p = norm(r["input_task"])
    gen = strip_sb(r.get("generated_code", ""))
    ref = strip_sb(r.get("reference_code", ""))
    grp = "leaked" if p in SFT_ANS else "clean"
    best_sft = max((sim(gen, strip_sb(a)) for a in SFT_ANS.get(p, [])), default=None)
    rows[grp].append({"gen_vs_bench_ref": sim(gen, ref), "gen_vs_sft_ans": best_sft,
                      "exact_bench": gen == ref and bool(gen),
                      "exact_sft": bool(best_sft is not None and best_sft == 1.0),
                      "pass": bool(r["func_pass"])})

print("=" * 74)
print("Does the model reproduce the SFT answer, or solve the task?")
print("=" * 74)
for grp in ("leaked", "clean"):
    g = rows[grp]
    n = len(g)
    eb = sum(x["exact_bench"] for x in g)
    mb = sum(x["gen_vs_bench_ref"] for x in g) / n
    print(f"\n{grp.upper()}  (n={n})")
    print(f"  generated == benchmark reference, exactly : {eb}/{n} = {100*eb/n:.1f}%")
    print(f"  mean similarity to benchmark reference    : {mb:.3f}")
    if grp == "leaked":
        es = sum(x["exact_sft"] for x in g)
        ms = sum(x["gen_vs_sft_ans"] for x in g) / n
        print(f"  generated == SFT answer, exactly          : {es}/{n} = {100*es/n:.1f}%")
        print(f"  mean similarity to SFT answer             : {ms:.3f}")

print("\n" + "=" * 74)
print("Split leaked tasks by whether the model reproduced the SFT answer verbatim")
print("=" * 74)
L = rows["leaked"]
for label, sel in (("reproduced SFT answer verbatim", [x for x in L if x["exact_sft"]]),
                   ("did not", [x for x in L if not x["exact_sft"]])):
    if sel:
        k = sum(x["pass"] for x in sel)
        print(f"  {label:32s} n={len(sel):>4d}  FuncRate {100*k/len(sel):5.1f}%")

hi = [x for x in L if (x["gen_vs_sft_ans"] or 0) >= 0.9]
lo = [x for x in L if (x["gen_vs_sft_ans"] or 0) < 0.5]
for label, sel in (("SFT similarity >= 0.90", hi), ("SFT similarity < 0.50", lo)):
    if sel:
        k = sum(x["pass"] for x in sel)
        print(f"  {label:32s} n={len(sel):>4d}  FuncRate {100*k/len(sel):5.1f}%")
