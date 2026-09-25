if adversarial: assert P('/work/cache').is_dir()
else: assert not os.path.lexists('/work/cache')
