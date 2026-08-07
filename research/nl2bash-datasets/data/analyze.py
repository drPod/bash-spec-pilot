"""Measure each shortlisted HuggingFace dataset from its actual contents, not its card.

Pulls the Parquet export, guesses the command and NL columns from their names, classifies every
command as single or multi-line, and MD5-hashes the whitespace-normalized commands so datasets
can be compared to each other later.

    python analyze.py <ids.txt> <out.json>      # produced res1.json and res2.json

The column guess is the weak step. It picked wrong for four datasets, which fix.py re-measures
into res_fix.json, so check `cmd_col` and `samples` on a row before trusting its numbers.
"""
import json,urllib.request,sys,hashlib,warnings
warnings.filterwarnings("ignore")
import pandas as pd

def api(u):
    """GET a HuggingFace API endpoint and return the parsed JSON."""
    req=urllib.request.Request(u,headers={"User-Agent":"research"})
    with urllib.request.urlopen(req,timeout=90) as r: return json.load(r)

CMD_HINTS=["cmd","command","bash","shell","code","output","completion","response","answer","gold","script","target","canonical","solution"]
NL_HINTS=["nl","instruction","prompt","query","question","input","text","description","invocation","intent"]

def pick(cols,hints,exclude=()):
    """Guess which column holds the commands (or the NL), by name.

    Exact name matches win over substring matches, and hints are tried in priority order. This is
    the step that misfired on four datasets: it will happily return an English column, a constant
    like `target_language`, or stdout instead of the command. fix.py overrides those by hand.
    """
    low={c:str(c).lower() for c in cols}
    for h in hints:
        for c in cols:
            if c in exclude: continue
            if low[c]==h: return c
    for h in hints:
        for c in cols:
            if c in exclude: continue
            if h in low[c]: return c
    return None

def analyze(did,max_rows=60000):
    """Measure one dataset: row count, single/multi-line split, unique command hashes, samples.

    Reads up to max_rows rows across at most 6 Parquet files, so large datasets are sampled rather
    than pulled whole; rows measured this way are labelled as sampled in the deliverable.
    """
    pq=api(f"https://huggingface.co/api/datasets/{did}/parquet")
    urls=[]
    def walk(o):
        """Collect every .parquet URL anywhere in the nested config/split response."""
        if isinstance(o,dict):
            for v in o.values(): walk(v)
        elif isinstance(o,list):
            for v in o: walk(v)
        elif isinstance(o,str) and o.endswith(".parquet"): urls.append(o)
    walk(pq)
    if not urls: return {"id":did,"err":"no parquet"}
    frames=[];tot=0
    for u in urls[:6]:
        try: df=pd.read_parquet(u)
        except Exception: continue
        frames.append(df); tot+=len(df)
        if tot>=max_rows: break
    if not frames: return {"id":did,"err":"parquet read failed"}
    df=pd.concat(frames,ignore_index=True)
    cols=[str(c) for c in df.columns]
    cmdc=pick(list(df.columns),CMD_HINTS)
    nlc=pick(list(df.columns),NL_HINTS,exclude=(cmdc,))
    res={"id":did,"sampled_rows":len(df),"n_parquet_files":len(urls),"cols":cols,"cmd_col":cmdc,"nl_col":nlc}
    if cmdc is not None:
        vals=[("" if v is None else str(v)) for v in df[cmdc].tolist()]
        vals=[v for v in vals if v and v.lower()!="nan"]
        if not vals: return res
        multi=[("\n" in v.strip()) for v in vals]
        res["n_nonempty"]=len(vals)
        res["n_multiline_sampled"]=sum(multi)
        res["n_singleline_sampled"]=len(vals)-sum(multi)
        res["pct_multiline"]=round(100*sum(multi)/len(vals),1)
        norm=[" ".join(v.split()) for v in vals]
        res["hashes"]=sorted(set(hashlib.md5(x.encode("utf-8","replace")).hexdigest()[:12] for x in norm))
        res["n_unique_cmds"]=len(res["hashes"])
        res["samples"]=[v[:200] for v in vals[:3]]
    if nlc is not None:
        nls=[("" if v is None else str(v)) for v in df[nlc].tolist()]
        nls=[" ".join(v.split()) for v in nls if v and v.lower()!="nan"]
        res["nl_hashes"]=sorted(set(hashlib.md5(x.encode("utf-8","replace")).hexdigest()[:12] for x in nls))
        res["nl_samples"]=[v[:150] for v in nls[:2]]
    return res

out={}
for did in [l.strip() for l in open(sys.argv[1]) if l.strip()]:
    try: r=analyze(did)
    except Exception as e: r={"id":did,"err":str(e)[:150]}
    out[did]=r
    print(f'{did:<55} n={r.get("n_nonempty")} col={r.get("cmd_col")} multi%={r.get("pct_multiline")} uniq={r.get("n_unique_cmds")} {r.get("err","")}',flush=True)
    json.dump(out,open(sys.argv[2],"w"))
