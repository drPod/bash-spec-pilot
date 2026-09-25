assert output('git','-C','/work/checkout','rev-parse','HEAD').strip() == expected_checkout_commit
