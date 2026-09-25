s=read('/work/app.conf'); assert 'endpoint=https://one\n' in s; assert '# endpoint=http://example\n' in s; assert 'other=http://keep\n' in s
if adversarial: assert 'endpoint=https://two\n' in s
