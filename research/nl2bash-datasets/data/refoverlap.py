"""Print every dataset's overlap against the five canonical NL->Bash corpora.

Each cell is containment: the share of the dataset's own unique commands that appear in that
reference. Rows are sorted by worst case, so remixes surface at the top and the genuinely
independent corpora fall to the bottom.
"""
from resload import load
res=load()
sets={k:set(v["hashes"]) for k,v in res.items() if v.get("hashes") and len(v["hashes"])>20}
REFS=["jiacheng-ye/nl2bash","westenfelder/NL2SH-ALFA","Romit2004/LinuxCommands","Edoigtrd/tldr-pages","TRamesh2/NL2CMD"]
print("Overlap of each dataset against the 5 canonical corpora (% of the dataset's unique commands found in ref)\n")
hdr="dataset".ljust(50)+"uniq".rjust(8)+"".join(r.split('/')[-1][:12].rjust(14) for r in REFS)
print(hdr); print("="*len(hdr))
rows=[]
for k in sorted(sets):
    A=sets[k]
    cells=[]
    mx=0
    for r in REFS:
        if r not in sets or r==k: cells.append("  -"); continue
        p=100*len(A&sets[r])/len(A); mx=max(mx,p)
        cells.append(f"{p:.0f}%")
    rows.append((mx,k,len(A),cells))
rows.sort(reverse=True)
for mx,k,n,cells in rows:
    print(k.ljust(50)+str(n).rjust(8)+"".join(c.rjust(14) for c in cells))
