"""Is the 'clean' half of BashBench 2026 actually clean?

The 179 multi-line tasks and the 64 non-leaked single-line tasks are clean of the released
SFT/GRPO sets. But the release also ships a 4.3 GB continued-pretraining corpus. This streams
that corpus (never materializing it) and Aho-Corasick-searches it for every one of those task
prompts, so we learn whether "clean" means "absent from training" or only "absent from the
two files anyone would think to check".
"""
import json, sys
import ahocorasick
from remotezip import RemoteZip

URL = "https://zenodo.org/records/18408692/files/BashCoder-R1.zip?download=1"
CPT = "BashCoder-R1/data/cpt/bash_cpt_with_general.jsonl"
EX = "extract/"
norm = lambda s: " ".join((s or "").split())

sft = json.load(open(EX + "data__sft__sft_command.json"))
SFT = {norm(r.get("input", "")) for r in sft}

# the authoritative 773 are the scored tasks in the released test_results file
scored = [r for r in json.load(open("testres/singleline_eval_20251222_022036.json"))
          if r.get("has_test_script")]
multi = json.load(open(EX + "data__evaluation__script__evaluation_multi-line_script.json"))

needles = {}
for r in scored:
    p = norm(r["input_task"])
    if p and p not in SFT:
        needles[p.lower()] = "single-clean"
for r in multi:
    p = norm(r.get("input", ""))
    if p:
        needles[p.lower()] = "multi"

# a control group: prompts we already know leaked, to prove the scanner works
leaked_ctrl = [norm(r["input_task"]) for r in scored if norm(r["input_task"]) in SFT][:60]
for p in leaked_ctrl:
    needles.setdefault(p.lower(), "single-leaked-CONTROL")

print(f"needles: {len(needles)}", file=sys.stderr)
for grp in ("single-clean", "multi", "single-leaked-CONTROL"):
    print(f"   {grp:24s} {sum(1 for v in needles.values() if v == grp)}", file=sys.stderr)

A = ahocorasick.Automaton()
for i, n in enumerate(needles):
    A.add_word(n, n)
A.make_automaton()

hits = set()
MAXLEN = max(len(n) for n in needles)
tail = b""
done = 0
with RemoteZip(URL) as z, z.open(CPT) as fh:
    while True:
        chunk = fh.read(1 << 24)          # 16 MB
        if not chunk:
            break
        done += len(chunk)
        buf = (tail + chunk).lower()
        for _, w in A.iter(buf.decode("utf-8", "replace")):
            hits.add(w)
        tail = chunk[-MAXLEN:]
        print(f"  {done/1e9:5.2f} GB  hits {len(hits)}", file=sys.stderr, flush=True)

out = {}
for grp in ("single-clean", "multi", "single-leaked-CONTROL"):
    tot = sum(1 for v in needles.values() if v == grp)
    h = sum(1 for n, v in needles.items() if v == grp and n in hits)
    out[grp] = {"total": tot, "in_cpt": h, "pct": round(100 * h / tot, 1) if tot else None}
    print(f"{grp:24s} {h}/{tot} = {out[grp]['pct']}% present in the CPT corpus")

json.dump(out, open("cpt_scan.json", "w"), indent=1)
