#!/usr/bin/env python3
"""Auditable textual classification of observed Ansible failures, not inferred root cause."""
from collections import Counter,defaultdict
import hashlib
import json
import re
from analyze import HERE,ROOT

PATTERNS=[('unsupported_module_parameter',r'Unsupported parameters for'),
          ('invalid_argument_value',r'value of .+ must be one of:'),
          ('missing_filter',r'No filter named'),
          ('undefined_variable_or_attribute',r'is undefined|has no attribute'),
          ('module_resolution',r"couldn't resolve module/action|Error loading plugin"),
          ('missing_controller_template_or_file',r'Could not find or access'),
          ('missing_target_file',r'Destination .+ does not exist'),
          ('untrusted_conditional',r'Conditional result|conditional.*untrusted|untrusted.*conditional'),
          ('yaml_or_playbook_structure',r'YAML parsing|conflicting action statements|not a valid attribute')]


def main():
    path=ROOT/'experiments/four-task-full-v1/execution.jsonl'; cases=[]
    for r in map(json.loads,path.read_text().splitlines()):
        if r['status']!='execution_error':continue
        e=r['executions'][-1];text=e['stdout']+'\n'+e['stderr']
        categories=[name for name,pattern in PATTERNS if re.search(pattern,text,re.I)] or ['other_execution_error']
        evidence=[l for l in text.splitlines() if '[ERROR]' in l or l.startswith('fatal:')]
        cases.append({'sample_id':r['sample_id'],'task_id':r['task_id'],'scenario':r['scenario'],
                      'categories':categories,'evidence_lines':evidence,'candidate_sha256':r['input_sha256']['candidate']})
    groups=defaultdict(set)
    for r in cases:groups[r['sample_id']].update(r['categories'])
    out={'execution_error_cases':len(cases),'programs_with_execution_error':len(groups),
         'case_category_counts':dict(Counter(c for r in cases for c in r['categories'])),
         'program_category_counts':dict(Counter(c for cs in groups.values() for c in cs)),
         'patterns':PATTERNS,'cases':cases,'source_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
         'limitations':['Categories summarize emitted diagnostics, not proof of a unique root cause.',
                        'A program may have multiple categories; category counts need not sum to program count.',
                        'Module resolution, missing files and version-dependent diagnostics require environment review before claiming portable program defects.']}
    (HERE/'execution-error-taxonomy.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps({k:out[k] for k in ('execution_error_cases','programs_with_execution_error','program_category_counts')},indent=2))


if __name__=='__main__':main()
