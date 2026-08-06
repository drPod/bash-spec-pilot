import json,urllib.request,urllib.parse,sys,time
def get(u):
    try:
        req=urllib.request.Request(u,headers={"User-Agent":"research"})
        with urllib.request.urlopen(req,timeout=40) as r: return json.load(r)
    except Exception as e: return {"_err":str(e)}
out={}
for did in [l.strip() for l in open("cands.txt") if l.strip()]:
    sz=get("https://datasets-server.huggingface.co/size?dataset="+urllib.parse.quote(did))
    rec={"id":did}
    if "size" in sz:
        rec["total_rows"]=sz["size"].get("dataset",{}).get("num_rows")
        rec["configs"]=[{"c":c["config"],"rows":c["num_rows"]} for c in sz["size"].get("configs",[])]
        rec["splits"]=[{"c":s["config"],"s":s["split"],"rows":s["num_rows"]} for s in sz["size"].get("splits",[])]
    else:
        rec["size_err"]=sz.get("_err") or json.dumps(sz)[:200]
    out[did]=rec
    print(f'{did:<58} rows={rec.get("total_rows")} {("ERR:"+str(rec.get("size_err"))[:80]) if rec.get("size_err") else ""}',flush=True)
    time.sleep(0.1)
json.dump(out,open("sizes.json","w"),indent=1)
