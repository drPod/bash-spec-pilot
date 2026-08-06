"""Range-request the multi-line baseline scores + the evaluation harness out of the 1.1 GB zip."""
import os, re, sys
from remotezip import RemoteZip

URL = "https://zenodo.org/records/18408692/files/BashCoder-R1.zip?download=1"
os.makedirs("harness", exist_ok=True)
os.makedirs("ml_base", exist_ok=True)

with RemoteZip(URL) as z:
    names = z.namelist()
    want = [n for n in names if n.startswith("BashCoder-R1/evaluation/") and n.endswith(".py")]
    want += [n for n in names
             if n.startswith("BashCoder-R1/test_results/multi-line/baselines/")
             and n.endswith("_summary.txt")]
    want += [n for n in names if n.startswith("BashCoder-R1/test_results/multi-line/ours/")]
    print(f"pulling {len(want)} members")
    for n in want:
        dst = ("harness/" if "/evaluation/" in n else "ml_base/") + n.rsplit("/", 1)[-1]
        if os.path.exists(dst):
            continue
        with z.open(n) as fh, open(dst, "wb") as out:
            out.write(fh.read())
        print("  ", dst)
