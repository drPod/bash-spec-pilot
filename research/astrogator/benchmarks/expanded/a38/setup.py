put('/work/rules','allow admin\n' + ('allow local\n' if adversarial else '') + 'deny all\n')
