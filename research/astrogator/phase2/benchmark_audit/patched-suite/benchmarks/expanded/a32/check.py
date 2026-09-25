import stat
for path, before in permission_prestate.items():
 actual = os.lstat(path).st_mode
 assert stat.S_ISDIR(actual) if before['directory'] else stat.S_ISREG(actual), path
 assert (actual & 0o644) == 0o644, ('required owner rw and everyone read',path)
 if before['directory']: assert (actual & 0o111) == 0o111, ('directory traversal',path)
 elif not before['executable']: assert (actual & 0o111) == 0, ('must not introduce executable regular file',path)
