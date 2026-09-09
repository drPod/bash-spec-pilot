#!/usr/bin/env python3
"""Assert child exit statuses from `run_baseline.sh`/`run_v2_units.sh`'s `exit_status.tsv`
against a typed table of expected non-zero exits, instead of the scripts' own `awk` line
(which only PRINTS non-zero rows and never fails the shell). A batch's `run_vst` receipt
`exit_status: 0` means the bash script itself did not error; it does NOT mean every child
`cb_main.exe` invocation behaved as expected (Pi review calculus-v2-recovery-1, finding 1).

`cb_main.ml`'s `lower` mode exits 4 when the lowering rejects a program (see
`grep -n 'exit 4' adapter/cb_main.ml`); `mut_bad_byte.sc` is the one case where that is the
CORRECT, expected outcome now (v2 catches its out-of-range byte literal statically instead of
at runtime, MAPPING.md "v1 vs v2"). Every other child must exit 0; any other non-zero exit is
an unexpected failure and this script reports it as such.
"""
import sys
from pathlib import Path

# name -> expected exit code, when it is anything other than 0.
EXPECTED_NONZERO = {
    'mut_bad_byte_relay': 4,
    'mut_bad_byte_relay_and_mark': 4,
}


def check(path):
    problems = []
    for line in Path(path).read_text().splitlines():
        if not line.strip():
            continue
        name, code = line.split('\t')
        code = int(code)
        expected = EXPECTED_NONZERO.get(name, 0)
        if code != expected:
            problems.append(f'{name}: exit {code}, expected {expected}')
    return problems


def main():
    if len(sys.argv) < 2:
        print('usage: check_exit_status.py EXIT_STATUS_TSV [...]', file=sys.stderr)
        return 2
    problems = []
    for p in sys.argv[1:]:
        problems += [f'{p}: {msg}' for msg in check(p)]
    for p in problems:
        print('PROBLEM', p)
    print(f'files={len(sys.argv) - 1} problems={len(problems)}', 'OK' if not problems else 'PROBLEMS')
    return 0 if not problems else 1


if __name__ == '__main__':
    sys.exit(main())
