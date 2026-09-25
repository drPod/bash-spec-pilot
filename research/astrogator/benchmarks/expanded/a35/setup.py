put('/work/app.conf','# keep\nmode=safe\n' + ('port=9090\n' if adversarial else ''))
