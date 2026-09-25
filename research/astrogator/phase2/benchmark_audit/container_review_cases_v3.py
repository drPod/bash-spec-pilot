import sys,pathlib,json,hashlib,subprocess
sys.path.insert(0,'/suite/scripts');import container_case as c
assert pathlib.Path('/.dockerenv').exists()
p=pathlib.Path('/suite/phase2/benchmark_audit');cid=sys.argv[1];spec=next(x for x in json.loads((p/'review-case-design-v3.json').read_text()) if x['id']==cid);task=spec['task'];fixture=spec['fixture']
original=pathlib.Path('/suite/benchmarks/expanded')/task
E=dict(vars(c),adversarial=True)
pathlib.Path('/work').mkdir(exist_ok=True);pathlib.Path('/fixtures').mkdir(exist_ok=True)
exec((original/'setup.py').read_text(),E)
if fixture=='untracked':c.put('/work/checkout/untracked','preserve')
if fixture=='extra_tracked':
 c.put('/work/checkout/other','tracked');c.run('git','-C','/work/checkout','add','other');c.run('git','-C','/work/checkout','-c','user.name=Audit','-c','user.email=audit@example.invalid','commit','-m','extra fixture')
if fixture=='empty_dirs':pathlib.Path('/work/source/empty/deep').mkdir(parents=True)
if fixture=='overlap':c.put('/work/dest/nested/data','stale destination')
if fixture=='executable':c.put('/work/tree/run','#!/bin/sh\nexit 0\n');c.os.chmod('/work/tree/run',0o700)
envs={};checks={};hashes={}
for version,base in [('v2',p/'v2/patched-suite'),('v3',p/'patched-suite')]:
 env=dict(E);setup=(base/'benchmarks/expanded'/task/'setup.py').read_text();assert setup.startswith((original/'setup.py').read_text());exec(setup[len((original/'setup.py').read_text()):],env);envs[version]=env;checks[version]=(base/'benchmarks/expanded'/task/'check.py').read_text();hashes[version]=hashlib.sha256(checks[version].encode()).hexdigest()
play=p/'review-cases-v3'/f'{cid}.yml';out={**spec,'check_sha256':hashes,'playbook_sha256':hashlib.sha256(play.read_bytes()).hexdigest(),'iterations':[]}
for iteration in range(2 if spec['expected_valid_under_declared_fixture_contract'] else 1):
 r=subprocess.run(['ansible-playbook','-i','localhost,','-c','local','-e','ansible_python_interpreter=/usr/bin/python3',str(play)],capture_output=True,text=True,timeout=60)
 row={'iteration':iteration+1,'returncode':r.returncode,'stdout':r.stdout,'stderr':r.stderr}
 if r.returncode:out['iterations'].append(row);break
 for version in ['v2','v3']:
  try:exec(checks[version],envs[version]);row[version]='passed'
  except Exception as e:row[version]='oracle_rejected';row[version+'_error']=repr(e)
 out['iterations'].append(row)
print(json.dumps(out))
