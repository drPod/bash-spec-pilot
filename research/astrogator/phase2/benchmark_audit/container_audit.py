"""Independent oracle audit, executable only inside disposable lab image."""
import sys,json,hashlib,time
from pathlib import Path
sys.path.insert(0,'/suite/scripts')
import container_case as c
assert Path('/.dockerenv').exists() and Path('/opt/astrogator-lab-marker').exists()
task,scenario,variant=sys.argv[1:]
d=Path('/suite/benchmarks/expanded')/task
E=dict(vars(c),adversarial=True)
Path('/work').mkdir(exist_ok=True);Path('/fixtures').mkdir(exist_ok=True)
exec((d/'setup.py').read_text(),E)
# New states chosen after freezing phase-one programs: do not tune reference programs.
if scenario=='heldout':
 if task=='a24': c.put('/work/spool/deep/.extra','binary\x00keep')
 if task=='a32': c.put('/work/tree/new/deep/payload','new');c.os.chmod('/work/tree',0o700);c.os.chmod('/work/tree/new/deep/payload',0o400)
 if task=='a34': Path('/work/source').write_bytes(b'\xff\x00independent\n')
 if task=='a53': c.put('/work/checkout/untracked','preserve me')
 if task=='a58':
  c.subprocess.run(['crontab','-'],input=c.output('crontab','-l')+'5 3 * * 1 /bin/echo independent\n',text=True,check=True)
 if task=='a64': c.run('groupadd','-g','1707','keepers');c.os.chown('/work/data/keep',0,1707);c.put('/work/data/sub/extra','extra')
 if task=='a68':
  Path('/work/enabled').unlink() # exercise absent branch, unlike original adversarial
 if task=='a70': Path('/work/source/.hidden').write_bytes(b'\xff\x00new-hidden');c.put('/work/source/new/deep','other');c.put('/work/dest/extra','extra')
# Capture expectations from prestate, independent of tested implementation.
before={}
if task=='a34': before['source']=Path('/work/source').read_bytes()
if task=='a53': before['head']=c.output('git','-C','/work/checkout','rev-parse','HEAD').strip()
if task=='a64': before['children']={str(p):(p.read_bytes(),p.stat().st_uid,p.stat().st_gid) for p in Path('/work/data').rglob('*') if p.is_file()}
if task=='a70': before['source']={str(p.relative_to('/work/source')):p.read_bytes() for p in Path('/work/source').rglob('*') if p.is_file()};before['dest']={str(p):p.read_bytes() for p in Path('/work/dest').rglob('*') if p.is_file()}
if task=='a58': before['other']=[x for x in c.output('crontab','-l').splitlines() if 'echo' in x]
if task=='a68': before['enabled']=Path('/work/enabled').exists();E['adversarial']=before['enabled']
result={'task':task,'scenario':scenario,'variant':variant,'reference_sha256':hashlib.sha256((d/'reference.yml').read_bytes()).hexdigest(),'old_oracle_sha256':hashlib.sha256((d/'check.py').read_bytes()).hexdigest(),'runs':[]}
def strict():
 if task=='a24': assert Path('/work/spool').is_dir(), 'required directory type'
 if task=='a32':
  for p in [Path('/work/tree'),*Path('/work/tree').rglob('*')]: assert c.mode(p)==(0o755 if p.is_dir() else 0o644),f'permission obligation: {p}'
 if task=='a34': assert Path('/work/source').read_bytes()==before['source'],'source payload preserved'
 if task=='a53': assert c.output('git','-C','/work/checkout','rev-parse','HEAD').strip()==before['head'],'existing commit preserved'
 if task=='a58':
  lines=c.output('crontab','-l').splitlines();i=lines.index('#Ansible: astro cleanup');assert lines[i+1]=='15 2 * * * /usr/bin/true','active named job required'
  for line in before['other']: assert line in lines,'unrelated job preserved'
 if task=='a64':
  for p,(data,uid,gid) in before['children'].items():
   assert Path(p).read_bytes()==data and Path(p).stat().st_uid==uid and Path(p).stat().st_gid==gid,'child bytes and both ownership fields preserved'
 if task=='a68': assert Path('/work/cache').is_dir() if before['enabled'] else not c.os.path.lexists('/work/cache'),'cache must be absent, not merely non-directory'
 if task=='a70':
  for rel,data in before['source'].items(): assert Path('/work/source',rel).read_bytes()==data and Path('/work/dest',rel).read_bytes()==data,'all source bytes preserved and copied'
  for p,data in before['dest'].items(): assert Path(p).read_bytes()==data,'unrelated destination bytes preserved'
for iteration in range(2):
 r=c.subprocess.run(['ansible-playbook','-i','localhost,','-c','local','-e','ansible_python_interpreter=/usr/bin/python3',str(d/'reference.yml')],capture_output=True,text=True,timeout=60)
 rec={'iteration':iteration+1,'execution_returncode':r.returncode,'stdout':r.stdout,'stderr':r.stderr}
 if r.returncode: result['runs'].append(rec);break
 if variant=='challenge':
  if task=='a24': c.run('rm','-rf','/work/spool');c.put('/work/spool','wrong type');c.os.chmod('/work/spool',0o1777)
  if task=='a32': c.os.chmod('/work/tree',0o700)
  if task=='a34': Path('/work/source').write_bytes(b'corrupted')
  if task=='a53':
   c.run('git','-C','/work/checkout','-c','user.name=Audit','-c','user.email=audit@example.invalid','commit','--allow-empty','-m','unwanted new commit')
  if task=='a58': c.subprocess.run(['crontab','-'],input=c.output('crontab','-l').replace('15 2 * * * /usr/bin/true','#15 2 * * * /usr/bin/true'),text=True,check=True)
  if task=='a64': c.os.chown('/work/data/keep',0,1)
  if task=='a68':
   if Path('/work/cache').exists(): c.run('rm','-rf','/work/cache')
   c.put('/work/cache','unexpected')
  if task=='a70': Path('/work/source/.hidden').unlink()
 for label,fn in [('old',lambda:exec((d/'check.py').read_text(),E)),('strengthened',strict)]:
  try: fn();rec[label]='pass'
  except Exception as ex:rec[label]='reject';rec[label+'_reason']=repr(ex)
 result['runs'].append(rec)
 # Counterexample concerns postcondition adequacy; no second execution after destructive fault.
 if variant=='challenge':break
print(json.dumps(result))
