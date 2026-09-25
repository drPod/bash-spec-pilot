"""Review-responsive necessary-condition checks; not complete semantic gold."""
import pathlib,shutil,difflib,json,hashlib
p=pathlib.Path(__file__).parent;root=p.parents[1]
setup={
'a24':'',
'a32':"""
permission_prestate = {str(p): {'directory': p.is_dir(), 'executable': bool(mode(p) & 0o111)} for p in [P('/work/tree'), *P('/work/tree').rglob('*')]}
assert not any(p.is_symlink() for p in [P('/work/tree'), *P('/work/tree').rglob('*')]), 'fixture scope: no symbolic links'
""",
'a34':"\nexpected_source_bytes = P('/work/source').read_bytes()\n",
'a53':"""
expected_checkout_commit = output('git','-C','/work/checkout' if adversarial else '/fixtures/repo','rev-parse','HEAD' if adversarial else 'main').strip()
if adversarial:
 assert subprocess.run(['git','-C','/work/checkout','diff','--quiet','HEAD'],capture_output=True).returncode == 0, 'fixture scope: clean tracked worktree; untracked files allowed'
""",
'a58':'',
'a64':"\nexpected_child_state = {str(p): (p.read_bytes(), p.stat().st_uid, p.stat().st_gid) for p in P('/work/data').rglob('*') if p.is_file()}\n",
'a68':'',
'a70':"""
# Scope is explicitly regular files/directories; symlink semantics need a separate task.
assert not any(p.is_symlink() for base in ['/work/source','/work/dest'] for p in P(base).rglob('*')), 'fixture scope: no symbolic links'
expected_source_files = {str(p.relative_to('/work/source')): p.read_bytes() for p in P('/work/source').rglob('*') if p.is_file()}
expected_source_dirs = {str(p.relative_to('/work/source')) for p in P('/work/source').rglob('*') if p.is_dir()}
preexisting_dest_files = {str(p.relative_to('/work/dest')): p.read_bytes() for p in P('/work/dest').rglob('*') if p.is_file()}
preexisting_dest_dirs = {str(p.relative_to('/work/dest')) for p in P('/work/dest').rglob('*') if p.is_dir()}
assert not (set(expected_source_files) & preexisting_dest_dirs or expected_source_dirs & set(preexisting_dest_files)), 'fixture scope: no file/directory type conflicts'
# Same-path file collisions are valid: source bytes win; unrelated destination bytes survive.
expected_dest_files = {**preexisting_dest_files, **expected_source_files}
expected_dest_dirs = preexisting_dest_dirs | expected_source_dirs
"""}
check={
'a24':"import stat\nassert stat.S_ISDIR(os.lstat('/work/spool').st_mode); assert mode('/work/spool') == 0o1777\n",
'a32':"""import stat
for path, before in permission_prestate.items():
 actual = os.lstat(path).st_mode
 assert stat.S_ISDIR(actual) if before['directory'] else stat.S_ISREG(actual), path
 assert (actual & 0o644) == 0o644, ('required owner rw and everyone read',path)
 if before['directory']: assert (actual & 0o111) == 0o111, ('directory traversal',path)
 elif not before['executable']: assert (actual & 0o111) == 0, ('must not introduce executable regular file',path)
""",
'a34':"assert os.stat('/work/source').st_ino == os.stat('/work/alias').st_ino; assert not P('/work/alias').is_symlink(); assert P('/work/source').read_bytes() == expected_source_bytes\n",
'a53':"""assert read('/work/checkout/version') == 'main'
assert output('git','-C','/work/checkout','rev-parse','HEAD').strip() == expected_checkout_commit
assert subprocess.run(['git','-C','/work/checkout','diff','--quiet','HEAD'],capture_output=True).returncode == 0, 'tracked worktree changed; untracked files are allowed'
""",
'a58':"lines=output('crontab','-l').splitlines(); assert lines.count('#Ansible: astro cleanup') == 1; i=lines.index('#Ansible: astro cleanup'); assert lines[i+1] == '15 2 * * * /usr/bin/true'; assert '0 0 * * * /bin/echo keep' in lines; assert '/bin/false' not in '\\n'.join(lines)\n",
'a64':"s=os.stat('/work/data'); assert s.st_uid == pwd.getpwnam('app').pw_uid; assert s.st_gid == grp.getgrnam('app').gr_gid\nfor path,(data,uid,gid) in expected_child_state.items():\n s=os.stat(path); assert s.st_uid == uid and s.st_gid == gid; assert P(path).read_bytes() == data\n",
'a68':"import stat\nif adversarial: assert stat.S_ISDIR(os.lstat('/work/cache').st_mode)\nelse: assert not os.path.lexists('/work/cache')\n",
'a70':"""import stat
for rel,data in expected_source_files.items():
 assert stat.S_ISREG(os.lstat(P('/work/source',rel)).st_mode); assert P('/work/source',rel).read_bytes() == data
for rel in expected_source_dirs: assert stat.S_ISDIR(os.lstat(P('/work/source',rel)).st_mode)
for rel,data in expected_dest_files.items():
 assert stat.S_ISREG(os.lstat(P('/work/dest',rel)).st_mode); assert P('/work/dest',rel).read_bytes() == data
for rel in expected_dest_dirs: assert stat.S_ISDIR(os.lstat(P('/work/dest',rel)).st_mode)
assert not P('/work/dest/source').exists()
"""}
parts=[];manifest={}
for task in check:
 src=root/'benchmarks/expanded'/task;dest=p/'patched-suite/benchmarks/expanded'/task
 shutil.copytree(src,dest,dirs_exist_ok=True)
 (dest/'setup.py').write_text((src/'setup.py').read_text()+setup[task]);(dest/'check.py').write_text(check[task])
 for name in ['setup.py','check.py']:
  rel=str((src/name).relative_to(pathlib.Path.cwd()));parts.extend(difflib.unified_diff((src/name).read_text().splitlines(True),(dest/name).read_text().splitlines(True),fromfile='a/'+rel,tofile='b/'+rel));manifest[rel]={'original':hashlib.sha256((src/name).read_bytes()).hexdigest(),'patched':hashlib.sha256((dest/name).read_bytes()).hexdigest()}
(p/'oracle-adequacy.patch').write_text(''.join(parts));(p/'patch-input-hashes.json').write_text(json.dumps(manifest,indent=2)+'\n')
