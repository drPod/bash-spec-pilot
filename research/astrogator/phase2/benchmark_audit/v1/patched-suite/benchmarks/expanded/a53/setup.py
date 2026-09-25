git_fixture()
if adversarial:
 run('git','clone','-b','main','/fixtures/repo','/work/checkout'); put('/fixtures/repo/version','new-main'); run('git','-C','/fixtures/repo','commit','-am','advance')

expected_checkout_commit = output('git','-C','/work/checkout' if adversarial else '/fixtures/repo','rev-parse','HEAD' if adversarial else 'main').strip()
