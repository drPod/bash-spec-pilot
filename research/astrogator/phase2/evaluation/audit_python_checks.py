#!/usr/bin/env python3
"""Inventory actual generated Python source for manual side-effect review.

This is not a sandbox or a proof of read-only behavior. No generated code runs.
"""
import ast
import hashlib
import json
from analyze import HERE,ROOT

MUTATORS={'write','write_text','write_bytes','chmod','chown','unlink','remove','rmdir','mkdir','makedirs',
          'rename','replace','system','popen','Popen','exec','eval','compile','symlink','link','truncate',
          'ftruncate','setuid','setgid','chroot','utime','touch','kill','killpg','putenv','unsetenv'}


def main():
    source=ROOT/'phase2/integration/frontier-python'
    frozen=source/'frozen-inputs.json';config=json.loads(frozen.read_text())
    records=[]
    for model in config['models']:
        for task in config['tasks']:
            path=source/model/(task['id']+'.json');assert path.exists(),str(path)
            d=json.loads(path.read_text());assert d['task']==task
            row={'model':model,'task_id':task['task_id'],'repeat':task['repeat'],
                 'prediction_file':str(path.relative_to(ROOT)),'prediction_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
                 'status':d['status'],'source_sha256':hashlib.sha256(d.get('extracted','').encode()).hexdigest()}
            code=d.get('extracted','')
            if d['status']!='ok':row['review_status']='no_successful_generation';records.append(row);continue
            try:tree=ast.parse(code)
            except SyntaxError as e:row.update(review_status='syntax_error',error=str(e));records.append(row);continue
            calls=[];imports=[]
            for n in ast.walk(tree):
                if isinstance(n,(ast.Import,ast.ImportFrom)):imports.append(ast.unparse(n))
                if isinstance(n,ast.Call):
                    name=n.func.attr if isinstance(n.func,ast.Attribute) else getattr(n.func,'id','')
                    calls.append({'line':n.lineno,'callee':ast.unparse(n.func),'call':ast.unparse(n),
                                  'named_mutator':name in MUTATORS})
            row.update(review_status='source_inventory_requires_manual_review',imports=imports,calls=calls,
                       named_mutator_calls=[c for c in calls if c['named_mutator']],
                       subprocess_calls=[c for c in calls if any(s in c['callee'] for s in ('subprocess','check_output','check_call','run','Popen','system'))],
                       open_calls=[c for c in calls if c['callee']=='open' or c['callee'].endswith('.open')])
            records.append(row)
    out={'records':records,'expected_generations':len(config['tasks'])*len(config['models']),
         'frozen_sha256':hashlib.sha256(frozen.read_bytes()).hexdigest(),
         'method':'AST/source inventory only. Named-call detection can miss aliases and dynamic effects; a manual review of these exact source hashes is required.',
         'successful_sources':sum(r['status']=='ok' for r in records),
         'named_mutator_occurrences':sum(len(r.get('named_mutator_calls',[])) for r in records)}
    (HERE/'python-check-source-inventory.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps({k:v for k,v in out.items() if k!='records'},indent=2))


if __name__=='__main__':main()
