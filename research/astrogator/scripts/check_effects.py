#!/usr/bin/env python3
"""Behaviorally meaningful controls for the semantic diagnostic representation."""
import json
from evaluate_effects import probe,differences

CASES=[
 ('implicit_remote',True,'copy file from "/source" to "/target"','copy file from remote "/source" to remote "/target"'),
 ('literal_quoting',True,'create directory at /work','create directory at "/work"'),
 ('straightline_sentence',True,'create directory at /one; create directory at /two','create directory at /one. create directory at /two'),
 ('unknown_alpha_rename',True,'copy file from /source to ?backup','copy file from /source to ?destination'),
 ('group_set_order',True,'create user with name=app in supplemental groups=deploy audit','create user with name=app in supplemental groups=audit deploy'),
 ('drop_reboot_guard',False,'if os is Debian and reboot required then reboot','if os is Debian then reboot'),
 ('controller_remote',False,'copy file from controller /source to remote /target','copy file from remote /source to remote /target'),
 ('condition_scope',False,'if os is Debian then create directory at /one; create directory at /two','if os is Debian then create directory at /one. create directory at /two'),
 ('move_copy',False,'move file from /source to /target','copy file from /source to /target'),
 ('changed_content',False,'create file at /target with content="old"','create file at /target with content="new"'),
 ('unknown_aliasing',False,'copy file from /source to ?first; copy file from /source to ?first','copy file from /source to ?first; copy file from /source to ?second'),
]
results=[]
for name,expected,a,b in CASES:
    left=probe(a); right=probe(b)
    assert left['status']=='ok' and right['status']=='ok',(name,left,right)
    delta=differences(left['effects'],right['effects']); equal=not delta
    results.append({'name':name,'expected_equal':expected,'actual_equal':equal,'passed':expected==equal,'differences':delta})
empty=probe(''); assert empty['status']=='empty_query',empty
assert all(r['passed'] for r in results),results
print(json.dumps({'controls':results,'empty_query_rejected':True,'passed':True},indent=2))
