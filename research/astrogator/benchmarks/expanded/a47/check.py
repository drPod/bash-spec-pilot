s=os.stat('/home/app'); assert s.st_uid == pwd.getpwnam('app').pw_uid; assert s.st_gid == grp.getgrnam('app').gr_gid; assert mode('/home/app') == 0o700; assert read('/home/app/keep') == 'keep'
