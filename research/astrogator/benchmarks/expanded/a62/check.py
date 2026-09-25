assert 'obsolete' not in [g.gr_name for g in grp.getgrall()]; assert grp.getgrnam('active').gr_gid == 1601
