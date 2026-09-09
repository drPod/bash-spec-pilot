#!/usr/bin/env python3
"""Freeze three new held-out Lean tasks from CalculusNested.lean (nested-state frame /
preservation theorems for the Aaron-frontend adapter's patched state mutators), distinct
from the three tasks used in the prior bounded diagnostic (evaluation/tasks/*). Each task's
target theorem is independent of the others' ablated helper (no cross-helper dependency),
so the base condition removes exactly the one designated reusable association-list lemma
(or pair) without disturbing anything else kept in the template. Run once; writes
tasks/manifest.json and tasks/<task>/{helper,base}.template.lean, and hashes everything into
the manifest so check_attempt.py can verify frozen identity before any model call.
"""
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
LIBC = HERE.parents[1]
SOURCE = LIBC / 'phase5/integration/lean/CalculusNested.lean'
TASKS = HERE / 'tasks'

LINES = SOURCE.read_text().splitlines(keepends=True)


def span(a, b):
    """1-indexed inclusive line range."""
    return ''.join(LINES[a - 1:b])


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


HEADER = span(1, 30)          # module doc comment
NAMESPACE_OPEN = span(31, 31)  # "namespace CalculusNested"
CORE1 = span(33, 108)          # Lit/Val/Path/Path.snoc/RVal/Func/Expr/Stmt/lookup/assocSet/assocRemove
CORE2 = span(150, 166)         # St, St.attrs/elems/empty, St.mk_attrs/mk_elems (@[simp])
CORE3 = span(168, 218)         # getAttrAt, setAttrAt, addElemAt, removeElemAt, hasElemAt
STRUCTURAL_CORE = CORE1 + '\n' + CORE2 + '\n' + CORE3 + '\n'

HELPERS = {
    'lookup_assocSet_same': (110, 118),
    'lookup_assocSet_other': (120, 128),
    'lookup_assocRemove_same': (130, 138),
    'lookup_assocRemove_other': (140, 148),
    'getAttrAt_empty': (290, 291),
}

TARGETS = {
    'nested_frame': dict(
        theorem='CalculusNested.setAttrAt_frame',
        target_lines=(250, 288),
        helpers=['lookup_assocSet_same', 'lookup_assocSet_other'],
        facet='nested-state frame preservation: writing an attribute at path p changes no '
              'other (path, attribute) pair (parent attrs, sibling elements, unrelated '
              'subtrees all preserved) -- the property nested_state.sc checks by execution',
    ),
    'nested_add_attrs': dict(
        theorem='CalculusNested.addElemAt_attrs',
        target_lines=(295, 336),
        helpers=['lookup_assocSet_same', 'lookup_assocSet_other', 'getAttrAt_empty'],
        facet='nested-state element creation preserves every attribute everywhere (a fresh '
              'element is empty, add_if_absent keeps an existing one with its attributes)',
    ),
    'nested_remove_frame': dict(
        theorem='CalculusNested.removeElemAt_here_frame',
        target_lines=(339, 347),
        helpers=['lookup_assocRemove_other'],
        facet='clearing an element at the state root keeps the root attributes and every '
              'sibling element (only the cleared element itself is affected)',
    ),
}

STRIP_TRAILING_BY = re.compile(r'\s*by\s*\n\Z')


def target_signature(a, b):
    text = span(a, b)
    # Keep only the statement up to and including ':=' (strip the proof and any trailing 'by').
    idx = text.index(':=')
    stmt = text[:idx + 2] + '\n'
    return stmt


def build_template(task_key, condition):
    spec = TARGETS[task_key]
    keep = spec['helpers'] if condition == 'helper' else []
    helper_text = ''
    for name in spec['helpers']:
        if name in keep:
            a, b = HELPERS[name]
            helper_text += span(a, b) + '\n'
    stmt = target_signature(*spec['target_lines'])
    body = (HEADER + NAMESPACE_OPEN + '\n' + STRUCTURAL_CORE + '\n'
            + helper_text + '\n' + stmt + '\nend CalculusNested\n')
    return body


def main():
    TASKS.mkdir(parents=True, exist_ok=True)
    manifest = dict(schema='phase5-evaluation-expanded-tasks/1', module='CalculusNested',
                    source='phase5/integration/lean/CalculusNested.lean',
                    source_sha256=sha(SOURCE.read_bytes()), tasks={})
    for key, spec in TARGETS.items():
        task_dir = TASKS / key
        task_dir.mkdir(parents=True, exist_ok=True)
        entry = dict(theorem=spec['theorem'], module='CalculusNested', facet=spec['facet'],
                     helper_lemmas=spec['helpers'], removed_in_base=spec['helpers'],
                     statement=target_signature(*spec['target_lines']), conditions={})
        for cond in ('helper', 'base'):
            text = build_template(key, cond)
            path = task_dir / f'{cond}.template.lean'
            path.write_text(text)
            entry['conditions'][cond] = dict(template=f'tasks/{key}/{cond}.template.lean',
                                              template_sha256=sha(text.encode()))
        manifest['tasks'][key] = entry
    (TASKS / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('wrote', TASKS / 'manifest.json')
    for key in TARGETS:
        print(' -', key, '->', manifest['tasks'][key]['theorem'])


if __name__ == '__main__':
    main()
