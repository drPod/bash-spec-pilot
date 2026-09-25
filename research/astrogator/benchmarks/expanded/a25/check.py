assert read('/work/app.conf') == ('port=9090\n# keep\n' if adversarial else 'port=8080\n')
