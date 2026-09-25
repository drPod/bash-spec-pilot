assert os.stat('/work/source').st_ino == os.stat('/work/alias').st_ino; assert not P('/work/alias').is_symlink(); assert P('/work/source').read_bytes() == expected_source_bytes
