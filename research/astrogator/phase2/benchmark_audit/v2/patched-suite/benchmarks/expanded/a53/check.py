assert read('/work/checkout/version') == 'main'
assert output('git','-C','/work/checkout','rev-parse','HEAD').strip() == expected_checkout_commit
assert subprocess.run(['git','-C','/work/checkout','diff','--quiet','HEAD'],capture_output=True).returncode == 0, 'tracked worktree changed; untracked files are allowed'
