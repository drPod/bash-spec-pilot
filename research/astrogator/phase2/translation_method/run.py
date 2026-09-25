#!/usr/bin/env python3
"""Matched source-handbook ablation: only the system message changes."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import sys

HERE=Path(__file__).resolve().parent
BASE=HERE.parent/'integration'
spec=importlib.util.spec_from_file_location('frontier_transport', BASE/'frontier.py')
frontier=importlib.util.module_from_spec(spec)
spec.loader.exec_module(frontier)

def prepare():
    base_path=BASE/'frontier/frozen-inputs.json'
    base=json.loads(base_path.read_text())
    guide=(HERE/'handbook.md').read_text()
    tasks=[]
    for task in base['tasks']:
        if task['mode']!='fql': continue
        row=copy.deepcopy(task)
        assert row['messages'][0]['role']=='system'
        row['messages'][0]['content']=guide
        assert row['messages'][1:]==task['messages'][1:]
        row['arm']='source_handbook_v1'
        tasks.append(row)
    sources={}
    for name in ['parser.mly','lexer.mll','semant.ml','knowledge.ml']:
        p=Path('/tmp/astrogator-upstream/lib/fql')/name
        sources[str(p)]=frontier.sha(p.read_bytes())
    config={'version':1,'models':base['models'],'reasoning_effort':base['reasoning_effort'],
            'tasks':tasks,'base_frozen_input_sha256':frontier.sha(base_path.read_bytes()),
            'source_sha256':sources,
            'handbook_sha256':frontier.sha((HERE/'handbook.md').read_bytes()),
            'runner_sha256':frontier.sha(Path(__file__).read_bytes()),
            'transport_sha256':frontier.sha((BASE/'frontier.py').read_bytes()),
            'design':{'intervention':'Replace only system message with source-derived handbook; retain exact four demonstrations, target NL, models, transport, and 3 repetitions.',
                      'provenance':'Handbook authored from upstream lexer/parser/semantic analyzer/Example KB. No frontier prediction, evaluation outcome, or target reference query inspected to design handbook.',
                      'limitation':'Existing Example KB is benchmark-related domain engineering; this tests access to existing compiler knowledge, not unseen-domain generalization. Prompt lengths differ; no compute-matched claim.',
                      'analysis':'Report paired per-task and per-repeat syntax, semantic/codegen, and normalized-effect-match outcomes; effect match remains a proxy. Preserve all outputs and failures.'}}
    frontier.OUT=HERE/'runs'
    path=frontier.OUT/'frozen-inputs.json'
    if path.exists(): assert json.loads(path.read_text())==config,'Frozen inputs changed'
    else: frontier.save(path,config)
    print(json.dumps({'tasks_per_model':len(tasks),'guide_characters':len(guide),'frozen_input_sha256':frontier.sha(path.read_bytes())}))

if __name__=='__main__':
    p=argparse.ArgumentParser(); p.add_argument('command',choices=['prepare','run']);
    p.add_argument('--models',nargs='+',default=list(frontier.MODELS));
    p.add_argument('--workers',type=int,default=2)
    a=p.parse_args()
    if a.command=='prepare': prepare()
    else:
        frontier.OUT=HERE/'runs'; a.modes=['fql']; frontier.run(a)
