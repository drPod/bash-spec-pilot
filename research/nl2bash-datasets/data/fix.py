import json,urllib.request,hashlib,warnings
warnings.filterwarnings("ignore")
import pandas as pd
def api(u):
    req=urllib.request.Request(u,headers={"User-Agent":"research"})
    with urllib.request.urlopen(req,timeout=90) as r: return json.load(r)
def load(did,maxr=60000):
    pq=api(f"https://huggingface.co/api/datasets/{did}/parquet"); urls=[]
    def walk(o):
        if isinstance(o,dict):
            for v in o.values(): walk(v)
        elif isinstance(o,list):
            for v in o: walk(v)
        elif isinstance(o,str) and o.endswith(".parquet"): urls.append(o)
    walk(pq)
    fr=[];t=0
    for u in urls:
        try: df=pd.read_parquet(u)
        except Exception: continue
        fr.append(df); t+=len(df)
        if t>=maxr: break
    return pd.concat(fr,ignore_index=True) if fr else None
# explicit (dataset, command_column, nl_column)
FIX=[("AnishJoshi/nl2bash-custom","bash_code","nl_command"),
     ("saurabh5/rlvr-code-data-bash","translated_solution","translated_problem"),
     ("adeelahmad/bash-agent-grpo-pairs","ground_truth","prompt"),
     ("jragsdale1/ShIO-bash-26.1","input",None),
     ("Frost2o24/bash-instruct-55k",None,None),
     ("Frost2o24/bash-instruct-II-55k",None,None),
     ("NickIBrody/linux-shell-corpus-ru-en",None,None),
     ("laion/stackexchange-unix-sandboxes-verified",None,None),
     ("penfever/nl2bash-verified-cleaned",None,None),
     ("Jawajawa/command-linux-bash-balanced-sft",None,None),
     ("GunA-SD/bash_code",None,None),
     ("mlech26l/shell-helper",None,None),
     ("ajayk007/shellsmith-commands",None,None),
     ("EuniAI/TerminalWorld",None,None),
     ("iselabvn/Linux-terminal-tool-calling",None,None),
     ("nvidia/Nemotron-Terminal-Synthetic-Tasks",None,None),
     ("AryaYT/nl2shell-terminal-bench",None,None),
     ("spignelon/bash_history",None,None),
     ("feifeinoban/Shell",None,None)]
out={}
for did,cc,nc in FIX:
    try: df=load(did)
    except Exception as e: print(f"{did}: ERR {str(e)[:80]}"); continue
    if df is None: print(f"{did}: no data"); continue
    print("="*100); print(f"{did}  rows={len(df)}  cols={list(df.columns)}")
    if cc is None:
        for c in df.columns[:12]:
            try: s=[str(x)[:110] for x in df[c].head(2).tolist()]
            except Exception: continue
            print(f"    [{c}] -> {s}")
        continue
    vals=[str(v) for v in df[cc].tolist() if v is not None and str(v).strip() and str(v).lower()!="nan"]
    multi=sum(1 for v in vals if "\n" in v.strip())
    norm=[" ".join(v.split()) for v in vals]
    h=sorted(set(hashlib.md5(x.encode("utf-8","replace")).hexdigest()[:12] for x in norm))
    out[did]={"id":did,"cmd_col":cc,"nl_col":nc,"n_nonempty":len(vals),"n_multiline_sampled":multi,
              "n_singleline_sampled":len(vals)-multi,"pct_multiline":round(100*multi/max(1,len(vals)),1),
              "hashes":h,"n_unique_cmds":len(h),"samples":[v[:150] for v in vals[:2]]}
    print(f"    FIXED: n={len(vals)} multi%={out[did]['pct_multiline']} uniq={len(h)}")
    print(f"    e.g. {vals[0][:130]!r}")
json.dump(out,open("res_fix.json","w"))
