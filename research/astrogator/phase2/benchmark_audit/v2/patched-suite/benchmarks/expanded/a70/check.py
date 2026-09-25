import stat
for rel,data in expected_source_files.items():
 assert stat.S_ISREG(os.lstat(P('/work/source',rel)).st_mode); assert P('/work/source',rel).read_bytes() == data
for rel in expected_source_dirs: assert stat.S_ISDIR(os.lstat(P('/work/source',rel)).st_mode)
for rel,data in expected_dest_files.items():
 assert stat.S_ISREG(os.lstat(P('/work/dest',rel)).st_mode); assert P('/work/dest',rel).read_bytes() == data
for rel in expected_dest_dirs: assert stat.S_ISDIR(os.lstat(P('/work/dest',rel)).st_mode)
assert not P('/work/dest/source').exists()
