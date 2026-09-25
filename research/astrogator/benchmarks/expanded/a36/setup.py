put('/work/app.conf','mode=safe\n# legacy=example\n' + ('legacy=yes\nlegacy=no\n' if adversarial else ''))
