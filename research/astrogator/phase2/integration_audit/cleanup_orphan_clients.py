#!/usr/bin/env python3
"""Terminate only adopted orphan roots inside the named research unit (opt-in)."""
import argparse
from datetime import datetime,timezone
import json
import os
from pathlib import Path
import signal

ALLOWED={'astrogator-phase2-finish-inference.service','astrogator-phase2-finish-translation.service','astrogator-phase2-environment-judge.service'}
def main():
 p=argparse.ArgumentParser();p.add_argument('unit',choices=sorted(ALLOWED));p.add_argument('--apply',action='store_true');a=p.parse_args()
 processes={}
 for path in Path('/proc').iterdir():
  if not path.name.isdigit():continue
  try:
   status={line.split(':',1)[0]:line.split(':',1)[1].strip() for line in (path/'status').read_text().splitlines() if ':' in line}
   processes[int(path.name)]={'ppid':int(status['PPid']),'name':status['Name'],'uid':int(status['Uid'].split()[0]),'cgroup':(path/'cgroup').read_text()}
  except (OSError,ValueError,KeyError):continue
 managers={pid for pid,d in processes.items() if d['name']=='systemd' and d['uid']==os.getuid()}
 victims=[]
 for pid,d in processes.items():
  if d['name'] not in {'codex','claude','node','bash','sh','wakatime-cli'}:continue
  if d['ppid'] not in managers or not any(line.rstrip().endswith('/'+a.unit) for line in d['cgroup'].splitlines()):continue
  row={'pid':pid,'name':d['name'],'ppid':d['ppid'],'reason':'Adopted by same-user systemd manager inside specified research unit; no live inference parent.'}
  if a.apply:
   try:os.kill(pid,signal.SIGTERM);row['action']='SIGTERM'
   except ProcessLookupError:row['action']='already_exited'
  else:row['action']='dry_run'
  victims.append(row)
 result={'at':datetime.now(timezone.utc).isoformat(),'unit':a.unit,'apply':a.apply,'roots':victims}
 dest=Path(__file__).resolve().parent/'orphan-cleanup-events.jsonl'
 if a.apply:
  with dest.open('a') as output:output.write(json.dumps(result)+'\n')
 print(json.dumps(result,indent=2))
if __name__=='__main__':main()
