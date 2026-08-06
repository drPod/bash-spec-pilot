import json,glob,itertools
res={}
for f in ["res1.json","res2.json","res_fix.json"]:  # res_fix last: it supersedes bad column picks
    try: res.update(json.load(open(f)))
    except Exception as e: print("skip",f,e)
sets={k:set(v["hashes"]) for k,v in res.items() if v.get("hashes")}
print(f"datasets with command hashes: {len(sets)}\n")
pairs=[]
for a,b in itertools.combinations(sorted(sets),2):
    A,B=sets[a],sets[b]
    if not A or not B: continue
    inter=len(A&B)
    if inter==0: continue
    cont_a=inter/len(A); cont_b=inter/len(B)   # containment
    jac=inter/len(A|B)
    if max(cont_a,cont_b)>=0.50:
        pairs.append((max(cont_a,cont_b),jac,a,b,len(A),len(B),inter,cont_a,cont_b))
pairs.sort(reverse=True)
print(f"{'containment':>11} {'jaccard':>8}  A / B   (uniqA, uniqB, shared)")
print("="*130)
for m,j,a,b,la,lb,i,ca,cb in pairs:
    rel = "IDENTICAL" if j>0.98 else ("SUBSET" if m>0.95 else "HEAVY-OVERLAP")
    print(f"{m*100:10.1f}% {j*100:7.1f}%  [{rel}]\n     A={a} (uniq {la})\n     B={b} (uniq {lb})  shared={i}  A⊆B:{ca*100:.1f}%  B⊆A:{cb*100:.1f}%")
json.dump([{"containment":m,"jaccard":j,"a":a,"b":b,"uniq_a":la,"uniq_b":lb,"shared":i} for m,j,a,b,la,lb,i,ca,cb in pairs],open("dupe_pairs.json","w"),indent=1)
