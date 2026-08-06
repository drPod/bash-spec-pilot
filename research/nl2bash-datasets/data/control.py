import json, hashlib
res = {}
for f in ('res1.json', 'res2.json', 'res_fix.json'):
    res.update(json.load(open(f)))  # res_fix last: AnishJoshi/nl2bash-custom is a REF corpus below
                                    # and its res1 entry used the NL column, not bash_code
REF_IDS = ['jiacheng-ye/nl2bash', 'TRamesh2/NL2CMD', 'Romit2004/LinuxCommands',
           'westenfelder/NL2SH-ALFA', 'Edoigtrd/tldr-pages', 'AnishJoshi/nl2bash-custom',
           'b-mc2/cli-commands-explained']
REF = set()
for r in REF_IDS:
    REF |= set(res[r]['hashes'])
print('REF size', len(REF), '\n')

print('POSITIVE CONTROL — known-contaminated, same union, same hash fn')
for k in ['westenfelder/InterCode-Corrections', 'epinnock/intercode-nl2bash-curated']:
    v = res.get(k, {})
    if v.get('hashes'):
        A = set(v['hashes'])
        print(f'  {k:45s} col={v["cmd_col"]:12s} {100*len(A&REF)/len(A):5.1f}%  n={len(A)}')

print('\nHELD-OUT CONTROL — corpora NOT in the union, so a fair "how much do independent')
print('command corpora overlap anyway?" baseline')
for k, v in sorted(res.items()):
    if k in REF_IDS or not v.get('hashes') or len(v['hashes']) < 300:
        continue
    A = set(v['hashes'])
    p = 100 * len(A & REF) / len(A)
    if p >= 5:
        print(f'  {k:45s} col={str(v["cmd_col"])[:12]:12s} {p:5.1f}%  n={len(A)}')
