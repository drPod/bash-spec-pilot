#!/usr/bin/env python3
"""Run a frozen, post-hoc selected mechanism probe only inside disposable Docker."""
import hashlib,json,os,shutil,subprocess,sys,time
from pathlib import Path
assert Path('/.dockerenv').exists()
R=Path('/suite');H=R/'phase2/end_to_end';f=json.loads((H/'a03-runtime-frozen.json').read_text());results=[]
root=Path('/home/mydata/web')
def observe():
 return {'root_exists':root.exists(),'root_is_directory':root.is_dir(),'root_mode':oct(root.stat().st_mode&0o7777)if root.exists()else None,'descendants':sorted(str(p.relative_to(root))for p in root.rglob('*'))if root.is_dir()else []}
for case in f['fixtures']:
 if root.exists():shutil.rmtree(root)
 root.mkdir(parents=True);root.chmod(0o751)
 for name,content in case['files'].items():p=root/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(content)
 before=observe();src=R/f['candidate']['path'];assert hashlib.sha256(src.read_bytes()).hexdigest()==f['candidate']['sha256']
 cmd=['ansible-playbook','-i','localhost,','-c','local','-e','ansible_python_interpreter=/usr/bin/python3',str(src)]
 start=time.time();p=subprocess.run(cmd,capture_output=True,text=True,timeout=60,env={**os.environ,'ANSIBLE_NOCOLOR':'1','ANSIBLE_HOST_KEY_CHECKING':'False'});after=observe()
 results.append({'fixture':case['id'],'before':before,'after':after,'command':cmd,'returncode':p.returncode,'stdout':p.stdout,'stderr':p.stderr,'seconds':time.time()-start,'checks':{'root_preserved_as_directory':after['root_is_directory'],'contents_removed':after['root_is_directory']and not after['descendants']}})
out={'frozen_sha256':hashlib.sha256((H/'a03-runtime-frozen.json').read_bytes()).hexdigest(),'ansible_version':subprocess.run(['ansible-playbook','--version'],capture_output=True,text=True).stdout,'results':results,'scope':'Post-hoc selected mechanism counterexample; not a newly labeled110-program task or an unbiased error rate.'}
(H/'a03-runtime-results.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps([{'fixture':x['fixture'],'returncode':x['returncode'],'checks':x['checks']}for x in results]))
