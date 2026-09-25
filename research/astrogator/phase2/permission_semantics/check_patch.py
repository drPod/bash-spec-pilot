#!/usr/bin/env python3
from pathlib import Path
import hashlib,json,subprocess,tempfile
H=Path(__file__).resolve().parent;UP=Path('/tmp/astrogator-upstream');A=H.parent/'adequacy'
with tempfile.TemporaryDirectory(prefix='permission-patch-check-')as tmp:
 d=Path(tmp)
 for path in ['lib/fql/codegen.ml','lib/ansible/semant.ml','bin/verify.ml','test/dune','test/test_state_based.ml']:
  p=d/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes((UP/path).read_bytes())
 subprocess.run(['git','init','-q',str(d)],check=True)
 for patch in [A/'permission-classes.patch',H/'permission-normalization.patch']:
  subprocess.run(['git','apply','--check',str(patch)],cwd=d,check=True)
  subprocess.run(['git','apply',str(patch)],cwd=d,check=True)
 for p in (H/'source').rglob('*'):
  if p.is_file():assert p.read_bytes()==(d/p.relative_to(H/'source')).read_bytes()
(H/'patch-application.json').write_text(json.dumps({'status':'passed','base_commit':'7c62afa51986d87033af5112cdccd3b104b1c120','patch_order':['../adequacy/permission-classes.patch','permission-normalization.patch'],'result_equals_delivered_source':True,'patch_sha256':hashlib.sha256((H/'permission-normalization.patch').read_bytes()).hexdigest()},indent=2)+'\n')
print('PASS clean sequential patch application and source equality')
