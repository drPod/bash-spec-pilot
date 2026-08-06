"""Rank the swept HuggingFace index down to a plausible shortlist.

Keyword scoring over the id, description and tags, weighted so a match in the id counts for more
than one in the prose. The NOISE list drops the words that merely contain "shell" (nutshell,
seashell, bombshell) unless the id itself also matches something strong. Writes shortlist.json.
"""
import json,re
seen=json.load(open("hf_raw.json"))
STRONG=[r"nl2bash",r"nl2cmd",r"nl2sh",r"bash",r"\bshell\b",r"\bzsh\b",r"coreutils",r"\btldr\b",
 r"command[- ]?line",r"\bcli\b",r"linux command",r"terminal[- ]bench",r"intercode",r"unix",
 r"shell[- ]?script",r"bash[- ]?script",r"\bposix\b",r"sysadmin",r"\bdevops\b",r"man ?page"]
MED=[r"\bterminal\b",r"\blinux\b",r"\bcommand\b",r"\bscript\b",r"\bos agent\b",r"\bsh\b"]
NOISE=[r"marshall",r"seashell",r"shelley",r"nutshell",r"bombshell",r"shellfish",r"eggshell"]
rows=[]
for did,d in seen.items():
    text=(did+" "+(d.get("description") or "")+" "+" ".join(d.get("tags") or [])).lower()
    if any(re.search(n,text) for n in NOISE) and not any(re.search(s,did.lower()) for s in STRONG): continue
    s=0
    for p in STRONG:
        if re.search(p,did.lower()): s+=10
        elif re.search(p,text): s+=4
    for p in MED:
        if re.search(p,did.lower()): s+=3
        elif re.search(p,text): s+=1
    if s>=6:
        rows.append((s,did,d.get("downloads",0),d.get("likes",0),(d.get("description") or "").replace("\n"," ")[:150]))
rows.sort(key=lambda r:(-r[0],-r[2]))
print("SHORTLIST:",len(rows))
json.dump([{"score":r[0],"id":r[1],"dl":r[2],"likes":r[3],"desc":r[4]} for r in rows],open("shortlist.json","w"),indent=1)
for r in rows[:120]: print(f"{r[0]:3d} dl={r[2]:<8} {r[1]:<55} {r[4][:90]}")
