"""Launcher-only resource-safe polling; never infer success from inactivity."""
import errno
import json
import hashlib
from pathlib import Path
import subprocess
import time


def run(argv, **kwargs):
    """Retry fork resource exhaustion only; do not retry a started failed job."""
    while True:
        try:
            return subprocess.run(argv, **kwargs)
        except OSError as error:
            if error.errno != errno.EAGAIN:
                raise
            print('Transient process-cap exhaustion; retrying launcher in 5 seconds', flush=True)
            time.sleep(5)


def wait_success(unit):
    while True:
        p=run(['systemctl','--user','show',unit,'-p','LoadState','-p','ActiveState',
               '-p','Result','-p','ExecMainCode','-p','ExecMainStatus','-p','ExecMainStartTimestampMonotonic'],
              capture_output=True,text=True,check=True)
        state=dict(line.split('=',1) for line in p.stdout.splitlines() if '=' in line)
        if state.get('ActiveState') in ('active','activating','deactivating','reloading'):
            time.sleep(5)
            continue
        if state.get('LoadState')=='not-found':
            # Successful transient units can be collected before the next poll.
            # Require the latest terminal journal event, not mere disappearance.
            log=run(['journalctl','--user','USER_UNIT='+unit,'SYSLOG_IDENTIFIER=systemd','-n','80','-o','json','--no-pager'],
                    capture_output=True,text=True,check=True)
            entries=[json.loads(line) for line in log.stdout.splitlines() if line.strip()]
            messages=[entry.get('MESSAGE','') for entry in entries]
            latest_start=max((i for i,m in enumerate(messages) if m.startswith('Started ')),default=-1)
            recent=messages[latest_start+1:]
            if any('Failed with result' in m or 'Main process exited' in m or m.startswith(('Stopping ','Stopped ')) for m in recent):
                raise RuntimeError(f'Dependency {unit} failed or was stopped: {recent}')
            if any('Deactivated successfully.' in m or m.startswith('Finished ') for m in recent):return
            # This systemd configuration logs resource consumption, not success,
            # for collected transient jobs. Require BOTH clean terminal manager
            # evidence and complete hash-validated artifacts, never disappearance.
            if any(': Consumed ' in m for m in recent) and artifacts_complete(unit):return
            raise RuntimeError(f'Dependency {unit} disappeared without evidence of success')
        if state.get('Result')=='success' and state.get('ExecMainCode')=='1' and state.get('ExecMainStatus')=='0' and state.get('ExecMainStartTimestampMonotonic') not in (None,'0'):
            return
        raise RuntimeError(f'Dependency {unit} did not complete successfully: {state}')


def artifacts_complete(unit):
    here=Path(__file__).resolve().parent
    root=here.parents[1]
    def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
    try:
        if unit=='astrogator-phase2-generated-tests.service':
            directory=here/'generated-tests'
            cfg=json.loads((directory/'frozen.json').read_text())
            for name,h in cfg['source_sha256'].items():
                if digest(root/name)!=h:return False
            for name,h in cfg['check_sha256'].items():
                if digest(directory/'specifications'/name)!=h:return False
            rows=[r for r in map(json.loads,(root/'data/manifest.jsonl').read_text().splitlines()) if r['task_id'] in ('a01','a02','a06','a17') and 'response' in r['artifacts']]
            for row in rows:
                for scenario in ('baseline','adversarial'):
                    p=directory/'cases'/(row['sample_id'].replace('/','-')+'-'+scenario+'.json')
                    d=json.loads(p.read_text())
                    if d['sample_id']!=row['sample_id'] or d['scenario']!=scenario:return False
                    if d.get('candidate_sha256')!=row['artifacts']['response']['sha256'] and d['status']!='harness_error':return False
            return len(rows)==422
        if unit=='astrogator-phase2-finish-inference.service':
            for name in ('frontier','frontier-full-judge'):
                directory=here/name;path=directory/'frozen-inputs.json';cfg=json.loads(path.read_text())
                for model in cfg['models']:
                    for task in cfg['tasks']:
                        d=json.loads((directory/model/(task['id']+'.json')).read_text())
                        if d['task']!=task or d['frozen_input_sha256']!=digest(path):return False
            return True
        marker=here/(unit+'.success.json')
        d=json.loads(marker.read_text())
        return d.get('unit')==unit and d.get('completed_successfully') is True
    except (OSError,ValueError,KeyError,TypeError):
        return False


def mark_success(unit):
    here=Path(__file__).resolve().parent
    p=here/(unit+'.success.json');tmp=p.with_suffix('.tmp')
    tmp.write_text(json.dumps({'unit':unit,'completed_successfully':True,'finished_at_epoch':time.time()})+'\n')
    tmp.replace(p)
