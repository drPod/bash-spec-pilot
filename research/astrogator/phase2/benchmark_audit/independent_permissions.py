import pathlib,os,subprocess,json
assert pathlib.Path('/.dockerenv').exists()
rows=[]
for kind,modes in [('directory',['0700','u=rwX','u=rwX,g=,o=']),('file',['0700','u=rwx','u=rwx,g=,o='])]:
 for i,mode in enumerate(modes):
  path=pathlib.Path('/tmp/permission-'+kind+str(i))
  path.mkdir() if kind=='directory' else path.write_text('data')
  os.chmod(path,0o777)
  play=[{'hosts':'all','gather_facts':False,'tasks':[{'ansible.builtin.file':{'path':str(path),'state':kind,'mode':mode}}]}]
  pp=pathlib.Path('/tmp/play.json');pp.write_text(json.dumps(play))
  r=subprocess.run(['ansible-playbook','-i','localhost,','-c','local','-e','ansible_python_interpreter=/usr/bin/python3',str(pp)],capture_output=True,text=True,timeout=45)
  rows.append({'object':kind,'initial_mode':'0777','requested_mode':mode,'actual_mode':format(path.stat().st_mode & 0o7777,'04o'),'returncode':r.returncode,'stdout':r.stdout,'stderr':r.stderr})
print(json.dumps(rows,indent=2))
