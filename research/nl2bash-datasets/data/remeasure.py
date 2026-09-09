"""Re-measure gold commands after the first pass mistakenly hashed English descriptions."""
import hashlib, io, json, re, sys, tarfile, urllib.parse, urllib.request

import pandas as pd

from resload import load

H = lambda s: hashlib.md5(" ".join(s.split()).encode("utf-8", "replace")).hexdigest()[:12]

REF_IDS = ["jiacheng-ye/nl2bash", "TRamesh2/NL2CMD", "Romit2004/LinuxCommands",
           "westenfelder/NL2SH-ALFA", "Edoigtrd/tldr-pages", "AnishJoshi/nl2bash-custom",
           "b-mc2/cli-commands-explained"]

res = load()

REF = set()
for r in REF_IDS:
    if r in res and res[r].get("hashes"):
        REF |= set(res[r]["hashes"])
        print(f"  ref {r:42s} {len(res[r]['hashes']):>7,}")
    else:
        print(f"  ref {r:42s} MISSING")
print(f"union of reference corpora: {len(REF):,} unique command hashes\n")


def parquet_urls(did, config, split):
    u = f"https://huggingface.co/api/datasets/{did}/parquet/{config}/{split}"
    return json.load(urllib.request.urlopen(u))


def load(did, config, split, columns, max_files=None):
    urls = parquet_urls(did, config, split)[:max_files]
    frames = [pd.read_parquet(io.BytesIO(urllib.request.urlopen(u).read()), columns=columns)
              for u in urls]
    return pd.concat(frames, ignore_index=True)


def report(name, cmds, note=""):
    """Include command samples to expose wrong-column measurements."""
    cmds = [c for c in (x.strip() for x in cmds) if c]
    hs = {H(c) for c in cmds}
    hit = len(hs & REF)
    pct = 100 * hit / len(hs) if hs else 0
    print(f"{name}\n  commands extracted : {len(cmds):,}  ({len(hs):,} unique)")
    print(f"  in reference union : {hit:,} = {pct:.1f}%   {note}")
    for c in cmds[:3]:
        print(f"    e.g. {c[:90]}")
    print()
    return {"name": name, "n_cmds": len(cmds), "n_unique": len(hs), "n_hit": hit,
            "pct": round(pct, 1), "note": note}


out = []

df = load("tiararodney/posix-sdc", "scenarios", "train", ["id", "reference_solution"])
cmds = [c for row in df["reference_solution"] if row is not None for c in row]
out.append(report(f"tiararodney/posix-sdc  ({len(df):,} scenarios)", cmds,
                  "exploded from list-valued reference_solution"))

df = load("ia03/terminal-bench", "default", "test", ["task_id", "archive"])
sols, n_with = [], 0
for blob in df["archive"]:
    try:
        tf = tarfile.open(fileobj=io.BytesIO(bytes(blob)))
    except Exception:
        continue
    got = False
    for m in tf.getmembers():
        if not m.isfile():
            continue
        base = m.name.rsplit("/", 1)[-1]
        if base in ("solution.sh", "solution.yaml"):
            txt = tf.extractfile(m).read().decode("utf-8", "replace")
            if base == "solution.yaml":
                txt = "\n".join(re.findall(r'^\s*-?\s*command:\s*(.+)$', txt, re.M))
            sols.append(txt)
            got = True
    n_with += got
print(f"terminal-bench: {n_with}/{len(df)} tasks ship an oracle solution")
cmds = [stripped for s in sols for ln in s.splitlines()
        for stripped in [ln.strip()] if stripped and not stripped.startswith("#")]
out.append(report(f"ia03/terminal-bench  ({n_with} tasks with oracle)", cmds,
                  "individual lines of solution.sh / solution.yaml"))

json.dump(out, open("remeasure.json", "w"), indent=1)
print("wrote remeasure.json")
