s=os.stat('/work/data'); assert s.st_uid == pwd.getpwnam('app').pw_uid; assert s.st_gid == grp.getgrnam('app').gr_gid
for path,(data,uid,gid) in expected_child_state.items():
 s=os.stat(path); assert s.st_uid == uid and s.st_gid == gid; assert P(path).read_bytes() == data
