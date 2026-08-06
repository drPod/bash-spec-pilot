"""Drop machine-generated bulk uploads from the shortlist.

Agent trajectory dumps and timestamped run artifacts match the keyword filter in score.py but are
not NL->Bash datasets, and there are enough of them to bury the real ones. Writes shortlist2.json.
"""
import json,re
sl=json.load(open("shortlist.json"))
SPAM=[r"^DCAgent", r"^mlfoundations-dev/", r"20\d{6}[_-]\d{6}", r"maxEps", r"-traces", r"_traces",
      r"restore-hp", r"\d+ep-", r"bugsseq", r"swesmith", r"r2egym", r"swebench"]
clean=[r for r in sl if not any(re.search(p,r["id"]) for p in SPAM)]
print("AFTER SPAM FILTER:",len(clean))
json.dump(clean,open("shortlist2.json","w"),indent=1)
for r in clean[:200]:
    print(f'{r["score"]:3d} dl={r["dl"]:<7} lk={r["likes"]:<4} {r["id"][:60]:<60} {r["desc"][:80]}')
