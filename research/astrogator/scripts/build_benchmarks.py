#!/usr/bin/env python3
"""Author-maintained task additions. Generates reviewable YAML and Python oracles.

FQL is a candidate specification until tested against upstream and reviewed for
intent. No generated item is silently designated a gold query.
"""
import copy
import json
from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]
TASKS = []


def task(module, **args):
    return {"ansible.builtin." + module: args}


def add(title, family, nl, query, tasks, setup, checks, mutant, fault, tags=()):
    ident = f'a{22 + len(TASKS):02}'
    TASKS.append(dict(id=ident, title=title, family=family, natural_language=nl,
        formal_query=query, fql_status='candidate_not_reviewed', tasks=tasks,
        setup=setup, checks=checks, mutant=mutant, fault=fault,
        tags=list(tags), scenarios=['baseline', 'adversarial'],
        environment='Debian 13 disposable container; root; offline fixtures',
        provenance='Authored for this extension; not mined from independent workloads',
        review_status='author_draft',
        idempotence='state checked after two successful executions; changed-count not scored'))


def change(tasks, index, module, **kwargs):
    out = copy.deepcopy(tasks)
    out[index]['ansible.builtin.' + module].update(kwargs)
    return out


t=[task('file',path='/work/private',state='directory',mode='0700')]
add('Private application directory','filesystem',
    'Ensure /work/private is a directory accessible only by its owner (mode 0700), preserving any existing contents.',
    'create directory at /work/private with read=owner, write=owner, list directory=owner',t,
    "if adversarial: put('/work/private/keep', 'keep'); os.chmod('/work/private', 0o777)",
    "assert P('/work/private').is_dir(); assert mode('/work/private') == 0o700\nif adversarial: assert read('/work/private/keep') == 'keep'",
    change(t,0,'file',mode='0755'),'world-readable private directory', ['permissions','preservation'])
t=[task('file',path='/work/shared',state='directory',mode='2770')]
add('Shared setgid directory','filesystem','Ensure /work/shared has mode 2770, including setgid, without removing existing files.',
    'create directory at /work/shared with read=owner group, write=owner group, list directory=owner group, setgid=true',t,
    "if adversarial: put('/work/shared/keep','keep'); os.chmod('/work/shared',0o777)",
    "assert mode('/work/shared') == 0o2770\nif adversarial: assert read('/work/shared/keep') == 'keep'",
    change(t,0,'file',mode='0770'),'omitted setgid',['special-permissions'])
t=[task('file',path='/work/spool',state='directory',mode='1777')]
add('Sticky shared spool','filesystem','Ensure /work/spool is a directory with mode 1777, including the sticky bit.',
    'create directory at /work/spool with read=all, write=all, list directory=all, sticky=true',t,
    "if adversarial: put('/work/spool/keep','keep'); os.chmod('/work/spool',0o777)",
    "assert mode('/work/spool') == 0o1777",
    change(t,0,'file',mode='0777'),'omitted sticky bit',['special-permissions'])
t=[task('copy',dest='/work/app.conf',content='port=8080\n',force=False)]
add('Initialize without overwriting','configuration','If /work/app.conf is absent, create it with exactly port=8080 followed by a newline. Otherwise preserve its existing bytes.',
    'if file "/work/app.conf" not exists then create file at "/work/app.conf" with content="port=8080\n"',t,
    "if adversarial: put('/work/app.conf','port=9090\\n# keep\\n')",
    "assert read('/work/app.conf') == ('port=9090\\n# keep\\n' if adversarial else 'port=8080\\n')",
    change(t,0,'copy',force=True),'overwrites existing configuration',['conditional','preservation'])
t=[task('copy',dest='/work/banner',content='Authorized users only\n',mode='0644')]
add('Replace obsolete banner','configuration','Ensure /work/banner contains exactly Authorized users only followed by a newline, replacing stale content, with mode 0644.',
    'create file at /work/banner with content="Authorized users only\n", read=all, write=owner',t,
    "if adversarial: put('/work/banner','stale\\n'); os.chmod('/work/banner',0o600)",
    "assert read('/work/banner') == 'Authorized users only\\n'; assert mode('/work/banner') == 0o644",
    change(t,0,'copy',force=False),'preserves obsolete content',['replacement'])
t=[task('file',path='/work/dest',state='directory'),task('copy',src='/work/source',dest='/work/dest/data',remote_src=True)]
add('Copy with destination dependency','filesystem','Copy the remote file /work/source to /work/dest/data, creating the destination directory if needed and keeping the source.',
    'create directory at /work/dest; copy file from remote /work/source to remote /work/dest/data',t,
    "put('/work/source','payload\\x00tail')\nif adversarial: put('/work/dest/data','stale')",
    "assert read('/work/source') == 'payload\\x00tail'; assert read('/work/dest/data') == 'payload\\x00tail'",
    t[1:],'missing destination prerequisite',['dependency','binary-content'])
t=[dict(task('stat',path='/work/source'),register='src'),dict(task('copy',src='/work/source',dest='/work/moved',remote_src=True),when='src.stat.exists'),task('file',path='/work/source',state='absent')]
add('Move and remove source','filesystem','Move /work/source to /work/moved, replacing any existing destination and removing the source. The source initially exists; subsequent runs must retain the moved data.',
    'move file from remote /work/source to remote /work/moved',t,
    "put('/work/source','move me')\nif adversarial: put('/work/moved','old')",
    "assert not P('/work/source').exists(); assert read('/work/moved') == 'move me'",
    t[:-1],'copy without deleting source',['move','idempotence'])
t=[task('file',path='/work/link',state='absent')]
add('Unlink without deleting target','filesystem','Remove /work/link, which may be a symbolic link, while preserving /work/target and its contents.',
    'delete file at /work/link',t,
    "put('/work/target','valuable')\nif adversarial: os.symlink('/work/target','/work/link')",
    "assert not os.path.lexists('/work/link'); assert read('/work/target') == 'valuable'",
    [task('file',path='/work/target',state='absent')],'deletes link target',['symlink','preservation'])
t=[task('file',path='/work/obsolete',state='absent')]
add('Remove only obsolete tree','filesystem','Remove /work/obsolete and all its contents, preserving its sibling /work/current.',
    'delete directory at /work/obsolete',t,
    "put('/work/current/keep','keep')\nif adversarial: put('/work/obsolete/nested/.hidden','old')",
    "assert not P('/work/obsolete').exists(); assert read('/work/current/keep') == 'keep'",
    [task('file',path='/work',state='absent')],'deletes parent and sibling',['scope','recursive'])
t=[dict(task('find',paths='/work/cache',patterns='*.tmp',file_type='file',hidden=True,recurse=False),register='found'),dict(task('file',path='{{ item.path }}',state='absent'),loop='{{ found.files }}')]
add('Prune temporary files selectively','filesystem','Delete only top-level regular files matching *.tmp in /work/cache, including hidden matches. Preserve directories, nested files, and nonmatches.',
    'delete files in /work/cache with glob="*.tmp"',t,
    "put('/work/cache/a.tmp','delete'); put('/work/cache/keep.txt','keep'); put('/work/cache/sub/nested.tmp','keep')\nif adversarial: put('/work/cache/.hidden.tmp','delete'); P('/work/cache/dir.tmp').mkdir()",
    "assert not P('/work/cache/a.tmp').exists(); assert read('/work/cache/keep.txt') == 'keep'; assert read('/work/cache/sub/nested.tmp') == 'keep'\nif adversarial: assert not P('/work/cache/.hidden.tmp').exists(); assert P('/work/cache/dir.tmp').is_dir()",
    change(t,0,'find',hidden=False),'misses hidden matches',['glob','negative-scope','hidden'])
t=[task('file',path='/work/tree',recurse=True,mode='u=rwX,g=rX,o=rX')]
add('Readable traversable tree','filesystem','For /work/tree and its contents, grant owner read/write and everyone read; grant directory traversal without making initially nonexecutable regular files executable.',
    'set file permissions in /work/tree to read=all, write=owner, list directory=all',t,
    "put('/work/tree/sub/data','data'); os.chmod('/work/tree/sub/data',0o600); os.chmod('/work/tree/sub',0o700)\nif adversarial: put('/work/tree/.hidden','hidden'); os.chmod('/work/tree/.hidden',0o600)",
    "assert mode('/work/tree/sub') == 0o755; assert mode('/work/tree/sub/data') == 0o644\nif adversarial: assert mode('/work/tree/.hidden') == 0o644",
    change(t,0,'file',mode='0755'),'makes data files executable',['permissions','file-vs-directory'])
t=[task('file',src='/work/releases/v2',dest='/work/current',state='link',force=True)]
add('Switch release symlink','filesystem','Point /work/current to /work/releases/v2, replacing an existing symlink to v1, and preserve both release directories.',
    'create symbolic link at /work/current to /work/releases/v2',t,
    "put('/work/releases/v1/data','v1'); put('/work/releases/v2/data','v2')\nif adversarial: os.symlink('/work/releases/v1','/work/current')",
    "assert os.readlink('/work/current') == '/work/releases/v2'; assert read('/work/releases/v1/data') == 'v1'; assert read('/work/current/data') == 'v2'",
    change(t,0,'file',src='/work/releases/v1'),'points at wrong release',['symlink'])
t=[task('file',src='/work/source',dest='/work/alias',state='hard',force=True)]
add('Create hard link','filesystem','Ensure /work/alias is a hard link to /work/source, replacing a stale ordinary file at /work/alias if present.',
    'create hard link at /work/alias to /work/source',t,
    "put('/work/source','payload')\nif adversarial: put('/work/alias','stale')",
    "assert os.stat('/work/source').st_ino == os.stat('/work/alias').st_ino; assert not P('/work/alias').is_symlink()",
    [task('copy',src='/work/source',dest='/work/alias',remote_src=True)],'copies bytes instead of sharing inode',['hardlink'])
t=[task('lineinfile',path='/work/app.conf',regexp='^port=',line='port=8080')]
add('Replace existing directive','configuration','In the existing /work/app.conf, ensure exactly one port=8080 line, replacing its single old port directive if present, and preserve unrelated lines.',
    'write "port=8080" to file at "/work/app.conf"',t,
    "put('/work/app.conf','# keep\\nmode=safe\\n' + ('port=9090\\n' if adversarial else ''))",
    "lines=read('/work/app.conf').splitlines(); assert [x for x in lines if x.startswith('port=')] == ['port=8080']; assert '# keep' in lines and 'mode=safe' in lines",
    change(t,0,'lineinfile',regexp='^port=8080$'),'appends without replacing old directive',['regex','preservation'])
t=[task('lineinfile',path='/work/app.conf',regexp='^legacy=',state='absent')]
add('Remove all legacy directives','configuration','Remove every line beginning legacy= from /work/app.conf while preserving unrelated lines, including commented legacy examples.',
    'delete lines from file at "/work/app.conf" with pattern="^legacy="',t,
    "put('/work/app.conf','mode=safe\\n# legacy=example\\n' + ('legacy=yes\\nlegacy=no\\n' if adversarial else ''))",
    "assert read('/work/app.conf') == 'mode=safe\\n# legacy=example\\n'",
    change(t,0,'lineinfile',regexp='legacy='),'also removes commented example',['regex','negative-scope'])
t=[task('blockinfile',path='/work/app.conf',marker='# {mark} ASTRO',block='alpha=1\nbeta=2')]
add('Update managed block','configuration','Ensure /work/app.conf has an ASTRO-managed block containing alpha=1 and beta=2 on separate lines; replace an old such block and preserve content outside it.',
    'write "alpha=1\nbeta=2" to file at "/work/app.conf" with block=ASTRO',t,
    "put('/work/app.conf','outside=keep\\n' + ('# BEGIN ASTRO\\nalpha=old\\n# END ASTRO\\n' if adversarial else ''))",
    "s=read('/work/app.conf'); assert 'outside=keep\\n' in s; assert s.count('# BEGIN ASTRO') == 1; assert '# BEGIN ASTRO\\nalpha=1\\nbeta=2\\n# END ASTRO' in s; assert 'alpha=old' not in s",
    change(t,0,'blockinfile',marker='# {mark} WRONG'),'leaves old managed block',['block-update'])
t=[task('lineinfile',path='/work/rules',line='allow local',insertbefore='^deny all$')]
add('Insert before terminal rule','configuration','Ensure allow local appears before the deny all line in /work/rules. Preserve other rules. The allow rule is initially absent or already correctly placed.',
    'write "allow local" to file at /work/rules at position=beginning',t,
    "put('/work/rules','allow admin\\n' + ('allow local\\n' if adversarial else '') + 'deny all\\n')",
    "s=read('/work/rules').splitlines(); assert s.count('allow local') == 1; assert s.index('allow local') < s.index('deny all'); assert 'allow admin' in s",
    [task('lineinfile',path='/work/rules',line='allow local',insertafter='EOF')],'inserts after terminal deny',['ordering'])
t=[task('replace',path='/work/app.conf',regexp='(?m)^endpoint=http://',replace='endpoint=https://')]
add('Targeted protocol migration','configuration','Change http:// to https:// only at the start of endpoint= values in /work/app.conf. Preserve comments and other keys.',
    'replace text in file at "/work/app.conf" with pattern="^endpoint=http://", replacement="endpoint=https://"',t,
    "put('/work/app.conf','endpoint=http://one\\n# endpoint=http://example\\nother=http://keep\\n' + ('endpoint=http://two\\n' if adversarial else ''))",
    "s=read('/work/app.conf'); assert 'endpoint=https://one\\n' in s; assert '# endpoint=http://example\\n' in s; assert 'other=http://keep\\n' in s\nif adversarial: assert 'endpoint=https://two\\n' in s",
    change(t,0,'replace',regexp='http://',replace='https://'),'rewrites unrelated URLs',['regex','negative-scope'])

t=[task('group',name='deploy',state='present'),task('user',name='app',group='deploy',create_home=True)]
add('Create group before account','identity','Ensure the deploy group exists and the app user exists with deploy as its primary group and a home directory.',
    'create group with name=deploy; create user with name=app in primary group=deploy',t,
    "if adversarial: run('groupadd','deploy'); run('useradd','-m','app')",
    "u=pwd.getpwnam('app'); assert u.pw_gid == grp.getgrnam('deploy').gr_gid; assert P(u.pw_dir).is_dir()",
    t[1:],'uses missing prerequisite group',['dependency'])
t=[task('user',name='app',groups=['deploy'],append=True)]
add('Append group membership','identity','Add the existing app user to deploy while retaining its existing supplemental group memberships.',
    'set supplemental groups for user=app to deploy with append=true',t,
    "run('groupadd','deploy'); run('groupadd','audit'); run('useradd','-m','app')\nif adversarial: run('usermod','-aG','audit','app')",
    "assert 'app' in grp.getgrnam('deploy').gr_mem\nif adversarial: assert 'app' in grp.getgrnam('audit').gr_mem",
    change(t,0,'user',append=False),'replaces existing memberships',['preservation','supplemental-group'])
t=[task('user',name='app',group='deploy')]
add('Change primary group','identity','Set the existing app user primary group to deploy, preserving its existing home directory and its contents.',
    'create user with name=app in primary group=deploy',t,
    "run('groupadd','deploy'); run('useradd','-m','app'); put('/home/app/keep','keep')\nif adversarial: run('usermod','-g','deploy','app')",
    "assert pwd.getpwnam('app').pw_gid == grp.getgrnam('deploy').gr_gid; assert read('/home/app/keep') == 'keep'",
    [task('user',name='app',groups=['deploy'],append=True)],'changes supplemental instead of primary group',['primary-vs-supplemental'])
t=[task('user',name='app',shell='/bin/bash')]
add('Change login shell','identity','Set the existing app user login shell to /bin/bash without changing its UID or home contents.',
    'set default shell for user=app to bash',t,
    "run('useradd','-m','-u','1501','-s','/bin/sh' if not adversarial else '/usr/sbin/nologin','app'); put('/home/app/keep','keep')",
    "u=pwd.getpwnam('app'); assert u.pw_shell == '/bin/bash'; assert u.pw_uid == 1501; assert read('/home/app/keep') == 'keep'",
    change(t,0,'user',shell='/bin/sh'),'sets wrong shell',['account-attributes'])
t=[task('user',name='retired',state='absent',remove=False)]
add('Delete account retain data','identity','Remove the retired user account, retaining /home/retired and all its contents.',
    'delete user with name=retired',t,
    "run('useradd','-m','retired'); put('/home/retired/keep','valuable')\nif adversarial: put('/home/retired/.hidden','secret')",
    "assert not user_exists('retired'); assert read('/home/retired/keep') == 'valuable'\nif adversarial: assert read('/home/retired/.hidden') == 'secret'",
    change(t,0,'user',remove=True),'removes retained home',['deletion','preservation'])
t=[task('user',name='retired',state='absent',remove=True)]
add('Delete account and home','identity','Remove the retired user and its home directory /home/retired while preserving /home/active.',
    'delete user with name=retired; delete directory at /home/retired',t,
    "run('useradd','-m','retired'); put('/home/retired/old','old'); put('/home/active/keep','keep')\nif adversarial: put('/home/retired/.hidden','old')",
    "assert not user_exists('retired'); assert not P('/home/retired').exists(); assert read('/home/active/keep') == 'keep'",
    change(t,0,'user',remove=False),'leaves retired home',['deletion','scope'])
t=[task('user',name='app',password_lock=True)]
add('Lock existing password','identity','Lock password authentication for the existing app user without replacing its stored password hash; retain the account.',
    'disable password for user=app',t,
    "run('useradd','-m','app'); run('usermod','-p',('!' if adversarial else '')+'$6$salt$hash','app')",
    "assert user_exists('app'); shadow=next(x.split(':')[1] for x in read('/etc/shadow').splitlines() if x.startswith('app:')); assert shadow.startswith('!'); assert shadow.lstrip('!') == '$6$salt$hash'",
    [task('user',name='app',password='!')],'destroys stored hash',['preservation','password-lock'])
t=[task('file',path='/home/app',state='directory',owner='app',group='app',mode='0700')]
add('Secure existing home','identity','Ensure /home/app is owned by app:app and has mode 0700, without deleting its contents.',
    'create directory at /home/app with owner=app, group=app, read=owner, write=owner, list directory=owner',t,
    "run('useradd','-m','app'); put('/home/app/keep','keep'); os.chmod('/home/app',0o755)\nif adversarial: os.chown('/home/app',0,0)",
    "s=os.stat('/home/app'); assert s.st_uid == pwd.getpwnam('app').pw_uid; assert s.st_gid == grp.getgrnam('app').gr_gid; assert mode('/home/app') == 0o700; assert read('/home/app/keep') == 'keep'",
    change(t,0,'file',owner='root',group='root'),'leaves root ownership',['ownership','permissions'])

t=[task('apt',deb='/fixtures/astro-demo_1.0_all.deb')]
add('Install offline package','packages','On this Debian host, install astro-demo version 1.0 from /fixtures/astro-demo_1.0_all.deb. The package may already be installed.',
    'if os is Debian then install astro-demo with version="1.0"',t,
    "if adversarial: run('dpkg','-i','/fixtures/astro-demo_1.0_all.deb')",
    "assert package_version('astro-demo') == '1.0'; assert read('/usr/share/astro-demo/version') == '1.0'",
    [task('debug',msg='done')],'claims installation without installing',['offline','package-state'])
t=[task('apt',name='astro-demo',state='absent',purge=True)]
add('Remove installed package','packages','Remove astro-demo from this Debian host if installed; leave astro-keep installed.',
    'if os is Debian then uninstall astro-demo',t,
    "run('dpkg','-i','/fixtures/astro-keep_1.0_all.deb')\nif adversarial: run('dpkg','-i','/fixtures/astro-demo_1.0_all.deb')",
    "assert package_version('astro-demo') is None; assert package_version('astro-keep') == '1.0'",
    [task('debug',msg='done')],'leaves installed package',['package-state','negative-scope'])
t=[task('apt',deb='/fixtures/astro-demo_2.0_all.deb')]
add('Upgrade to exact package version','packages','Ensure astro-demo version 2.0 is installed from /fixtures/astro-demo_2.0_all.deb, upgrading version 1.0 if necessary.',
    'if os is Debian then install astro-demo with version="2.0"',t,
    "run('dpkg','-i','/fixtures/astro-demo_'+('1.0' if adversarial else '2.0')+'_all.deb')",
    "assert package_version('astro-demo') == '2.0'; assert read('/usr/share/astro-demo/version') == '2.0'",
    [task('apt',name='astro-demo',state='present')],'accepts stale installed version',['version'])
t=[task('dpkg_selections',name='astro-demo',selection='hold')]
add('Hold installed package','packages','Mark the installed astro-demo Debian package as held, preserving version 1.0.',
    'set package selection for astro-demo to hold',t,
    "run('dpkg','-i','/fixtures/astro-demo_1.0_all.deb')\nif adversarial: run('apt-mark','hold','astro-demo')",
    "assert 'astro-demo' in output('apt-mark','showhold').splitlines(); assert package_version('astro-demo') == '1.0'",
    [task('apt',name='astro-demo',state='present')],'installed does not imply held',['package-policy'])

git_setup="git_fixture()\nif adversarial: run('git','clone','-b','main','/fixtures/repo','/work/checkout')"
t=[task('git',repo='/fixtures/repo',dest='/work/checkout',version='release',update=True)]
add('Checkout release branch','version-control','Clone /fixtures/repo into /work/checkout and check out its release branch; update an existing checkout from main if present.',
    'clone git repository from /fixtures/repo with branch=release into /work/checkout',t,git_setup,
    "assert read('/work/checkout/version') == 'release'; assert output('git','-C','/work/checkout','rev-parse','HEAD').strip() == output('git','-C','/fixtures/repo','rev-parse','release').strip()",
    change(t,0,'git',version='main'),'wrong branch',['version','existing-checkout'])
t=[task('git',repo='/fixtures/repo',dest='/work/checkout',version='main',update=False)]
add('Preserve existing checkout','version-control','Clone main from /fixtures/repo to /work/checkout if absent. If a checkout already exists, preserve its current commit even if main has advanced.',
    'if directory /work/checkout not exists then clone git repository from /fixtures/repo with branch=main into /work/checkout',t,
    "git_fixture()\nif adversarial:\n run('git','clone','-b','main','/fixtures/repo','/work/checkout'); put('/fixtures/repo/version','new-main'); run('git','-C','/fixtures/repo','commit','-am','advance')",
    "assert read('/work/checkout/version') == 'main'",
    change(t,0,'git',update=True),'updates checkout that should be preserved',['conditional','preservation'])
t=[task('git',repo='/fixtures/repo',dest='/work/checkout',version='v1',update=True)]
add('Pin deployment tag','version-control','Ensure /work/checkout is checked out at tag v1 from /fixtures/repo, even when an existing checkout follows main.',
    'clone git repository from /fixtures/repo with tag=v1 into /work/checkout',t,git_setup,
    "assert output('git','-C','/work/checkout','rev-parse','HEAD').strip() == output('git','-C','/fixtures/repo','rev-parse','v1').strip(); assert read('/work/checkout/version') == 'tag-v1'",
    change(t,0,'git',version='main'),'tracks branch instead of pinning tag',['version'])

t=[task('service',name='cron',state='started')]
add('Start existing service','services','Ensure the installed cron service is running. It may initially be stopped or already running.',
    'start cron service',t,
    "if adversarial: run('/etc/init.d/cron','start')",
    "assert subprocess.run(['pgrep','-x','cron'],capture_output=True).returncode == 0",
    [task('service',name='cron',enabled=True)],'enables boot startup without starting',['running-vs-enabled'])
t=[task('service',name='cron',state='stopped')]
add('Stop existing service','services','Ensure cron is stopped, including when it is initially running.',
    'stop cron service',t,
    "if adversarial: run('/etc/init.d/cron','start')",
    "assert subprocess.run(['pgrep','-x','cron'],capture_output=True).returncode != 0",
    [task('service',name='cron',enabled=False)],'disables boot startup without stopping',['running-vs-enabled'])
t=[task('service',name='cron',enabled=True)]
add('Enable boot startup only','services','Enable cron at boot without starting it now. It is initially stopped, and may already be enabled.',
    'enable cron service',t,
    "run('update-rc.d','cron','defaults')\nif not adversarial: run('update-rc.d','cron','disable')",
    "assert list(P('/etc/rc2.d').glob('S*cron')); assert subprocess.run(['pgrep','-x','cron'],capture_output=True).returncode != 0",
    [task('service',name='cron',state='started',enabled=True)],'unexpectedly starts service',['negative-action','boot-policy'])
t=[task('cron',name='astro cleanup',minute='15',hour='2',user='root',job='/usr/bin/true')]
add('Update scheduled job','scheduling','Ensure root has one Ansible-named astro cleanup cron job running /usr/bin/true daily at 02:15; preserve unrelated jobs and update a stale astro cleanup entry.',
    'create cron job with name="astro cleanup", minute="15", hour="2", command="/usr/bin/true"',t,
    "s='0 0 * * * /bin/echo keep\\n' + ('#Ansible: astro cleanup\\n0 1 * * * /bin/false\\n' if adversarial else ''); subprocess.run(['crontab','-'],input=s,text=True,check=True)",
    "s=output('crontab','-l'); assert s.count('#Ansible: astro cleanup') == 1; assert '15 2 * * * /usr/bin/true' in s; assert '0 0 * * * /bin/echo keep' in s; assert '/bin/false' not in s",
    change(t,0,'cron',minute='0',hour='15'),'swaps schedule fields',['schedule','preservation'])
t=[task('file',path='/work/unpacked',state='directory'),task('unarchive',src='/fixtures/bundle.tar',dest='/work/unpacked',remote_src=True)]
add('Extract remote artifact','archives','Extract the remote /fixtures/bundle.tar into /work/unpacked, creating that directory if absent and preserving unrelated existing files.',
    'create directory at /work/unpacked; extract archive from remote "/fixtures/bundle.tar" to /work/unpacked',t,
    "archive_fixture()\nif adversarial: put('/work/unpacked/keep','keep')",
    "assert read('/work/unpacked/app/data') == 'artifact'\nif adversarial: assert read('/work/unpacked/keep') == 'keep'",
    [t[0]],'creates directory without extracting',['dependency','archive'])
t=[task('file',path='/work/unpacked',state='directory'),task('unarchive',src='/fixtures/bundle.tar',dest='/work/unpacked',remote_src=True,creates='/work/unpacked/app/data')]
add('Skip initialized extraction','archives','Extract /fixtures/bundle.tar into /work/unpacked only when /work/unpacked/app/data is absent. Preserve customized data when that file exists.',
    'if file "/work/unpacked/app/data" not exists then extract archive from remote "/fixtures/bundle.tar" to /work/unpacked',t,
    "archive_fixture()\nif adversarial: put('/work/unpacked/app/data','customized')",
    "assert read('/work/unpacked/app/data') == ('customized' if adversarial else 'artifact')",
    [t[0],task('unarchive',src='/fixtures/bundle.tar',dest='/work/unpacked',remote_src=True)],'overwrites customized extraction',['conditional','preservation'])


t=[task('group',name='analytics',state='present')]
add('Ensure shared group exists','identity','Ensure the analytics group exists, preserving its GID if it already exists.',
    'create group with name=analytics',t,
    "if adversarial: run('groupadd','-g','1601','analytics')",
    "g=grp.getgrnam('analytics')\nif adversarial: assert g.gr_gid == 1601",
    [task('group',name='analytics',state='present',gid=1602)],'changes existing group identity',['identity-preservation'])
t=[task('group',name='obsolete',state='absent')]
add('Remove unused group','identity','Remove the unused obsolete group if it exists, preserving the active group and its GID.',
    'delete group with name=obsolete',t,
    "run('groupadd','-g','1601','active')\nif adversarial: run('groupadd','obsolete')",
    "assert 'obsolete' not in [g.gr_name for g in grp.getgrall()]; assert grp.getgrnam('active').gr_gid == 1601",
    [task('group',name='active',state='absent')],'removes wrong group',['negative-scope'])
t=[task('user',name='app',group='primary',groups=['deploy','audit'],append=True)]
add('Provision multiple memberships','identity','Ensure app exists with primary group primary and membership in both deploy and audit. All three groups already exist.',
    'create user with name=app in primary group=primary, supplemental groups=deploy audit',t,
    "run('groupadd','primary'); run('groupadd','deploy'); run('groupadd','audit')\nif adversarial: run('useradd','-m','-g','primary','-G','deploy','app')",
    "assert pwd.getpwnam('app').pw_gid == grp.getgrnam('primary').gr_gid; assert 'app' in grp.getgrnam('deploy').gr_mem; assert 'app' in grp.getgrnam('audit').gr_mem",
    change(t,0,'user',groups=['deploy']),'omits one required membership',['multiple-obligations'])
t=[task('file',path='/work/data',state='directory',owner='app',group='app',recurse=False)]
add('Change directory owner only','filesystem','Make /work/data owned by app:app, preserving the ownership and bytes of files inside it. The directory and app account already exist.',
    'create directory at /work/data with owner=app, group=app',t,
    "run('useradd','-m','app'); put('/work/data/keep','keep')\nif adversarial: os.chown('/work/data',pwd.getpwnam('app').pw_uid,grp.getgrnam('app').gr_gid)",
    "s=os.stat('/work/data'); assert s.st_uid == pwd.getpwnam('app').pw_uid; assert s.st_gid == grp.getgrnam('app').gr_gid; assert os.stat('/work/data/keep').st_uid == 0; assert read('/work/data/keep') == 'keep'",
    change(t,0,'file',recurse=True),'recursively changes child ownership',['negative-scope','ownership'])
t=[task('lineinfile',path='/work/profile',line='export ASTRO=1',insertafter='EOF')]
add('Append profile setting','configuration','Ensure export ASTRO=1 is the last line of /work/profile, preserving existing lines. The setting is initially absent or already last.',
    'write "export ASTRO=1" to /work/profile at position=end',t,
    "put('/work/profile','# keep\\nexport KEEP=1\\n' + ('export ASTRO=1\\n' if adversarial else ''))",
    "s=read('/work/profile').splitlines(); assert s[-1] == 'export ASTRO=1'; assert s.count('export ASTRO=1') == 1; assert '# keep' in s and 'export KEEP=1' in s",
    change(t,0,'lineinfile',insertafter=None,insertbefore='BOF'),'prepends instead of appending',['ordering','preservation'])
t=[task('lineinfile',path='/work/header',line='# managed',insertbefore='BOF')]
add('Prepend managed header','configuration','Ensure # managed is the first line of /work/header, retaining all original body lines. The header is initially absent or already first.',
    'write "# managed" to /work/header at position=start',t,
    "put('/work/header',('# managed\\n' if adversarial else '')+'body one\\nbody two\\n')",
    "s=read('/work/header').splitlines(); assert s[0] == '# managed'; assert s.count('# managed') == 1; assert s[1:] == ['body one','body two']",
    [task('lineinfile',path='/work/header',line='# managed',insertafter='EOF')],'appends header',['ordering','preservation'])
t=[task('file',path='/work/run.sh',mode='0700')]
add('Private executable mode','filesystem','Give the existing /work/run.sh mode 0700, retaining its bytes and leaving /work/data mode 0644.',
    'set file permissions for "/work/run.sh" to read=owner, write=owner, execute=owner',t,
    "put('/work/run.sh','#!/bin/sh\\nexit 0\\n'); put('/work/data','keep'); os.chmod('/work/data',0o644); os.chmod('/work/run.sh',0o777 if adversarial else 0o600)",
    "assert mode('/work/run.sh') == 0o700; assert read('/work/run.sh') == '#!/bin/sh\\nexit 0\\n'; assert mode('/work/data') == 0o644",
    change(t,0,'file',mode='0600'),'omits execute permission',['execute-permission','negative-scope'])
t=[dict(task('stat',path='/work/enabled'),register='enabled'),dict(task('file',path='/work/cache',state='directory'),when='enabled.stat.exists')]
add('Gate directory creation on marker','filesystem','Create /work/cache only if the marker file /work/enabled exists. The cache is initially absent and must remain absent without the marker.',
    'if file /work/enabled exists then create directory at /work/cache',t,
    "if adversarial: put('/work/enabled','yes')",
    "assert P('/work/cache').is_dir() == adversarial",
    [task('file',path='/work/cache',state='directory')],'acts when condition is false',['conditional','negative-action'])
t=[dict(task('stat',path='/work/maintenance'),register='maintenance'),task('copy',dest='/work/status',content="{{ 'offline' if maintenance.stat.exists else 'online' }}")]
add('Explicit two-branch status','configuration','Write offline to /work/status when /work/maintenance exists; otherwise write online. Do not append a newline.',
    'if file /work/maintenance exists then create file at /work/status with content="offline" otherwise create file at /work/status with content="online"',t,
    "put('/work/status','stale')\nif adversarial: put('/work/maintenance','yes')",
    "assert read('/work/status') == ('offline' if adversarial else 'online')",
    change(t,1,'copy',content='online'),'ignores true branch',['otherwise','conditional'])
t=[task('copy',src='/work/source/',dest='/work/dest/',remote_src=True)]
add('Copy directory contents not wrapper','filesystem','Copy the contents of remote /work/source into /work/dest, preserving hidden files, nested structure, the source, and unrelated destination files. Both directories exist.',
    'copy directory from remote /work/source to remote /work/dest',t,
    "put('/work/source/.hidden','hidden'); put('/work/source/nested/data','data'); P('/work/dest').mkdir()\nif adversarial: put('/work/dest/keep','keep')",
    "assert read('/work/dest/.hidden') == 'hidden'; assert read('/work/dest/nested/data') == 'data'; assert read('/work/source/nested/data') == 'data'; assert not P('/work/dest/source').exists()\nif adversarial: assert read('/work/dest/keep') == 'keep'",
    change(t,0,'copy',src='/work/source'),'copies enclosing directory instead of contents',['directory-layout','hidden','preservation'])


def play(tasks):
    return [dict(name='Benchmark candidate',hosts='all',gather_facts=False,tasks=tasks)]


def main():
    assert len(TASKS) == 49
    for t in TASKS:
        d=ROOT/'benchmarks/expanded'/t['id']; d.mkdir(parents=True,exist_ok=True)
        for name,ts in [('reference',t['tasks']),('mutant',t['mutant'])]:
            (d/f'{name}.yml').write_text(yaml.safe_dump(play(ts),sort_keys=False))
        (d/'query.fql').write_text(t['formal_query']+'\n')
        (d/'setup.py').write_text(t['setup']+'\n')
        (d/'check.py').write_text(t['checks']+'\n')
        (d/'task.json').write_text(json.dumps({k:v for k,v in t.items() if k not in ['tasks','mutant','setup','checks']},indent=2)+'\n')
    (ROOT/'benchmarks/expanded.json').write_text(json.dumps([{k:v for k,v in t.items() if k not in ['tasks','mutant','setup','checks']} for t in TASKS],indent=2)+'\n')
    print(f'Wrote {len(TASKS)} task packages, each with reference, semantic mutant, two scenarios, and an independent state oracle.')


if __name__=='__main__': main()
