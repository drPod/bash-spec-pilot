import json,sys
sys.path.insert(0,'/suite/scripts');from upstream_eval import probe
for q in ['create directory at /d with read=none','create directory at /d with read=','create directory at /d with setuid=true, setgid=true, sticky=true','create directory at /d with sticky=false']:
 print(json.dumps({'query':q,'result':probe(q)}),flush=True)
