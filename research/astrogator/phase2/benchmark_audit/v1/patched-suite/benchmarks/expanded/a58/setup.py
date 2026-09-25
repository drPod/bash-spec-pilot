s='0 0 * * * /bin/echo keep\n' + ('#Ansible: astro cleanup\n0 1 * * * /bin/false\n' if adversarial else ''); subprocess.run(['crontab','-'],input=s,text=True,check=True)
