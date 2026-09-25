git_fixture()
if adversarial:
 run('git','clone','-b','main','/fixtures/repo','/work/checkout'); put('/fixtures/repo/version','new-main'); run('git','-C','/fixtures/repo','commit','-am','advance')

expected_checkout_commit = output('git','-C','/work/checkout' if adversarial else '/fixtures/repo','rev-parse','HEAD' if adversarial else 'main').strip()
tracked_repository = '/work/checkout' if adversarial else '/fixtures/repo'
tracked_revision = 'HEAD' if adversarial else 'main'
expected_tracked_files = {}
for record in subprocess.check_output(['git','-C',tracked_repository,'ls-tree','-rz',tracked_revision]).split(b'\0'):
 if not record: continue
 metadata, raw_name = record.split(b'\t',1); name = os.fsdecode(raw_name)
 assert metadata.split()[0] in [b'100644',b'100755'], 'fixture scope: tracked regular files only'
 expected_tracked_files[name] = subprocess.check_output(['git','-C',tracked_repository,'show',tracked_revision+':'+name])
if adversarial:
 for name, data in expected_tracked_files.items():
  assert not P('/work/checkout',name).is_symlink() and P('/work/checkout',name).read_bytes() == data, 'fixture scope: clean tracked bytes, independently of index flags'
 assert subprocess.run(['git','-C','/work/checkout','diff','--quiet','HEAD'],capture_output=True).returncode == 0, 'fixture scope: clean tracked worktree; untracked files allowed'
