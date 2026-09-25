run('useradd','-m','app'); put('/work/data/keep','keep')
if adversarial: os.chown('/work/data',pwd.getpwnam('app').pw_uid,grp.getgrnam('app').gr_gid)

expected_child_state = {str(p): (p.read_bytes(), p.stat().st_uid, p.stat().st_gid) for p in P('/work/data').rglob('*') if p.is_file()}
