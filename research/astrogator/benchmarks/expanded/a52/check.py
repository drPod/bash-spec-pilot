assert read('/work/checkout/version') == 'release'; assert output('git','-C','/work/checkout','rev-parse','HEAD').strip() == output('git','-C','/fixtures/repo','rev-parse','release').strip()
