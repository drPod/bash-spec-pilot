#!/usr/bin/env python3
"""Create a minimal, reviewable patch against pinned upstream bytes."""
import difflib,hashlib,json
from pathlib import Path
H=Path(__file__).resolve().parent
p=Path('/tmp/astrogator-upstream/lib/fql/codegen.ml');old=p.read_text();new=old
for who in ['u','g','o']:
 new=new.replace(f'if perm = "" then None else Some ("{who}=" ^ perm)',f'"{who}=" ^ perm')
new=new.replace('Option.to_list owner @ Option.to_list group @ Option.to_list other','[owner; group; other]')
new=new.replace('[owner; group; other]',"""if List.exists Option.is_some [read; write; exec; file_list]
      then [owner; group; other]
      else List.filter (fun part -> String.length part > 2) [owner; group; other]""")
# Preserve upstream semantics for special-bit-only fields; interpreting those
# as a complete permission set requires a separate language-design decision.
assert old!=new
out=H/'patched-source/lib/fql/codegen.ml';out.parent.mkdir(parents=True,exist_ok=True);out.write_text(new)
(H/'permission-classes.patch').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/lib/fql/codegen.ml',tofile='b/lib/fql/codegen.ml')))
(H/'patch-provenance.json').write_text(json.dumps({'upstream_commit':'7c62afa51986d87033af5112cdccd3b104b1c120','path':'lib/fql/codegen.ml','before_sha256':hashlib.sha256(old.encode()).hexdigest(),'after_sha256':hashlib.sha256(new.encode()).hexdigest(),'scope':'Proposed total-permission reading when an ordinary read/write/execute/list field is explicit; preserve upstream special-bit-only behavior. No general permission semantics claim.'},indent=2)+'\n')
# Include the regression executable in upstream's test target.
old_dune=Path('/tmp/astrogator-upstream/test/dune').read_text()
new_dune='''(test
 (name test_state_based)
 (modules test_state_based))

(test
 (name permission_regression)
 (modules permission_regression)
 (libraries fql modules))
'''
test=(H/'permission_regression.ml').read_text()
(H/'patched-source/test').mkdir(parents=True,exist_ok=True)
(H/'patched-source/test/dune').write_text(new_dune)
(H/'patched-source/test/permission_regression.ml').write_text(test)
with (H/'permission-classes.patch').open('a') as f:
 f.write(''.join(difflib.unified_diff(old_dune.splitlines(True),new_dune.splitlines(True),fromfile='a/test/dune',tofile='b/test/dune')))
 f.write(''.join(difflib.unified_diff([],test.splitlines(True),fromfile='/dev/null',tofile='b/test/permission_regression.ml')))
