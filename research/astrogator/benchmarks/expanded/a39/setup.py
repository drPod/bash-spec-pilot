put('/work/app.conf','endpoint=http://one\n# endpoint=http://example\nother=http://keep\n' + ('endpoint=http://two\n' if adversarial else ''))
