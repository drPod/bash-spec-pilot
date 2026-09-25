"""Read-only, deliberately bounded assertion language for a second test baseline.

This baseline is separate from unrestricted Python-test generation. The model
chooses checks and expected values; the evaluator supplies no task-specific answer.
"""
import grp
import os
from pathlib import Path
import pwd
import subprocess

KINDS={'directory','absent','mode','content','contains','not_contains','member','package','running','password_locked'}


def schema():
    fields={'directory':['path'],'absent':['path'],'mode':['path','value'],
            'content':['path','value'],'contains':['path','value'],'not_contains':['path','value'],
            'member':['user','group'],'package':['name','version'],'running':['name','value'],
            'password_locked':['user']}
    branches=[]
    for kind,keys in fields.items():
        props={'kind':{'const':kind},'scenario':{'enum':['both','baseline','adversarial']}}
        props.update({k:{'type':'boolean' if kind=='running' and k=='value' else 'string'} for k in keys})
        branches.append({'type':'object','properties':props,'required':['kind','scenario',*keys],'additionalProperties':False})
    return {'type':'object','properties':{'checks':{'type':'array','minItems':1,'maxItems':12,'items':{'anyOf':branches}}},
            'required':['checks'],'additionalProperties':False}


def validate(spec):
    if not isinstance(spec,dict) or set(spec)!={'checks'}: raise ValueError('Expected checks object')
    if not isinstance(spec['checks'],list) or not 1<=len(spec['checks'])<=20: raise ValueError('Expected 1..20 checks')
    keys={'directory':{'path'},'absent':{'path'},'mode':{'path','value'},
          'content':{'path','value'},'contains':{'path','value'},'not_contains':{'path','value'},
          'member':{'user','group'},'package':{'name','version'},'running':{'name','value'},'password_locked':{'user'}}
    for c in spec['checks']:
        if not isinstance(c,dict) or c.get('kind') not in KINDS: raise ValueError('Unknown check kind')
        if set(c)-{'kind','scenario'} != keys[c['kind']]: raise ValueError('Incorrect check fields')
        if c.get('scenario','both') not in ['both','baseline','adversarial']: raise ValueError('Unknown scenario')
        for k,v in c.items():
            if k=='value' and c['kind']=='running':
                if type(v) is not bool: raise ValueError('running.value must be boolean')
            elif not isinstance(v,str): raise ValueError('Expected strings')
        if 'path' in c and not c['path'].startswith('/'): raise ValueError('Expected absolute path')
        if c['kind']=='mode': int(c['value'],8)
    for scenario in ['baseline','adversarial']:
        if not any(c.get('scenario','both') in ['both',scenario] for c in spec['checks']):
            raise ValueError('Vacuous scenario')
    return spec


def evaluate(spec,scenario):
    validate(spec); outcomes=[]
    for c in spec['checks']:
        if c.get('scenario','both') not in ['both',scenario]: continue
        try:
            kind=c['kind']; p=Path(c.get('path','/'))
            if kind=='directory': ok=p.is_dir()
            elif kind=='absent': ok=not os.path.lexists(p)
            elif kind=='mode': ok=(p.stat().st_mode & 0o7777)==int(c['value'],8)
            elif kind=='content': ok=p.read_text()==c['value']
            elif kind=='contains': ok=c['value'] in p.read_text()
            elif kind=='not_contains': ok=c['value'] not in p.read_text()
            elif kind=='member':
                g=grp.getgrnam(c['group']); u=pwd.getpwnam(c['user']); ok=c['user'] in g.gr_mem or u.pw_gid==g.gr_gid
            elif kind=='package':
                r=subprocess.run(['dpkg-query','-W','-f=${db:Status-Status} ${Version}',c['name']],capture_output=True,text=True,timeout=5)
                ok=r.returncode==0 and r.stdout=='installed '+c['version']
            elif kind=='running':
                r=subprocess.run(['pgrep','-x',c['name']],capture_output=True,timeout=5)
                ok=(r.returncode==0)==c['value']
            elif kind=='password_locked':
                pwd.getpwnam(c['user'])
                h=next(x.split(':')[1] for x in Path('/etc/shadow').read_text().splitlines() if x.startswith(c['user']+':'))
                ok=h.startswith(('!','*'))
            outcomes.append({'check':c,'passed':ok})
        except Exception as e: outcomes.append({'check':c,'passed':False,'error':repr(e)})
    return {'passed':bool(outcomes) and all(c['passed'] for c in outcomes),'outcomes':outcomes}
