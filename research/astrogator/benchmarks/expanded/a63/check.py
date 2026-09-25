assert pwd.getpwnam('app').pw_gid == grp.getgrnam('primary').gr_gid; assert 'app' in grp.getgrnam('deploy').gr_mem; assert 'app' in grp.getgrnam('audit').gr_mem
