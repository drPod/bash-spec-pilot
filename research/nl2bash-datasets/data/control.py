"""The two controls that make the contamination numbers in contamination.md mean something.

Positive control: benchmarks known to be drawn from the reference corpora have to come back high
through the identical pipeline, which shows the union matches what it should.

Baseline control: independent command corpora already overlap the union to some degree, so the
near-zero figures for execution-environment benchmarks need that floor to be read against. Without
it, a 0.1% result is indistinguishable from a measurement bug, which is exactly the mistake the
first pass made.
"""
from resload import load
res = load()
REF_IDS = ['jiacheng-ye/nl2bash', 'TRamesh2/NL2CMD', 'Romit2004/LinuxCommands',
           'westenfelder/NL2SH-ALFA', 'Edoigtrd/tldr-pages', 'AnishJoshi/nl2bash-custom',
           'b-mc2/cli-commands-explained']
REF = set()
print('REFERENCE UNION — check every column and sample before trusting anything below.')
for r in REF_IDS:                       # a wrong column here silently invalidates every result,
    v = res[r]                          # which is the exact failure the first pass shipped
    assert v.get('hashes'), f'{r}: no hashes'
    print(f"  {r:35s} col={str(v['cmd_col']):22s} n={len(v['hashes']):6d}  "
          f"e.g. {str(v.get('samples', ['?'])[0])[:48]!r}")
    REF |= set(v['hashes'])
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
