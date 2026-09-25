import stat
for name, data in expected_tracked_files.items():
 assert stat.S_ISREG(os.lstat(P('/work/checkout',name)).st_mode), name
 assert P('/work/checkout',name).read_bytes() == data, ('tracked bytes changed', name)
assert read('/work/checkout/version') == 'main'
assert output('git','-C','/work/checkout','rev-parse','HEAD').strip() == expected_checkout_commit
assert subprocess.run(['git','-C','/work/checkout','diff','--quiet','HEAD'],capture_output=True).returncode == 0, 'tracked worktree changed; untracked files are allowed'
