#!/usr/bin/env python3
"""Package exact file bytes with an embedded hash manifest, then verify the zip."""
import argparse
import hashlib
import json
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    p = argparse.ArgumentParser(); p.add_argument('--out', type=Path, required=True); a = p.parse_args()
    if a.out.exists(): raise RuntimeError('Refusing to replace an existing review snapshot')
    if ROOT in a.out.resolve().parents: raise RuntimeError('Write the snapshot outside the artifact tree')
    hashes = {}
    excluded = {'.venv', '.cache', '__pycache__', '.git'}
    with zipfile.ZipFile(a.out, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for path in sorted(ROOT.rglob('*')):
            rel = path.relative_to(ROOT)
            if not path.is_file() or path.is_symlink() or excluded.intersection(rel.parts): continue
            if rel.parts[:2] == ('data', 'corpus') or str(rel) == 'ARTIFACT-SHA256.json': continue
            data = path.read_bytes()
            # Catch concurrent/incomplete writes instead of distributing corrupt records.
            if path.suffix == '.json': json.loads(data)
            elif path.suffix == '.jsonl':
                if data and not data.endswith(b'\n'): raise RuntimeError('Partial JSONL file: ' + str(rel))
                for line in data.splitlines(): json.loads(line)
            hashes[str(rel)] = hashlib.sha256(data).hexdigest()
            z.writestr('astrogator/' + str(rel), data)
        manifest = json.dumps(hashes, indent=2, sort_keys=True).encode() + b'\n'
        z.writestr('astrogator/ARTIFACT-SHA256.json', manifest)
    with zipfile.ZipFile(a.out) as z:
        for path, expected in hashes.items():
            if hashlib.sha256(z.read('astrogator/' + path)).hexdigest() != expected:
                raise RuntimeError('Archive verification failed: ' + path)
    # This manifest describes the snapshot, even if ongoing work later changes local files.
    (ROOT / 'ARTIFACT-SHA256.json').write_bytes(manifest)
    print(json.dumps({'path': str(a.out), 'files': len(hashes) + 1,
                      'bytes': a.out.stat().st_size, 'sha256': hashlib.sha256(a.out.read_bytes()).hexdigest()}))


if __name__ == '__main__': main()
