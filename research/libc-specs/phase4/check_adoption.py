#!/usr/bin/env python3
"""Check reuse evidence only: VF buffer safety, controls and upstream buffered I/O."""
import argparse, fcntl, hashlib, json, os, re, subprocess, time
from pathlib import Path
ROOT = Path(__file__).resolve().parent

def tokens(s):
    s = re.sub(r'/\*.*?\*/|//[^\n]*', '', s, flags=re.S)
    return re.findall(r'[A-Za-z_]\w*|\d+|==|<=|>=|!=|&&|\|\||[^\s]', s)

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--toolchain', type=Path, default=Path.home()/'.cache/bash-spec-pilot/toolchains/verifast-26.01')
    ap.add_argument('--out', type=Path, default=Path.home()/'.cache/bash-spec-pilot/phase4-adoption')
    args = ap.parse_args()
    tool = args.toolchain.expanduser().resolve(); out = args.out.expanduser().resolve()
    if ROOT.parents[2] in out.parents: ap.error('logs must be outside repository')
    out.mkdir(parents=True, exist_ok=True)
    lockpath = Path.home()/'.cache/bash-spec-pilot/phase3-compiler.lock'
    lockpath.parent.mkdir(parents=True, exist_ok=True)
    lock = lockpath.open('a')
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    exe = tool/'bin/verifast'; header = ROOT/'verifast/include/unistd.h'
    original = ROOT.parent/'phase2/relay.c'; annotated = ROOT/'verifast/relay_annotated.c'
    assert hashlib.sha256(original.read_bytes()).hexdigest() == 'c5abc06f53474d90ff7927aa485a03316e267fe758593a411f70a6d22f1afe68'
    assert hashlib.sha256(exe.read_bytes()).hexdigest() == '67c8afa463c3f3b14bbe1a4ff3fbc3fbc2164f59a2ce3ba158606976c329c150', 'unexpected verifier binary'
    source = annotated.read_text(); assert tokens(source) == tokens(original.read_text())
    cases = {
        'relay': (source, True, 'memory/initialized-slice and return-range partial correctness'),
        'read_33': (source.replace('read(0, buf, 32)', 'read(0, buf, 33)'), False, 'request exceeds declared allocated capacity'),
        'residual_n': (source.replace('write(1, buf + off, (size_t)n - off)', 'write(1, buf + off, (size_t)n)'), False, 'retry requests more initialized memory than remains'),
        'zero_retry': (source.replace('if (w <= 0)', 'if (w < 0)'), True, 'partial correctness does not establish progress after zero writes; ghost cleanup follows changed guard'),
        'wrong_pointer': (source.replace('write(1, buf + off, (size_t)n - off)', 'write(1, buf, (size_t)n - off)').replace('chars_split((char *)buf, off)', 'chars_split((char *)buf, n - off)'), True, 'base-pointer retry remains memory safe; annotation partitions actual requested base range; byte-order contract absent'),
    }
    start = time.monotonic(); records = []
    def run(name, file, include, expected, scope):
        log=out/(name+'.log'); timing=out/(name+'.time')
        cmd=['/usr/bin/time','-f','MEASURE %e %M','-o',str(timing),'timeout','--kill-after=2s','60s','prlimit','--as=1610612736:1610612736','--cpu=60:60','--core=0:0','--fsize=16777216:16777216','--',str(exe),'-c','-target','Linux64','-I',str(include),str(file)]
        with log.open('w') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,timeout=65)
        text=log.read_text(); match=re.search(r'0 errors found \((\d+) statements verified\)',text)
        success=r.returncode==0 and match is not None and int(match[1])>0
        resource_failure=r.returncode in [124,137] or r.returncode<0
        measured=re.search(r'MEASURE ([0-9.]+) (\d+)',timing.read_text())
        record={'name':name,'status':r.returncode,'verified':success,'statements':int(match[1]) if match else 0,'expected_verified':expected,'matched':success==expected and not resource_failure and (expected or 'error:' in text),'scope':scope,'seconds':float(measured[1]),'peak_rss_kib':int(measured[2]),'log_sha256':hashlib.sha256(log.read_bytes()).hexdigest(),'source_sha256':hashlib.sha256(file.read_bytes()).hexdigest()}
        records.append(record);print(name,record['matched'],r.returncode,flush=True)
    for name,(body,expected,scope) in cases.items():
        file=out/(name+'.c');file.write_text(body);run(name,file,header.parent,expected,scope)
    upstream=tool/'examples/abstract_io/buffered_io/stdio.c'
    run('upstream_buffered_io',upstream,tool/'examples/abstract_io',True,'upstream custom buffered-I/O API; no host stdio claim')
    result={'passed':all(r['matched'] for r in records),'elapsed_seconds':time.monotonic()-start,'tool':'VeriFast26.01','target':'Linux64','mode':'-c modular verification; external contracts trusted; no independent kernel certificate','tool_sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'source_identity':'C tokens unchanged after removing annotations/comments; headers explicitly replaced by contracts','sources':{str(p.relative_to(ROOT.parents[2])):hashlib.sha256(p.read_bytes()).hexdigest() for p in [original,annotated,header,Path(__file__)]},'cases':records,'scope':'Infrastructure adoption evidence. Does not prove byte-stream refinement, termination, POSIX conformance or C-to-Lean preservation.'}
    (out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    if not result['passed']:raise SystemExit(1)
if __name__=='__main__':main()
