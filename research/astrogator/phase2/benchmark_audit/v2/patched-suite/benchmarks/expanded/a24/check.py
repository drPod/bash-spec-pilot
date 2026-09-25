import stat
assert stat.S_ISDIR(os.lstat('/work/spool').st_mode); assert mode('/work/spool') == 0o1777
