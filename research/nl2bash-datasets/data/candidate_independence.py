"""Is BashBench 2026's FuncRate a function of the generated code at all?

Static reading of the shipped harness says no: `execute_test_script` writes the candidate to
`solution.sh` and then runs `test.sh`, but no test script in the release references solution.sh.
That predicts something falsifiable in the already-released per-task results:

    among models whose code was successfully EXTRACTED for a given task, func_pass should be
    the SAME for every model -- because the thing being executed is the same either way.

A real functional test would produce the opposite: weak models failing tasks strong models pass.
"""
import glob, json, os, re, collections

FILES = sorted(glob.glob("ml_base_full/*.json")) + ["testres_ml/multiline_eval_20251115_124953_20260123_033003.json"]
name = lambda f: re.sub(r"_?\d{8}_\d{6}", "", os.path.basename(f)
                        .replace("multiline_eval_", "").replace(".json", "")) or "BashCoder-R1(ours)"

models = {}
for f in FILES:
    d = json.load(open(f))
    if isinstance(d, dict):
        d = d.get("results", d.get("details", []))
    models[name(f)] = {r["sample_id"]: r for r in d}
print(f"{len(models)} models x 179 tasks\n")

ids = sorted(set.intersection(*[set(m) for m in models.values()]))
NO_CODE = "No code to execute"

# Per task: among models where extraction produced code, do they agree on func_pass?
agree = disagree = 0
disagreements = []
for sid in ids:
    votes = {}
    for mn, m in models.items():
        r = m[sid]
        if (r.get("func_error") or "") == NO_CODE or not (r.get("generated_code") or "").strip():
            continue                       # extraction failed -> harness short-circuits, not a test result
        votes[mn] = bool(r.get("func_pass"))
    if len(votes) < 2:
        continue
    if len(set(votes.values())) == 1:
        agree += 1
    else:
        disagree += 1
        disagreements.append((sid, votes))

tot = agree + disagree
print("=" * 92)
print("Do models with extractable code agree on func_pass, task by task?")
print("=" * 92)
print(f"  identical verdict for every model : {agree}/{tot} = {100*agree/tot:.1f}%")
print(f"  any disagreement                  : {disagree}/{tot} = {100*disagree/tot:.1f}%")
print("\n  A functional test of the generated code cannot look like this: a 3B model and a 32B")
print("  model do not write the same script, so they should not get the same verdict.\n")

# What DOES vary between models is whether code could be extracted at all.
print("=" * 92)
print("What actually drives the reported FuncRate")
print("=" * 92)
print(f"  {'model':<34s}{'extracted':>11s}{'FuncRate':>10s}{'pass|extracted':>16s}")
for mn, m in sorted(models.items(), key=lambda kv: -sum(bool(r.get('func_pass')) for r in kv[1].values())):
    ext = [r for r in m.values()
           if (r.get("func_error") or "") != NO_CODE and (r.get("generated_code") or "").strip()]
    fp = sum(bool(r.get("func_pass")) for r in m.values())
    n = len(m)
    cond = 100 * sum(bool(r.get("func_pass")) for r in ext) / len(ext) if ext else 0
    print(f"  {mn:<34s}{100*len(ext)/n:>10.1f}%{100*fp/n:>9.1f}%{cond:>15.1f}%")

# The tasks that fail: same ones for everyone?
fail_sets = {}
for mn, m in models.items():
    fail_sets[mn] = {sid for sid, r in m.items()
                     if not r.get("func_pass") and (r.get("func_error") or "") != NO_CODE
                     and (r.get("generated_code") or "").strip()}
common = set.intersection(*fail_sets.values()) if fail_sets else set()
union = set.union(*fail_sets.values()) if fail_sets else set()
print(f"\n  tasks failing for EVERY model (with code): {len(common)}")
print(f"  tasks failing for at least one model     : {len(union)}")
print(f"  -> {100*len(common)/len(union):.0f}% of all observed failures are the same tasks for everyone")

print("\n  a sample of those universally-failing tasks and why:")
for sid in sorted(common)[:6]:
    err = (models['BashCoder-R1(ours)'][sid].get("func_error") or "")[:88].replace("\n", " ")
    print(f"    sample {sid}: {err}")

json.dump({"agree": agree, "disagree": disagree,
           "common_failures": sorted(common), "union_failures": sorted(union)},
          open("candidate_independence.json", "w"))
