import json, urllib.request, urllib.parse, time, sys
seen=json.load(open("hf_raw.json"))
SAT=["nl2bash","bash","shell","terminal","cli","tldr","terminal bench","linux command","unix","intercode","os agent","command generation"]
for q in SAT:
    for off in range(100, 600, 100):
        url=f"https://huggingface.co/api/datasets?search={urllib.parse.quote(q)}&limit=100&offset={off}&full=true"
        try:
            with urllib.request.urlopen(url, timeout=30) as r: data=json.load(r)
        except Exception as e:
            print("ERR",q,off,e,file=sys.stderr); break
        if not data: break
        new=0
        for d in data:
            if d["id"] not in seen:
                d["_found_via"]=[q]; seen[d["id"]]=d; new+=1
        print(f"{q}+{off}: {len(data)} res, {new} new, total {len(seen)}", file=sys.stderr)
        if len(data)<100: break
        time.sleep(0.15)
json.dump(seen, open("hf_raw.json","w"))
print("TOTAL UNIQUE:", len(seen))
