"""Pull only the single-line evaluation_results files out of the 1.1 GB Zenodo archive
via HTTP range requests, so we never download the whole thing."""
import os, sys
from remotezip import RemoteZip

URL = "https://zenodo.org/records/18408692/files/BashCoder-R1.zip?download=1"
OUT = "results"
os.makedirs(OUT, exist_ok=True)

with RemoteZip(URL) as z:
    names = [n for n in z.namelist()
             if "evaluation_results/single-line/" in n and n.endswith(".json")]
    print(f"{len(names)} result files")
    for n in names:
        dest = os.path.join(OUT, n.split("/")[-1])
        if os.path.exists(dest) and os.path.getsize(dest) > 0:
            print("  cached", os.path.basename(dest)); continue
        with z.open(n) as fh, open(dest, "wb") as out:
            out.write(fh.read())
        print(f"  {os.path.getsize(dest)/1e6:6.1f} MB  {os.path.basename(dest)}")
