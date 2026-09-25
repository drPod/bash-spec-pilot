u=pwd.getpwnam('app'); assert u.pw_gid == grp.getgrnam('deploy').gr_gid; assert P(u.pw_dir).is_dir()
