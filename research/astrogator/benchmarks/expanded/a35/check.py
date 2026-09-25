lines=read('/work/app.conf').splitlines(); assert [x for x in lines if x.startswith('port=')] == ['port=8080']; assert '# keep' in lines and 'mode=safe' in lines
