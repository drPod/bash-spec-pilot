import json, urllib.request, urllib.parse, time, sys
seen=json.load(open("hf_raw.json"))
SAT=["nl2bash","bash","shell","terminal","cli","tldr","terminal bench","linux command","unix","intercode","command line interface","sh","script"]
for q in SAT:
    url=f"https://huggingface.co/api/datasets?search={urllib.parse.quote(q)}&limit=1000&full=true"
    try:
        with urllib.request.urlopen(url, timeout=60) as r: data=json.load(r)
    except Exception as e:
        print("ERR",q,e,file=sys.stderr); continue
    new=0
    for d in data:
        if d["id"] not in seen:
            d["_found_via"]=[q]; seen[d["id"]]=d; new+=1
        else: seen[d["id"]].setdefault("_found_via",[]).append(q)
    print(f"{q}: {len(data)} res, {new} new, total {len(seen)}", file=sys.stderr)
    time.sleep(0.2)
json.dump(seen, open("hf_raw.json","w"))
print("TOTAL UNIQUE:", len(seen))
