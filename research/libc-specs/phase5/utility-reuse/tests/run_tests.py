#!/usr/bin/env python3
"""Differential tests: frozen C sources (compiled with host gcc) vs a Python
transliteration of the Coq model (IOWorld.v: read_n, write_n, SafeRead,
SafeWrite, FullWrite, CatLoop/CatOutcome).

Complements the VST theorem; does not replace it. Only fd 0 -> fd 1 can be
exercised because `input_desc` is a file-scope static in the fragment (default
0). Writes JSONL results outside the repo unless --out is given.
"""
import argparse
import json
import random
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TU = HERE.parent / 'src/tu'
EINTR, EINVAL, ENOSPC = 4, 22, 28
SYS_BUFSIZE_MAX = 2146435072


def build(outdir):
    gcc_inc = subprocess.check_output(['gcc', '-print-file-name=include'], text=True).strip()
    exe = outdir / 'harness'
    cmd = ['gcc', '-std=c11', '-O0', '-o', str(exe)]
    frozen = ['safe_read.c', 'safe_write.c', 'full_write.c', 'cat_fragment.c']
    objs = []
    for f in frozen:
        o = outdir / (f[:-2] + '.o')
        subprocess.check_call(['gcc', '-std=c11', '-O0', '-c', '-nostdinc',
                               '-I', str(HERE / 'include'), '-I', str(TU / 'include'),
                               '-I', str(TU), '-I', gcc_inc, '-o', str(o), str(TU / f)])
        objs.append(str(o))
    subprocess.check_call(cmd + [str(HERE / 'harness.c')] + objs)
    return exe


# ---- Python transliteration of IOWorld.v ----
class World:
    def __init__(self, unread, reads, writes):
        self.unread = bytes(unread); self.delivered = b''
        self.reads = list(reads); self.writes = list(writes); self.diag = []


def action(fallback, xs):
    return xs[0] if xs else fallback


def read_n(n, s):
    q = action(n, s.reads)
    s.reads = s.reads[1:]
    if q < 0:
        return -1, -q, b''
    k = min(max(1, q), min(n, len(s.unread)))
    bs, s.unread = s.unread[:k], s.unread[k:]
    return k, 0, bs


def write_n(bs, s):
    q = action(len(bs), s.writes)
    s.writes = s.writes[1:]
    if q < 0:
        return -1, -q
    k = min(q, len(bs))
    s.delivered += bs[:k]
    return k, 0


def safe_read(n, s, errno):
    assert n <= SYS_BUFSIZE_MAX
    while True:
        r, e, bs = read_n(n, s)
        if r >= 0:
            return r, errno, bs          # errno unchanged by the wrapper on success
        if e == EINTR:
            errno = e; continue
        return -1, e, b''


def safe_write(bs, s, errno):
    while True:
        r, e = write_n(bs, s)
        if r >= 0:
            return r, errno
        if e == EINTR:
            errno = e; continue
        return -1, e


def full_write(bs, s, errno):
    total = 0
    while bs:
        r, errno = safe_write(bs, s, errno)
        if r == -1:
            break
        if r == 0:
            errno = ENOSPC; break
        total += r; bs = bs[r:]
    return total, errno


def cat(n, s, errno):
    while True:
        r, errno, bs = safe_read(n, s, errno)
        if r == -1:
            s.diag.append(errno)
            return False, errno, None
        if r == 0:
            return True, errno, None
        total, errno = full_write(bs, s, errno)
        if total != len(bs):
            return None, errno, 'write_error'


def run_case(exe, bufsize, reads, writes, data):
    inp = f"{bufsize}\n{' '.join(map(str, reads))}\n{' '.join(map(str, writes))}\n{data.hex()}\n"
    out = subprocess.run([str(exe)], input=inp, capture_output=True, text=True, check=True).stdout
    c = json.loads(out)
    s = World(data, reads, writes)
    res, errno, we = cat(bufsize, s, 12345)
    ok = (c['delivered'] == s.delivered.hex() and c['unread'] == s.unread.hex()
          and c['diag'] == s.diag and c['read_fds_ok'] == 1 and c['write_fds_ok'] == 1)
    if we == 'write_error':
        ok &= c['write_error'] == 1 and c['result'] == -1
    else:
        ok &= c['write_error'] == 0 and c['result'] == (1 if res else 0)
        if res is False:
            ok &= c['errno'] == errno
            # theorem cat_false_reports: delivered ++ unread accounts for the input, errno reported
            ok &= s.delivered + s.unread == bytes(data) and s.diag == [errno] and errno != EINTR
        if res is True:
            # theorem cat_true_copies_all: everything delivered, nothing unread, no diagnostics
            ok &= s.delivered == bytes(data) and s.unread == b'' and s.diag == []
    return ok, c, {'result': res, 'errno': errno, 'write_error': we,
                   'delivered': s.delivered.hex(), 'unread': s.unread.hex(), 'diag': s.diag}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cases', type=int, default=2000)
    ap.add_argument('--seed', type=int, default=20260907)
    ap.add_argument('--out', type=Path, default=Path.home() / 'agent-jobs/astra-research/phase5/utility-reuse-tests')
    a = ap.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)
    exe = build(a.out)
    rng = random.Random(a.seed)
    directed = [
        (4, [], [], b'hello world'),                 # plain copy, short reads at 4
        (8, [-EINTR, -EINTR, 3, -EINTR], [2, -EINTR, 1], b'abcdefgh'),  # EINTR retries both sides, short writes
        (8, [-5], [], b'abc'),                         # read error EIO=5 -> false, diagnostic 5
        (8, [-EINVAL], [], b'abc'),                    # EINVAL with count <= SYS_BUFSIZE_MAX: fail (no shrink)
        (8, [3, -EINTR, -13], [], b'abcdef'),          # data, EINTR, then EACCES=13
        (8, [], [0], b'abc'),                          # zero write -> ENOSPC -> write_error
        (8, [], [1, -28], b'abc'),                     # short write then ENOSPC error -> write_error
        (8, [], [1, 1, 1], b'abc'),                    # three short writes complete
        (1, [], [], b'xyz'),                           # bufsize 1
        (8, [0], [], b''),                             # EOF immediately (empty input; quota 0 acts as 1 but no data)
        (8, [], [], b''),                              # empty input
        (16, [5, 5, 5], [3, 3, 3, 3, 3, 3], bytes(range(256))[:40]),
    ]
    results = []
    failures = 0
    for i, (bufsize, r, w, d) in enumerate(directed):
        ok, c, m = run_case(exe, bufsize, r, w, d)
        results.append({'kind': 'directed', 'i': i, 'ok': ok, 'bufsize': bufsize, 'reads': r, 'writes': w,
                        'data': d.hex(), 'c': c, 'model': m})
        failures += not ok
    for i in range(a.cases):
        bufsize = rng.choice([1, 2, 3, 4, 7, 8, 16, 64])
        n = rng.randrange(0, 40)
        data = bytes(rng.randrange(256) for _ in range(n))
        def sched(k, allow_zero):
            out = []
            for _ in range(k):
                x = rng.random()
                if x < 0.25: out.append(-EINTR)
                elif x < 0.35: out.append(-rng.choice([1, 5, 9, 13, 22, 28, 32]))
                elif allow_zero and x < 0.42: out.append(0)
                else: out.append(rng.randrange(1, 10))
            return out
        r, w = sched(rng.randrange(0, 8), False), sched(rng.randrange(0, 8), True)
        ok, c, m = run_case(exe, bufsize, r, w, data)
        results.append({'kind': 'random', 'i': i, 'ok': ok, 'bufsize': bufsize, 'reads': r, 'writes': w,
                        'data': data.hex(), 'c': c, 'model': m})
        failures += not ok
    (a.out / 'results.jsonl').write_text('\n'.join(json.dumps(x) for x in results) + '\n')
    kinds = {}
    for x in results:
        k = ('write_error' if x['model']['write_error'] else
             'true' if x['model']['result'] else 'false')
        kinds[k] = kinds.get(k, 0) + 1
    summary = {'total': len(results), 'failures': failures, 'outcomes': kinds,
               'seed': a.seed, 'results': str(a.out / 'results.jsonl')}
    print(json.dumps(summary))
    sys.exit(1 if failures else 0)


if __name__ == '__main__':
    main()
