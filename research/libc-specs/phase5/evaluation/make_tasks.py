#!/usr/bin/env python3
"""Freeze the three non-UTF8 proof-generation tasks from already-checked phase2/phase3 Lean.

Each task is a line-range extraction from a hash-pinned source file. The target theorem's
statement is kept byte-for-byte; its proof is removed. Two library conditions are frozen
per task: `helper` keeps the named reviewed helper lemmas (with their proofs) that precede
the target in the same file; `base` deletes them (statement and proof), leaving only the
imports and definitions. Imports are identical in both conditions.

Writes tasks/<task>/<condition>.template.lean and tasks/manifest.json. Run once, before any
model attempt; the manifest hashes are what check_attempt.py enforces.
"""
import hashlib
import json
from pathlib import Path
import datetime

HERE = Path(__file__).resolve().parent
LIBC = HERE.parents[1]
TASKS = HERE / 'tasks'

# (task id, source file, module, full theorem name, prefix range, helper ranges, target range,
#  closing lines, research facet, removed helper names)
SPEC = [
    dict(task='shell_status', source='phase3/ShellObservation.lean', module='ShellObservation',
         theorem='ShellObservation.query_transfer', prefix=(1, 36), helpers=[(37, 70)],
         target=(71, 79), close=['', 'end ShellObservation', ''],
         facet='shell short-circuit / status composition: accepted query transfers through '
               '`;`, `&&`, `||` with exit status and residual state',
         removed_in_base=['ShellObservation.command_refines'],
         imports_available=['BufferRelay (phase2; not needed for this target)']),
    dict(task='byte_relay', source='phase3/RelayComposition.lean', module='RelayComposition',
         theorem='RelayComposition.fragment_refines', prefix=(1, 32), helpers=[(33, 43)],
         target=(44, 46), close=['', 'end RelayComposition', ''],
         facet='byte-bearing relay instantiation of the generic status-composition lemma '
               '(pointer-memory evaluator refines the list model under the shell fragment)',
         removed_in_base=['RelayComposition.primitive_eq', 'RelayComposition.primitive_refines'],
         imports_available=['PointerRelay.run_detailed_eq : observe (run input reads writes).state '
                            '= BufferRelay.runDetailed input reads writes',
                            'ShellObservation.command_refines (unchanged, statement in prompt)']),
    dict(task='partial_error', source='phase2/BufferRelay.lean', module='BufferRelay',
         theorem='BufferRelay.run_write_failure_residual', prefix=(1, 322), helpers=[(323, 327)],
         target=(328, 332), close=['', 'end BufferRelay', ''],
         facet='partial-error behaviour: a write failure (status 2) leaves a nonempty pending '
               'suffix and delivered bytes strictly below consumed bytes',
         removed_in_base=['BufferRelay.run_conservation'],
         imports_available=['MemoryTransfer (memory-experiment; framing lemmas)']),
]


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def lines(text, rng):
    a, b = rng
    return text.splitlines()[a - 1:b]


def strip_proof_marker(stmt_lines):
    last = stmt_lines[-1]
    for marker in (':= by', ':='):
        if last.rstrip().endswith(marker):
            return stmt_lines[:-1] + [last.rstrip()[: -len(marker)].rstrip() + ' :=']
    raise SystemExit('target statement must end in `:=` or `:= by`: ' + last)


def main():
    manifest = dict(schema='phase5-evaluation-tasks/1',
                    frozen_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds'),
                    lean='leanprover/lean4:v4.31.0', tasks={})
    frozen = (TASKS / 'manifest.json').exists()  # verify-only mode: touch nothing on disk
    for s in SPEC:
        src = LIBC / s['source']
        text = src.read_text()
        prefix = lines(text, s['prefix'])
        helpers = [l for r in s['helpers'] for l in lines(text, r)]
        target = strip_proof_marker(lines(text, s['target']))
        out = TASKS / s['task']
        if not frozen:
            out.mkdir(parents=True, exist_ok=True)
        entry = dict(source=s['source'], source_sha256=sha(src.read_bytes()), module=s['module'],
                     theorem=s['theorem'], facet=s['facet'], prefix_lines=list(s['prefix']),
                     helper_lines=[list(r) for r in s['helpers']], target_lines=list(s['target']),
                     removed_in_base=s['removed_in_base'], imports_available=s['imports_available'],
                     statement='\n'.join(target), conditions={})
        for cond in ('helper', 'base'):
            body = prefix + (helpers if cond == 'helper' else []) + [''] + target
            template = '\n'.join(body) + '\n' + '\n'.join(s['close'])
            path = out / f'{cond}.template.lean'
            if not frozen:
                path.write_text(template)
            entry['conditions'][cond] = dict(template=str(path.relative_to(HERE)),
                                             template_sha256=sha(template.encode()))
        if not frozen:
            (out / 'original_proof.txt').write_text(
                'Original proof body (held out from prompts; used only as the helper-condition '
                'positive control).\nby\n' + '\n'.join(text.splitlines()[s['target'][1]:]).split('\n\n')[0] + '\n')
        manifest['tasks'][s['task']] = entry
    existing = TASKS / 'manifest.json'
    if existing.exists():
        # Frozen: never rewrite. Verify that the regenerated templates and sources still match.
        old = json.loads(existing.read_text())
        mismatches = [(k, c) for k, v in manifest['tasks'].items() for c, d in v['conditions'].items()
                      if old['tasks'][k]['conditions'][c]['template_sha256'] != d['template_sha256']
                      or old['tasks'][k]['source_sha256'] != v['source_sha256']]
        print(json.dumps(dict(frozen_utc=old['frozen_utc'], verified=not mismatches, mismatches=mismatches)))
        raise SystemExit(1 if mismatches else 0)
    existing.write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps({k: v['conditions'] for k, v in manifest['tasks'].items()}, indent=1))


if __name__ == '__main__':
    main()
