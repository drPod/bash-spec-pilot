#!/usr/bin/env python3
"""Run one bounded command in the existing VST container; retain private logs.

Does not create containers, install packages, or certify a successful command as a
proof. Compiler outputs/caches stay in the container. Uses the earlier phases'
compiler lock and refuses to overlap an already running container job.
"""
import argparse
import fcntl
import hashlib
import json
from pathlib import Path
import subprocess
import time


def output(args):
    return subprocess.check_output(args, text=True, timeout=15)


def file_hash(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--container', default='phase5-vst')
    parser.add_argument('--seconds', type=int, default=120)
    parser.add_argument('--name', required=True)
    parser.add_argument('--workdir', default='/home/coq/phase5')
    parser.add_argument('--allow-sanitizer-shadow', action='store_true',
                        help='retain the cgroup memory cap but allow ASan virtual shadow mappings')
    parser.add_argument('--logs', type=Path,
                        default=Path.home() / 'agent-jobs/astra-research/phase5/runs')
    parser.add_argument('command', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command[1:] if args.command[:1] == ['--'] else args.command
    if not command or not 1 <= args.seconds <= 900:
        parser.error('supply a command and a wall limit between 1 and 900 seconds')
    if not args.name.replace('-', '').replace('_', '').isalnum():
        parser.error('name must contain only letters, numbers, hyphens and underscores')
    logs = args.logs.expanduser().resolve()
    repo = Path(__file__).resolve().parents[3]
    if logs == repo or repo in logs.parents:
        parser.error('runtime logs must remain outside the repository')
    logs.mkdir(parents=True, exist_ok=True)
    receipt = logs / (args.name + '.json')
    log = logs / (args.name + '.log')
    if receipt.exists() or log.exists():
        parser.error('choose a new run name; previous evidence is never overwritten')
    lockpath = Path.home() / '.cache/bash-spec-pilot/phase3-compiler.lock'
    lockpath.parent.mkdir(parents=True, exist_ok=True)
    with lockpath.open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        info = json.loads(output(['docker', 'inspect', args.container]))[0]
        config = info['HostConfig']
        if not (info['State']['Running'] and
                0 < config['Memory'] <= 3221225472 and
                config['Memory'] <= config['MemorySwap'] <= 3758096384 and
                0 < config['NanoCpus'] <= 1000000000):
            parser.error('container must be live and bounded to one CPU, 3 GiB + 512 MiB swap')
        # Docker needs a PID column to map host processes into the container.
        processes = [p.split(None, 1)[1].strip() for p in
                     output(['docker', 'top', args.container, '-eo', 'pid,comm']).splitlines()[1:]]
        if processes != ['sleep']:
            parser.error('container has an existing job; inspect it before starting another')
        measure = '/tmp/phase5-command.time'
        docker_command = [
            'docker', 'exec', '-e', 'OPAMJOBS=1', '-e', 'MAKEFLAGS=-j1',
            '-w', args.workdir, args.container, 'opam', 'exec', '--',
            '/usr/bin/time', '-f', '%e %M %x', '-o', measure,
            'timeout', '--signal=INT', '--kill-after=10s', str(args.seconds) + 's',
            'prlimit', '--core=0:0', '--fsize=67108864:67108864',
            *([] if args.allow_sanitizer_shadow else ['--as=3221225472:3221225472']), '--',
            *command,
        ]
        started = time.time()
        # The timeout is inside the container. Do not kill/restart a still-live
        # computation just because an outer observation handle yields.
        with log.open('w') as stream:
            result = subprocess.run(docker_command, stdout=stream, stderr=subprocess.STDOUT)
        timing = output(['docker', 'exec', args.container, 'cat', measure])
        fields = timing.strip().splitlines()[-1].split()
        record = {
            'command': command, 'workdir': args.workdir,
            'container_image_id': info['Image'],
            'started_unix': started, 'wall_limit_seconds': args.seconds,
            'host_elapsed_seconds': time.time() - started,
            'elapsed_seconds': float(fields[0]), 'peak_rss_kib': int(fields[1]),
            'exit_status': result.returncode, 'timing_exit_status': int(fields[2]),
            'container_memory_limit_bytes': config['Memory'],
            'address_space_limit_bytes': None if args.allow_sanitizer_shadow else 3221225472,
            'output_file_limit_bytes': 67108864,
            'log_sha256': file_hash(log),
            'measurement': 'GNU time around timeout/prlimit; maximum child RSS, not aggregate process-tree memory',
            'scope': 'Command receipt only; inspect theorem types, assumptions and logs before claiming verification.',
        }
        receipt.write_text(json.dumps(record, indent=2) + '\n')
        print(json.dumps(record, indent=2), flush=True)
        raise SystemExit(result.returncode)


if __name__ == '__main__':
    main()
