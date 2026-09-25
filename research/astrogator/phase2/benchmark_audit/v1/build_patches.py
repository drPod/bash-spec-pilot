import pathlib,shutil,json
p=pathlib.Path(__file__).parent; root=p.parents[1]
add_setup={
'a24':'',
'a32':"\nexpected_modes = {str(p): (0o755 if p.is_dir() or (mode(p) & 0o111) else 0o644) for p in [P('/work/tree'), *P('/work/tree').rglob('*')]}\n",
'a34':"\nexpected_source_bytes = P('/work/source').read_bytes()\n",
'a53':"\nexpected_checkout_commit = output('git','-C','/work/checkout' if adversarial else '/fixtures/repo','rev-parse','HEAD' if adversarial else 'main').strip()\n",
'a58':'',
'a64':"\nexpected_child_state = {str(p): (p.read_bytes(), p.stat().st_uid, p.stat().st_gid) for p in P('/work/data').rglob('*') if p.is_file()}\n",
'a68':'',
'a70':"\nexpected_source_files = {str(p.relative_to('/work/source')): p.read_bytes() for p in P('/work/source').rglob('*') if p.is_file()}\nexpected_dest_files = {str(p): p.read_bytes() for p in P('/work/dest').rglob('*') if p.is_file()}\n"}
checks={
'a24':"assert P('/work/spool').is_dir(); assert mode('/work/spool') == 0o1777\n",
'a32':"for path, expected in expected_modes.items():\n assert mode(path) == expected, path\n",
'a34':"assert os.stat('/work/source').st_ino == os.stat('/work/alias').st_ino; assert not P('/work/alias').is_symlink(); assert P('/work/source').read_bytes() == expected_source_bytes\n",
'a53':"assert output('git','-C','/work/checkout','rev-parse','HEAD').strip() == expected_checkout_commit\n",
'a58':"lines=output('crontab','-l').splitlines(); assert lines.count('#Ansible: astro cleanup') == 1; i=lines.index('#Ansible: astro cleanup'); assert lines[i+1] == '15 2 * * * /usr/bin/true'; assert '0 0 * * * /bin/echo keep' in lines; assert '/bin/false' not in '\\n'.join(lines)\n",
'a64':"s=os.stat('/work/data'); assert s.st_uid == pwd.getpwnam('app').pw_uid; assert s.st_gid == grp.getgrnam('app').gr_gid\nfor path,(data,uid,gid) in expected_child_state.items():\n s=os.stat(path); assert s.st_uid == uid and s.st_gid == gid; assert P(path).read_bytes() == data\n",
'a68':"if adversarial: assert P('/work/cache').is_dir()\nelse: assert not os.path.lexists('/work/cache')\n",
'a70':"for rel,data in expected_source_files.items():\n assert P('/work/source',rel).read_bytes() == data; assert P('/work/dest',rel).read_bytes() == data\nfor path,data in expected_dest_files.items(): assert P(path).read_bytes() == data\nassert not P('/work/dest/source').exists()\n"}
for task in checks:
 src=root/'benchmarks/expanded'/task;dest=p/'patched-suite/benchmarks/expanded'/task
 shutil.copytree(src,dest,dirs_exist_ok=True)
 (dest/'setup.py').write_text((src/'setup.py').read_text()+add_setup[task]);(dest/'check.py').write_text(checks[task])
