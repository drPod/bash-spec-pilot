import stat
if adversarial: assert stat.S_ISDIR(os.lstat('/work/cache').st_mode)
else: assert not os.path.lexists('/work/cache')
