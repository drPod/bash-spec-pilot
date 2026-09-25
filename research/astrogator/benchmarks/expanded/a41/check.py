assert 'app' in grp.getgrnam('deploy').gr_mem
if adversarial: assert 'app' in grp.getgrnam('audit').gr_mem
