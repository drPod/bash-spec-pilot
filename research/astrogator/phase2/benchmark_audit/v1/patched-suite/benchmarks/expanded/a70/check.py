for rel,data in expected_source_files.items():
 assert P('/work/source',rel).read_bytes() == data; assert P('/work/dest',rel).read_bytes() == data
for path,data in expected_dest_files.items(): assert P(path).read_bytes() == data
assert not P('/work/dest/source').exists()
