put('/work/source','payload')
if adversarial: put('/work/alias','stale')

expected_source_bytes = P('/work/source').read_bytes()
