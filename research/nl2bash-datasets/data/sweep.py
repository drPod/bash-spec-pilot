"""Discover candidate datasets by searching the HuggingFace dataset index.

One request per query term, results merged by id with the terms that found it recorded in
_found_via. Writes hf_raw.json. This first pass reached 809 unique datasets; see sweep3.py for
what got it to 5,661.
"""
import json, urllib.request, urllib.parse, time, sys

QUERIES = ["nl2bash","bash","shell","nl2cmd","nl2sh","command line","linux command","terminal",
 "bash script","shell script","unix","cli","commandline","bash command","posix","zsh","sh script",
 "coreutils","tldr","man page","sysadmin","devops script","bash code","shell code","script generation",
 "intercode","terminal bench","os agent","bashbench","linux terminal","command generation","text to bash",
 "text to command","natural language command","shellcheck","dockerfile bash","kubernetes command","awk sed grep"]

seen={}
for q in QUERIES:
    url="https://huggingface.co/api/datasets?search="+urllib.parse.quote(q)+"&limit=100&full=true"
    try:
        with urllib.request.urlopen(url, timeout=30) as r:
            data=json.load(r)
    except Exception as e:
        print("ERR",q,e, file=sys.stderr); continue
    for d in data:
        if d["id"] not in seen:
            d["_found_via"]=[q]; seen[d["id"]]=d
        else:
            seen[d["id"]]["_found_via"].append(q)
    print(f"{q}: {len(data)} results, total unique {len(seen)}", file=sys.stderr)
    time.sleep(0.15)

json.dump(seen, open("hf_raw.json","w"))
print("TOTAL UNIQUE:", len(seen))
