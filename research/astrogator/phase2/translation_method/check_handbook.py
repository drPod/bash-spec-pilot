#!/usr/bin/env python3
"""Source-derived smoke cases; not target tasks, references, or quality labels."""
import json
import sys
from pathlib import Path
sys.path.insert(0,'/suite/scripts')
from upstream_eval import probe
CASES=[
'create file at "/probe/item" with content="alpha", owner="nobody", read=all, write=owner.',
'create directory at "/probe/tree" with owner="nobody", list directory=owner group.',
'delete file at "/probe/item".',
'delete directory at "/probe/tree".',
'delete files in "/probe/tree" with glob="*.tmp".',
'copy file from controller "/probe/source" to remote "/probe/dest".',
'copy directory from "/probe/source" to "/probe/dest".',
'copy files from "/probe/source" to "/probe/dest" with glob="*.cfg".',
'move file from "/probe/source" to "/probe/dest".',
'move directory from "/probe/source" to "/probe/dest".',
'move files from "/probe/source" to "/probe/dest" with glob="*.cfg".',
'download file from "https://probe.invalid/item" to "/probe/item".',
'write "alpha" to "/probe/item" with position=overwrite.',
'set file permissions for "/probe/item" with read=all, write=owner.',
'set file permissions in "/probe/tree" with execute=owner group.',
'create user with name="probeuser", primary group="staff", supplemental groups="audio" "video".',
'delete user with name="probeuser".',
'create group with name="probegroup".',
'delete group with name="probegroup".',
'disable password for user="probeuser".',
'enable sudo for user="probeuser".',
'disable sudo for group="probegroup".',
'enable passwordless sudo for group="probegroup".',
'disable passwordless sudo for user="probeuser".',
'set default shell for user="probeuser" to bash.',
'create ssh key for user="probeuser" with name="probe_key".',
'create ssh key for user="probeuser" at "/probe/key".',
'install bash with version="5".',
'uninstall zsh.',
'start ssh server service.',
'stop postfix service.',
'clone git repository from "https://probe.invalid/repo" into "/probe/tree" with branch="stable".',
'clone github repository with name="probeorg/proberepo" into "/probe/tree" via ssh with tag="v3".',
'create virtual environment in "/probe/venv" with python="3".',
'set environment variable PROBE to "alpha".',
'reboot.',
'if os is Ubuntu then install apache server; start apache server service.',
'if os is Debian based then if reboot required then reboot.',
'if file "/probe/item" not exists then create file at "/probe/item".',
'if directory at "/probe/tree" exists then delete directory at "/probe/tree".',
'if bash installed then uninstall bash.',
'if ssh server running then stop ssh server service.',
'install numpy in virtual environment at "/probe/venv".',
'create bash configuration file for user="probeuser".',
'write "alpha" to zsh configuration file for user="probeuser" with position=end.',
'copy postfix configuration file to "/probe/backup".',
'create zsh configuration directory for user="probeuser".',
'if os is RedHat then install ssh client otherwise if os is Debian based then install ssh client.',
]
if __name__=='__main__':
    rows=[{'id':f'source-example-{i:02d}','query':q,'result':probe(q)} for i,q in enumerate(CASES)]
    print(json.dumps({'purpose':'Language-reference smoke checks, not benchmark query validation','cases':rows,'passed':sum(r['result']['returncode']==0 for r in rows),'total':len(rows)},indent=2))
