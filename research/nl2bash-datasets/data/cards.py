import urllib.request,re,sys
IDS="""nvidia/Nemotron-Terminal-Corpus
nvidia/Nemotron-Terminal-Synthetic-Tasks
laion/stackexchange-unix-sandboxes-verified
lisayan/rlvr-bash-terminal-bench
tiararodney/posix-sdc
Eccentricity/bashbench2
Eccentricity/basharena2
EuniAI/TerminalWorld
alibabagroup/terminal-bench-pro
IntelligenceLab/Long-Horizon-Terminal-Bench
Mitchins/NL-SHELL-MULTI
AryaYT/nl2shell-training-v3
AryaYT/nl2shell-terminal-bench
jragsdale1/ShIO-bash-26.1
saurabh5/rlvr-code-data-bash
laion/bash-textbook-v2
mlech26l/shell-helper""".split()
KW=re.compile(r"(test|verif|valid|execut|reward|check|oracle|docker|sandbox|pass@|unit test|assert)",re.I)
for i in IDS:
    for br in ["main"]:
        try:
            u=f"https://huggingface.co/datasets/{i}/raw/{br}/README.md"
            req=urllib.request.Request(u,headers={"User-Agent":"research"})
            txt=urllib.request.urlopen(req,timeout=30).read().decode("utf-8","replace")
        except Exception as e:
            print(f"--- {i}: ERR {e}"); continue
        body=re.sub(r"^---.*?^---","",txt,flags=re.S|re.M)
        hits=[l.strip() for l in body.split("\n") if KW.search(l) and len(l.strip())>25][:4]
        print(f"\n=== {i} ({len(body)} chars)")
        for h in hits: print("   *",h[:190])
