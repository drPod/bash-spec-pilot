#!/usr/bin/env python3
"""New-version oracle sensitivity study. Run only inside the bounded lab image.

The password probe establishes hash verification, not PAM/SSH authentication.
The strict integrity check is an explicit strengthening, not retroactive gold.
"""
import ctypes
import hashlib
import json
import os
from pathlib import Path
import pwd
import subprocess
import sys
import time

HASH = '$6$astrolab$GfDheI3dJMI7bPFBGNmrcPJ4//UlyTCt7GxxluOHGKjhBWB1/8O/IyrtzbN1sk41YqlCMgqZobe7QoOiYcRd70'
PASSWORD = b'AstrogatorFixtureOnly'


def run(*args):
    return subprocess.run(args, capture_output=True, text=True, check=True)


def password_matches(value):
    lib = ctypes.CDLL('libcrypt.so.1')
    lib.crypt.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
    lib.crypt.restype = ctypes.c_char_p
    return lib.crypt(PASSWORD, value.encode()) == value.encode()


def observe(task, scenario):
    if task == 'a06':
        p = Path('/etc/file.txt')
        data = p.read_bytes() if p.is_file() else None
        target = b'existing content' if scenario == 'adversarial' else b'beginning'
        return {'file_exists': p.is_file(), 'content_hex': data.hex() if data is not None else None,
                'old_oracle': data == target,
                'single_final_newline_tolerant': data in (target, target + b'\n') if scenario == 'baseline' else data == target}
    lines = [s.split(':') for s in Path('/etc/shadow').read_text().splitlines() if s.split(':')[0] == 'service']
    passwd = [s.split(':') for s in Path('/etc/passwd').read_text().splitlines() if s.split(':')[0] == 'service']
    try:
        pwd.getpwnam('service')
        user_exists = True
    except KeyError:
        user_exists = False
    locked = bool(lines and len(lines[0]) >= 2 and lines[0][1].startswith(('!', '*')))
    structure = len(lines) == 1 and len(lines[0]) == 9 and len(passwd) == 1 and len(passwd[0]) == 7
    aging = structure and all(not x or (x.isascii() and x.isdigit()) for x in lines[0][2:8])
    reserved = structure and not lines[0][8]
    integrity = bool(structure and aging and reserved)
    return {'user_exists': user_exists, 'service_shadow_entries': lines,
            'service_passwd_entries': passwd, 'password_locked_marker': locked,
            'shadow_and_passwd_integrity': integrity, 'old_oracle': user_exists and locked,
            'strict_oracle': user_exists and locked and integrity,
            'fixture_password_still_matches': password_matches(lines[0][1]) if lines and len(lines[0]) > 1 else None}


def main():
    assert Path('/.dockerenv').exists() and Path('/opt/astrogator-lab-marker').exists()
    task, scenario, candidate = sys.argv[1:]
    assert task in ('a06', 'a17') and scenario in ('baseline', 'adversarial')
    result = {'task_id': task, 'scenario': scenario, 'status': 'fixture_error',
              'candidate_sha256': hashlib.sha256(Path(candidate).read_bytes()).hexdigest(),
              'runner_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
    start = time.monotonic()
    try:
        if task == 'a17':
            assert password_matches(HASH), 'Real password hash control failed'
            run('useradd', '-m', 'service')
            run('usermod', '-p', ('!' if scenario == 'adversarial' else '') + HASH, 'service')
            result['before'] = observe(task, scenario)
            assert result['before']['fixture_password_still_matches'] == (scenario == 'baseline')
            assert result['before']['shadow_and_passwd_integrity']
        elif scenario == 'adversarial':
            Path('/etc/file.txt').write_text('existing content')
        process = subprocess.run(['ansible-playbook', '-i', 'localhost,', '-c', 'local',
                                  '-e', 'ansible_python_interpreter=/usr/bin/python3', candidate],
                                 capture_output=True, text=True, timeout=45,
                                 env={**os.environ, 'ANSIBLE_NOCOLOR': '1', 'ANSIBLE_LOCAL_TEMP': '/tmp/ansible-local'})
        result['execution'] = {'returncode': process.returncode, 'stdout': process.stdout, 'stderr': process.stderr}
        result['status'] = 'observed' if process.returncode == 0 else 'execution_error'
        result['after'] = observe(task, scenario)
    except subprocess.TimeoutExpired:
        result['status'] = 'execution_timeout'
    except Exception as e:
        result['error'] = repr(e)
    result['seconds'] = round(time.monotonic() - start, 3)
    print(json.dumps(result))


if __name__ == '__main__':
    main()
