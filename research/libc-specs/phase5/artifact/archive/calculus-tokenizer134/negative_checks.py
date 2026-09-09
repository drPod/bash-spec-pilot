from pathlib import Path
import subprocess,json,hashlib,sys
J=Path(__file__).parent
B=Path(sys.argv[1]);out=Path(sys.argv[2]);out.mkdir(exist_ok=True)
valid="ok\t(return 0)\n"
cases={"missing_tab":"badline\n", "unterminated_quote":'bad\t(ret (str "oops))\n', "trailing_tokens":"bad\t(return 0) junk\n", "unsupported":"bad\t(unsupported)\n", "mixed_valid_invalid":valid+"badline\n", "quoted_bad_name":'bad"name\n'}
records=[]
for name,data in cases.items():
 f=out/(name+'.tsv');f.write_text(data)
 for exe in ['export-run','compare-run']:
  cmd=[str(B/exe)]+(['ok',str(f)] if exe=='compare-run' else [])
  r=subprocess.run(cmd,input=(data if exe=='export-run' else 'case\t\t\t\n'),text=True,capture_output=True,timeout=10)
  rows=[];malformed=[]
  for stream in [r.stdout,r.stderr]:
   for line in stream.splitlines():
    if line.startswith('{'):
     try:rows.append(json.loads(line))
     except ValueError:malformed.append(line)
  executed=any(x.get('outcome')!='parse_rejected' for x in rows)
  records.append(dict(case=name,exe=exe,returncode=r.returncode,stdout=r.stdout,stderr=r.stderr,malformed_json=malformed,executed=executed,passed=r.returncode!=0 and bool(rows) and not malformed and not executed,bin_sha256=hashlib.sha256((B/exe).read_bytes()).hexdigest()))
(out/'checks.json').write_text(json.dumps(records,indent=2)+'\n')
print(json.dumps({'checks':len(records),'passed':sum(r['passed'] for r in records),'failed':[r['exe']+':'+r['case'] for r in records if not r['passed']]}))
