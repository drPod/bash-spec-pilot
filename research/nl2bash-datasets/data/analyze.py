import json,urllib.request,sys,hashlib,warnings
warnings.filterwarnings("ignore")
import pandas as pd

def api(u):
    req=urllib.request.Request(u,headers={"User-Agent":"research"})
    with urllib.request.urlopen(req,timeout=90) as r: return json.load(r)

CMD_HINTS=["cmd","command","bash","shell","code","output","completion","response","answer","gold","script","target","canonical","solution"]
NL_HINTS=["nl","instruction","prompt","query","question","input","text","description","invocation","intent"]

def pick(cols,hints,exclude=()):
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
    pq=api(f"https://huggingface.co/api/datasets/{did}/parquet")
    urls=[]
    def walk(o):
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
    res={"id":did,"sampled_rows":len(df),"n_parquet_files":len(urls),"cols":cols,"cmd_col":str(cmdc),"nl_col":str(nlc)}
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
