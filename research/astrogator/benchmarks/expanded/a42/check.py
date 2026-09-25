assert pwd.getpwnam('app').pw_gid == grp.getgrnam('deploy').gr_gid; assert read('/home/app/keep') == 'keep'
