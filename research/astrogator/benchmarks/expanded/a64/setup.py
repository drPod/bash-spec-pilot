run('useradd','-m','app'); put('/work/data/keep','keep')
if adversarial: os.chown('/work/data',pwd.getpwnam('app').pw_uid,grp.getgrnam('app').gr_gid)
