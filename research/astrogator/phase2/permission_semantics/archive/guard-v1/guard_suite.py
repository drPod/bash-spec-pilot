#!/usr/bin/env python3
import copy,json,sys,tempfile
from pathlib import Path
import yaml
sys.path.insert(0,'/suite/scripts');import upstream_eval as u
H=Path('/suite/phase2/permission_semantics');u.BIN=H/'.cache/bin'
base=u.call;enabled=False
def call(argv,*args,**kwargs):
 if enabled and argv[0]==str(u.BIN/'verify.exe'):
  argv=list(argv);argv.insert(3,'--constant-modes')
 return base(argv,*args,**kwargs)
u.call=call
modules={'file':{'path':'/work/guard','state':'directory'},'copy':{'dest':'/work/guard','content':'x'},'lineinfile':{'path':'/work/guard','line':'x'},'blockinfile':{'path':'/work/guard','block':'x'},'get_url':{'url':'http://example.invalid/file','dest':'/work/guard'},'uri':{'url':'http://example.invalid/file','dest':'/work/guard'}}
rows=[]
def verify(name,args,on):
 global enabled;enabled=on
 with tempfile.NamedTemporaryFile(mode='w',suffix='.yml')as f:
  yaml.safe_dump([{'hosts':'all','tasks':[{'ansible.builtin.'+name:args}]}],f);f.flush()
  return u.verify('create directory at /work/guard',f.name)
for name,args in modules.items():
 for alias in ['partial','absent']:
  a={**args,**({'mode':'u+x'}if alias=='partial' else{})}
  on=verify(name,a,True);off=verify(name,a,False)
  if alias=='partial':assert on['status']=='ansible_lowering_error' and 'Unsupported permission mode' in on['stdout'],(name,on)
  else:assert on['status']==off['status'] and on['stdout']==off['stdout'],(name,on,off)
  rows.append({'module':name,'mode_kind':alias,'enabled':on,'disabled':off})
for name,args in [
 ('directory_X',{'state':'directory','mode':'u=rwX,g=,o='}),
 ('unknown_X',{'mode':'u=rwX,g=,o='}),
 ('recursive_X',{'state':'directory','recurse':True,'mode':'u=rwX,g=,o='}),
 ('dynamic_mode',{'state':'directory','mode':'{{ mymode }}'}),
 ('integer_mode',{'state':'directory','mode':448}),
 ('float_mode',{'state':'directory','mode':448.0}),
 ('quoted_constant',{'state':'directory','mode':'0700'}),
 ('complete_symbolic',{'state':'directory','mode':'u=rwx,g=,o='})]:
 a={'path':'/work/guard',**args};on=verify('file',a,True)
 expected=name in ['directory_X','quoted_constant','complete_symbolic']
 unsupported=on['status']=='ansible_lowering_error'and 'Unsupported permission mode' in on['stdout']
 assert unsupported!=expected,(name,on)
 rows.append({'case':name,'args':a,'within_supported_subset':expected,'enabled':on})
(H/'guard-regressions.json').write_text(json.dumps({'status':'passed','cases':rows,'case_count':len(rows),'verifier_calls':32},indent=2)+'\n');print('PASS 20 guard/control cases,32 verifier calls')
