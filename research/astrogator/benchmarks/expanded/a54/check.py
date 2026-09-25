assert output('git','-C','/work/checkout','rev-parse','HEAD').strip() == output('git','-C','/fixtures/repo','rev-parse','v1').strip(); assert read('/work/checkout/version') == 'tag-v1'
