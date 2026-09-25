#!/usr/bin/env python3
"""Compare compiled OCaml normalizer against installed Ansible's real interpreter.
Runs only inside the lab container; exercises no host chmod operations.
"""
import hashlib,inspect,itertools,json,os,stat,subprocess,time
from pathlib import Path
from ansible.module_utils.basic import AnsibleModule
import ansible.release
H=Path('/suite/phase2/permission_semantics')
def symbolic(n):
 def part(who,shift,special):
  x=(n>>shift)&7
  perms=('r' if x&4 else '')+('w' if x&2 else '')+('x' if x&1 else '')
  if n&special:perms+='t' if who=='o' else 's'
  return who+'='+perms
 return ','.join([part('u',6,0o4000),part('g',3,0o2000),part('o',0,0o1000)])
def runtime(s,initial,directory):
 info=os.stat_result(((stat.S_IFDIR if directory else stat.S_IFREG)|initial,0,0,1,0,0,0,0,0,0))
 return AnsibleModule._symbolic_mode_to_octal(info,s)
def main():
 assert Path('/.dockerenv').exists()
 start=time.monotonic(); cases=[]
 for n in range(0o10000):
  cases.append(('unknown',f'{n:04o}',f'{n:04o}'))
  for order in itertools.permutations(symbolic(n).split(',')):
   cases.append(('unknown',','.join(order),f'{n:04o}'))
  cases.append(('directory',symbolic(n).replace('x','X'),f'{n:04o}'))
  cases.append(('integer',str(n),f'{n:04o}'))
 negative=[('unknown','u=rwx'),('unknown','a=rwx'),('unknown','u=rwX,g=,o='),('unknown','u=g,g=,o='),('directory','u=g,g=,o='),('directory','u+rwx,g=,o='),('unknown','u=rw,u=,o='),('unknown','u=rwx,g=,o=tg'),('unknown','=rwx'),('unknown','07000'),('unknown','0899'),('unknown','700.0'),('unknown','{{ mode }}'),('integer','-1'),('integer','4096')]
 cases.extend((kind,s,'DECLINED')for kind,s in negative)
 payload=''.join(f'{kind}\t{s}\n'for kind,s,_ in cases)
 p=subprocess.run([str(H/'.cache/bin/mode_probe.exe')],input=payload,text=True,capture_output=True,check=True)
 actual=p.stdout.splitlines();assert len(actual)==len(cases)
 for (kind,s,want),got in zip(cases,actual):assert got==want,(kind,s,want,got)
 comparisons=0
 # All 4096 target bit patterns, all six clause orders, both object types,
 # eight initial modes spanning absent/present rwx and special permissions.
 initials=[0,0o777,0o4000,0o2000,0o1000,0o7000,0o7777,0o1754]
 for n in range(0o10000):
  for order in itertools.permutations(symbolic(n).split(',')):
   s=','.join(order)
   for d in [False,True]:
    for initial in initials:
     got=runtime(s,initial,d);assert got==n,(s,initial,d,n,got);comparisons+=1
  sx=symbolic(n).replace('x','X')
  for initial in initials:
   got=runtime(sx,initial,True);assert got==n,(sx,initial,n,got);comparisons+=1
 # Exhaust every initial mode for a fixed 16-target boundary panel.
 targets=[0,1,0o700,0o070,0o007,0o755,0o644,0o777,0o1000,0o2000,0o4000,0o7000,0o1700,0o2770,0o4755,0o7777]
 for initial in range(0o10000):
  for n in targets:
   for d in [False,True]:
    got=runtime(symbolic(n),initial,d);assert got==n,(n,initial,d,got);comparisons+=1
 # Concrete witnesses why the excluded X/partial forms cannot be constant.
 witnesses=[]
 for s in ['u=rwx','u=rwX,g=,o=','u=g,g=,o=']:
  observations={f'{m:04o}':f'{runtime(s,m,False):04o}'for m in [0,0o600,0o010,0o777]}
  assert len(set(observations.values()))>1
  witnesses.append({'symbolic':s,'regular_file_observations':observations})
 source='\n'.join(inspect.getsource(getattr(AnsibleModule,n))for n in ['_symbolic_mode_to_octal','_apply_operation_to_mode','_get_octal_mode_from_symbolic_perms'])
 (H/'ansible-symbolic-source.txt').write_text(source)
 out={'ansible_version':ansible.release.__version__,'normalizer_cases':len(cases),'accepted_cases':len(cases)-len(negative),'declined_boundary_cases':len(negative),'normalizer_input_sha256':hashlib.sha256(payload.encode()).hexdigest(),'normalizer_output_sha256':hashlib.sha256(p.stdout.encode()).hexdigest(),'ansible_semantic_comparisons':comparisons,'full_cartesian_product_tested':False,'coverage':'Every4096 target mode ×6 clauseorders ×2 objecttypes ×8 initialstates; directoryX every4096target×8initials; every4096initial×16boundarytargets×2types. Not all4096×4096 pairs.','state_dependence_witnesses':witnesses,'ansible_source_sha256':hashlib.sha256(source.encode()).hexdigest(),'seconds':round(time.monotonic()-start,3),'status':'passed'}
 (H/'semantic-checks.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out),flush=True)
if __name__=='__main__':main()
