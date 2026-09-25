# Traced paired-decision changes across21 tasks

These transitions show downstream consequences of generated specifications. They do not establish which decision is correct. Full raw diagnostics, normalized effect proxies, candidate programs, and residual branches are in `all-traces.json`.

## compact-all: a03, gpt-4o/p15/0

gpt6, r0: `accepted_with_possible_residuals` → `verification_rejected`.

Delete the contents of the /home/mydata/web directory

Supplied query:
```
delete files in /home/mydata/web
```
Generated query:
```
delete contents of directory at /home/mydata/web
```
Diagnostic/verifier excerpt:
```
FAILED TO VERIFY
```

## compact-all: a03, deepseek/p15/0

gpt6, r0: `verification_rejected` → `accepted_with_possible_residuals`.

Delete the contents of the /home/mydata/web directory

Supplied query:
```
delete files in /home/mydata/web
```
Generated query:
```
delete contents of directory at /home/mydata/web
```
Diagnostic/verifier excerpt:
```
VERIFIED
< #local(()), env(()): <last_reboot = -1, os_distribution = "RedHat", os_family = "RedHat", time_counter = 0 >, fs(('/home/mydata/web', file_system::remote(()))): <fs_type = file_type::directory(∀15) > > { 1 branch } assuming < env(()) : < hostname = [ 0: ∀43 ] > > and can_become(("#local_user", "root")) = [ 0 : true ] performing <>
< #local(()), env(()): <last_reboot = -1, os_distribution = "Debian", os_family = "Debian", time_counter = 0 >, fs(('/home/mydata/web', file_system::remote(()))): <fs_type = file_type::directory(∀24) > > { 1 branch } assuming < env(()) : < hostname = [ 0: ∀43 ] > > and can_become(("#local_user", "root")) = [ 0 : true ] performing <>
< #local(()), env(()): <last_reboot = -1, os_distribution = "Ubuntu", os_family = "Debian", time_counter = 0 >, fs(('/home/mydata/web', file_system::remote(()))): <fs_type = file_type::directory(∀33) > > { 1 branch } assuming < env(()) : < hostname = [ 0: ∀43 ] > > and can_become(("#local_user", "root")) = [ 0 : true ] performing <>
```

## compact-all: a03, gpt-4o/p15/0

opus55, r0: `accepted_with_possible_residuals` → `query_semantic_error`.

Delete the contents of the /home/mydata/web directory

Supplied query:
```
delete files in /home/mydata/web
```
Generated query:
```
delete directory contents at /home/mydata/web
```
Diagnostic/verifier excerpt:
```
parse	ok	0793c686675a2c59e49e6d2a47085e90
semantic	error	Unhandled deletion of: directory contents
```

## compact-all: a03, gpt-4o/p15/8

opus55, r0: `ansible_lowering_error` → `query_semantic_error`.

Delete the contents of the /home/mydata/web directory

Supplied query:
```
delete files in /home/mydata/web
```
Generated query:
```
delete directory contents at /home/mydata/web
```
Diagnostic/verifier excerpt:
```
parse	ok	0793c686675a2c59e49e6d2a47085e90
semantic	error	Unhandled deletion of: directory contents
```

## compact-all: a03, deepseek/p15/0

opus55, r0: `verification_rejected` → `query_semantic_error`.

Delete the contents of the /home/mydata/web directory

Supplied query:
```
delete files in /home/mydata/web
```
Generated query:
```
delete directory contents at /home/mydata/web
```
Diagnostic/verifier excerpt:
```
parse	ok	0793c686675a2c59e49e6d2a47085e90
semantic	error	Unhandled deletion of: directory contents
```

## compact-all: a09, granite/p07/5

gpt6, r2: `accepted_with_possible_residuals` → `verification_rejected`.

Clone the release1.8.4 branch from the ansible/ansible github repo to /ansible using https

Supplied query:
```
clone github repository with name=ansible/ansible, branch="release1.8.4" into /ansible via https
```
Generated query:
```
clone git repository from "https://github.com/ansible/ansible.git" with branch="release1.8.4" into /ansible
```
Diagnostic/verifier excerpt:
```
FAILED TO VERIFY
```

## compact-all: a10, deepseek/p02/3

gpt6, r1: `accepted_with_possible_residuals` → `query_semantic_error`.

Permanently set the environment variable LC_ALL to ``C'' system-wide

Supplied query:
```
set environment variable LC_ALL to "C"
```
Generated query:
```
set system-wide environment variable LC_ALL to C with permanent=true
```
Diagnostic/verifier excerpt:
```
parse	ok	5263597c000c9b16d2f245c76b1d641e
semantic	error	Unhandled set of: system-wide environment variable LC_ALL
```

## compact-all: a10, deepseek/p02/2

gpt6, r1: `ansible_lowering_error` → `query_semantic_error`.

Permanently set the environment variable LC_ALL to ``C'' system-wide

Supplied query:
```
set environment variable LC_ALL to "C"
```
Generated query:
```
set system-wide environment variable LC_ALL to C with permanent=true
```
Diagnostic/verifier excerpt:
```
parse	ok	5263597c000c9b16d2f245c76b1d641e
semantic	error	Unhandled set of: system-wide environment variable LC_ALL
```

## compact-all: a10, deepseek/p02/0

gpt6, r1: `verification_rejected` → `query_semantic_error`.

Permanently set the environment variable LC_ALL to ``C'' system-wide

Supplied query:
```
set environment variable LC_ALL to "C"
```
Generated query:
```
set system-wide environment variable LC_ALL to C with permanent=true
```
Diagnostic/verifier excerpt:
```
parse	ok	5263597c000c9b16d2f245c76b1d641e
semantic	error	Unhandled set of: system-wide environment variable LC_ALL
```

## compact-all: a11, deepseek/p09/2

gpt6, r0: `accepted_with_possible_residuals` → `query_semantic_error`.

Add the line `module load gcc' to the end of foo's bashrc

Supplied query:
```
write "module load gcc" to bashrc file for user = foo at position=end
```
Generated query:
```
write "module load gcc" to bashrc for user="foo" at position=end
```
Diagnostic/verifier excerpt:
```
parse	ok	109e04f6d828bb67ab7a54d4cfdb30ef
semantic	error	Unhandled arguments for write: user = foo
```

## compact-all: a11, deepseek/p09/0

gpt6, r0: `ansible_lowering_error` → `query_semantic_error`.

Add the line `module load gcc' to the end of foo's bashrc

Supplied query:
```
write "module load gcc" to bashrc file for user = foo at position=end
```
Generated query:
```
write "module load gcc" to bashrc for user="foo" at position=end
```
Diagnostic/verifier excerpt:
```
parse	ok	109e04f6d828bb67ab7a54d4cfdb30ef
semantic	error	Unhandled arguments for write: user = foo
```

## compact-all: a11, deepseek/p09/1

gpt6, r0: `verification_rejected` → `query_semantic_error`.

Add the line `module load gcc' to the end of foo's bashrc

Supplied query:
```
write "module load gcc" to bashrc file for user = foo at position=end
```
Generated query:
```
write "module load gcc" to bashrc for user="foo" at position=end
```
Diagnostic/verifier excerpt:
```
parse	ok	109e04f6d828bb67ab7a54d4cfdb30ef
semantic	error	Unhandled arguments for write: user = foo
```

## compact-all: a12, gpt-4o/p14/0

opus55, r1: `accepted_with_possible_residuals` → `query_parse_error`.

For Debian, restart the system if it is needed

Supplied query:
```
if os is Debian and reboot required then reboot
```
Generated query:
```
if os is Debian then reboot system if required
```
Diagnostic/verifier excerpt:
```
exception	error	Stdlib.Parsing.Parse_error
```

## compact-all: a12, deepseek/p14/0

opus55, r1: `ansible_lowering_error` → `query_parse_error`.

For Debian, restart the system if it is needed

Supplied query:
```
if os is Debian and reboot required then reboot
```
Generated query:
```
if os is Debian then reboot system if required
```
Diagnostic/verifier excerpt:
```
exception	error	Stdlib.Parsing.Parse_error
```

## compact-all: a12, deepseek/p14/5

opus55, r1: `verification_rejected` → `query_parse_error`.

For Debian, restart the system if it is needed

Supplied query:
```
if os is Debian and reboot required then reboot
```
Generated query:
```
if os is Debian then reboot system if required
```
Diagnostic/verifier excerpt:
```
exception	error	Stdlib.Parsing.Parse_error
```

## compact-all: a14, deepseek/p06/0

gpt6, r0: `ansible_lowering_error` → `query_semantic_error`.

Create a Python 3.10 virtual environment at /user/home/venv and install numpy in it

Supplied query:
```
create virtual environment with python="3.10" in /user/home/venv; install numpy in virtual environment at /user/home/venv
```
Generated query:
```
create Python virtual environment at /user/home/venv with version="3.10"; install numpy in /user/home/venv
```
Diagnostic/verifier excerpt:
```
parse	ok	eb676325826f9194ddf8542f258fee11
semantic	error	Unhandled environment type for create: Python virtual
```

## compact-all: a14, gpt-4o/p06/8

gpt6, r0: `verification_rejected` → `query_semantic_error`.

Create a Python 3.10 virtual environment at /user/home/venv and install numpy in it

Supplied query:
```
create virtual environment with python="3.10" in /user/home/venv; install numpy in virtual environment at /user/home/venv
```
Generated query:
```
create Python virtual environment at /user/home/venv with version="3.10"; install numpy in /user/home/venv
```
Diagnostic/verifier excerpt:
```
parse	ok	eb676325826f9194ddf8542f258fee11
semantic	error	Unhandled environment type for create: Python virtual
```

## compact-all: a16, deepseek/p16/1

gpt6, r0: `accepted_with_possible_residuals` → `query_semantic_error`.

Install zsh, set it as the user `dev''s default shell, and ensure its configuration file exists

Supplied query:
```
install zsh; set default shell for user="dev" to zsh; if zsh configuration file for user="dev" not exists then create zsh configuration file for user="dev"
```
Generated query:
```
install zsh; set default shell for user=dev to zsh; if zsh configuration file not exists then create zsh configuration file
```
Diagnostic/verifier excerpt:
```
parse	ok	ec3f36bd49be8c0d5c019c6d70761341
semantic	error	Must specify 'user' for zsh configuration file
```

## compact-all: a16, deepseek/p16/0

gpt6, r0: `ansible_lowering_error` → `query_semantic_error`.

Install zsh, set it as the user `dev''s default shell, and ensure its configuration file exists

Supplied query:
```
install zsh; set default shell for user="dev" to zsh; if zsh configuration file for user="dev" not exists then create zsh configuration file for user="dev"
```
Generated query:
```
install zsh; set default shell for user=dev to zsh; if zsh configuration file not exists then create zsh configuration file
```
Diagnostic/verifier excerpt:
```
parse	ok	ec3f36bd49be8c0d5c019c6d70761341
semantic	error	Must specify 'user' for zsh configuration file
```

## compact-all: a16, deepseek/p16/2

gpt6, r0: `verification_rejected` → `query_semantic_error`.

Install zsh, set it as the user `dev''s default shell, and ensure its configuration file exists

Supplied query:
```
install zsh; set default shell for user="dev" to zsh; if zsh configuration file for user="dev" not exists then create zsh configuration file for user="dev"
```
Generated query:
```
install zsh; set default shell for user=dev to zsh; if zsh configuration file not exists then create zsh configuration file
```
Diagnostic/verifier excerpt:
```
parse	ok	ec3f36bd49be8c0d5c019c6d70761341
semantic	error	Must specify 'user' for zsh configuration file
```

## compact-all: a18, deepseek/p17/1

gpt6, r1: `ansible_lowering_error` → `query_semantic_error`.

For RedHat and Ubuntu, install the lastest version of postfix, backup its default configuration file, and download the configuration file from http://example.com/cfg.ubuntu for Ubuntu and http://example.com/cfg.redhat for RedHat

Supplied query:
```
if os is RedHat or os is Ubuntu then install postfix with version=latest; copy postfix configuration file to ?backup. if os is Ubuntu then download postfix configuration file from "http://example.com/cfg.ubuntu". if os is "RedHat" then download postfix configuration file from "http://example.com/cfg.redhat"
```
Generated query:
```
if os is RedHat or os is Ubuntu then install postfix with version=latest; copy postfix default configuration file to backup. if os is Ubuntu then download postfix configuration file from "http://example.com/cfg.ubuntu". if os is RedHat then download postfix configuration file from "http://example.com/cfg.redhat"
```
Diagnostic/verifier excerpt:
```
parse	ok	5a022153d6d103f02cc746ccdb680c6a
semantic	error	Unknown file: postfix default configuration
```

## compact-all: a18, deepseek/p17/0

gpt6, r1: `verification_rejected` → `query_semantic_error`.

For RedHat and Ubuntu, install the lastest version of postfix, backup its default configuration file, and download the configuration file from http://example.com/cfg.ubuntu for Ubuntu and http://example.com/cfg.redhat for RedHat

Supplied query:
```
if os is RedHat or os is Ubuntu then install postfix with version=latest; copy postfix configuration file to ?backup. if os is Ubuntu then download postfix configuration file from "http://example.com/cfg.ubuntu". if os is "RedHat" then download postfix configuration file from "http://example.com/cfg.redhat"
```
Generated query:
```
if os is RedHat or os is Ubuntu then install postfix with version=latest; copy postfix default configuration file to backup. if os is Ubuntu then download postfix configuration file from "http://example.com/cfg.ubuntu". if os is RedHat then download postfix configuration file from "http://example.com/cfg.redhat"
```
Diagnostic/verifier excerpt:
```
parse	ok	5a022153d6d103f02cc746ccdb680c6a
semantic	error	Unknown file: postfix default configuration
```

## compact-all: a19, deepseek/p18/0

opus55, r2: `accepted_with_possible_residuals` → `query_semantic_error`.

For RedHat, install apache server, ensure the home page exists, and create a `webdev' user

Supplied query:
```
if os is RedHat then install apache server; create user with name=webdev; if apache server html home page file not exists then create apache server html home page file
```
Generated query:
```
if os is RedHat then install apache server; create apache server home page; create user with name=webdev
```
Diagnostic/verifier excerpt:
```
parse	ok	03e8bc508e8c0af7df61f9d1e77020dc
semantic	error	Unhandled creation of: apache server home page
```

## compact-all: a19, deepseek/p18/5

opus55, r2: `ansible_lowering_error` → `query_semantic_error`.

For RedHat, install apache server, ensure the home page exists, and create a `webdev' user

Supplied query:
```
if os is RedHat then install apache server; create user with name=webdev; if apache server html home page file not exists then create apache server html home page file
```
Generated query:
```
if os is RedHat then install apache server; create apache server home page; create user with name=webdev
```
Diagnostic/verifier excerpt:
```
parse	ok	03e8bc508e8c0af7df61f9d1e77020dc
semantic	error	Unhandled creation of: apache server home page
```

## compact-all: a19, deepseek/p18/1

opus55, r2: `verification_rejected` → `query_semantic_error`.

For RedHat, install apache server, ensure the home page exists, and create a `webdev' user

Supplied query:
```
if os is RedHat then install apache server; create user with name=webdev; if apache server html home page file not exists then create apache server html home page file
```
Generated query:
```
if os is RedHat then install apache server; create apache server home page; create user with name=webdev
```
Diagnostic/verifier excerpt:
```
parse	ok	03e8bc508e8c0af7df61f9d1e77020dc
semantic	error	Unhandled creation of: apache server home page
```

## compact-all: a20, starcoder/p19/9

gpt6, r2: `accepted_with_possible_residuals` → `query_semantic_error`.

Enable passwordless sudo for a `wheel' group and create an `ansible' user in that group

Supplied query:
```
enable passwordless sudo for group=wheel; create user with name=ansible in supplemental groups=wheel
```
Generated query:
```
enable passwordless sudo for group with name=wheel; create user with name=ansible in group=wheel
```
Diagnostic/verifier excerpt:
```
parse	ok	de890629a5a35757f8cf5b1767ccf720
semantic	error	Expected exactly one of 'user' and 'group' arguments for enable sudo
```

## compact-all: a20, deepseek/p19/8

gpt6, r2: `ansible_lowering_error` → `query_semantic_error`.

Enable passwordless sudo for a `wheel' group and create an `ansible' user in that group

Supplied query:
```
enable passwordless sudo for group=wheel; create user with name=ansible in supplemental groups=wheel
```
Generated query:
```
enable passwordless sudo for group with name=wheel; create user with name=ansible in group=wheel
```
Diagnostic/verifier excerpt:
```
parse	ok	de890629a5a35757f8cf5b1767ccf720
semantic	error	Expected exactly one of 'user' and 'group' arguments for enable sudo
```

## compact-all: a20, deepseek/p19/0

gpt6, r2: `verification_rejected` → `query_semantic_error`.

Enable passwordless sudo for a `wheel' group and create an `ansible' user in that group

Supplied query:
```
enable passwordless sudo for group=wheel; create user with name=ansible in supplemental groups=wheel
```
Generated query:
```
enable passwordless sudo for group with name=wheel; create user with name=ansible in group=wheel
```
Diagnostic/verifier excerpt:
```
parse	ok	de890629a5a35757f8cf5b1767ccf720
semantic	error	Expected exactly one of 'user' and 'group' arguments for enable sudo
```

## compact-all: a21, deepseek/p20/1

gpt6, r1: `ansible_lowering_error` → `query_semantic_error`.

For Debian and RedHat, install and start an ssh client and server and generated an ssh key for `fizbaz' at /.ssh/fizbaz_rsa

Supplied query:
```
if os is Debian or os is RedHat then install ssh client; install ssh server; start ssh server service; create ssh key for user="fizbaz", name="fizbaz_rsa"
```
Generated query:
```
if os is Debian or os is RedHat then install ssh client and server; start ssh client and server; create ssh key for fizbaz at "/.ssh/fizbaz_rsa"
```
Diagnostic/verifier excerpt:
```
parse	ok	cc9734418934fd1301f4c744560d9df1
semantic	error	Unknown package: ssh client and server
```

## compact-all: a21, deepseek/p20/0

gpt6, r1: `verification_rejected` → `query_semantic_error`.

For Debian and RedHat, install and start an ssh client and server and generated an ssh key for `fizbaz' at /.ssh/fizbaz_rsa

Supplied query:
```
if os is Debian or os is RedHat then install ssh client; install ssh server; start ssh server service; create ssh key for user="fizbaz", name="fizbaz_rsa"
```
Generated query:
```
if os is Debian or os is RedHat then install ssh client and server; start ssh client and server; create ssh key for fizbaz at "/.ssh/fizbaz_rsa"
```
Diagnostic/verifier excerpt:
```
parse	ok	cc9734418934fd1301f4c744560d9df1
semantic	error	Unknown package: ssh client and server
```

## handbook-all: a18, deepseek/p17/1

opus55, r2: `ansible_lowering_error` → `query_semantic_error`.

For RedHat and Ubuntu, install the lastest version of postfix, backup its default configuration file, and download the configuration file from http://example.com/cfg.ubuntu for Ubuntu and http://example.com/cfg.redhat for RedHat

Supplied query:
```
if os is RedHat or os is Ubuntu then install postfix with version=latest; copy postfix configuration file to ?backup. if os is Ubuntu then download postfix configuration file from "http://example.com/cfg.ubuntu". if os is "RedHat" then download postfix configuration file from "http://example.com/cfg.redhat"
```
Generated query:
```
if os is RedHat or os is Ubuntu then install postfix with version="latest"; copy postfix configuration file to ?backup; if os is Ubuntu then download file from "http://example.com/cfg.ubuntu" to postfix configuration file otherwise download file from "http://example.com/cfg.redhat" to postfix configuration file
```
Diagnostic/verifier excerpt:
```
parse	ok	4ff2b63d6be54017fe04ad0605c77501
semantic	error	unhandled path specifier 'postfix configuration file'
```

## handbook-all: a18, deepseek/p17/0

opus55, r2: `verification_rejected` → `query_semantic_error`.

For RedHat and Ubuntu, install the lastest version of postfix, backup its default configuration file, and download the configuration file from http://example.com/cfg.ubuntu for Ubuntu and http://example.com/cfg.redhat for RedHat

Supplied query:
```
if os is RedHat or os is Ubuntu then install postfix with version=latest; copy postfix configuration file to ?backup. if os is Ubuntu then download postfix configuration file from "http://example.com/cfg.ubuntu". if os is "RedHat" then download postfix configuration file from "http://example.com/cfg.redhat"
```
Generated query:
```
if os is RedHat or os is Ubuntu then install postfix with version="latest"; copy postfix configuration file to ?backup; if os is Ubuntu then download file from "http://example.com/cfg.ubuntu" to postfix configuration file otherwise download file from "http://example.com/cfg.redhat" to postfix configuration file
```
Diagnostic/verifier excerpt:
```
parse	ok	4ff2b63d6be54017fe04ad0605c77501
semantic	error	unhandled path specifier 'postfix configuration file'
```

## handbook-all: a20, starcoder/p19/9

gpt6, r0: `accepted_with_possible_residuals` → `verification_rejected`.

Enable passwordless sudo for a `wheel' group and create an `ansible' user in that group

Supplied query:
```
enable passwordless sudo for group=wheel; create user with name=ansible in supplemental groups=wheel
```
Generated query:
```
enable passwordless sudo for group="wheel"; create user with name="ansible", primary group="wheel"
```
Diagnostic/verifier excerpt:
```
FAILED TO VERIFY
```

## handbook-all: a21, deepseek/p20/8

gpt6, r0: `verification_rejected` → `accepted_with_possible_residuals`.

For Debian and RedHat, install and start an ssh client and server and generated an ssh key for `fizbaz' at /.ssh/fizbaz_rsa

Supplied query:
```
if os is Debian or os is RedHat then install ssh client; install ssh server; start ssh server service; create ssh key for user="fizbaz", name="fizbaz_rsa"
```
Generated query:
```
if os is Debian or os is RedHat then install ssh client; install ssh server; start ssh server service; create ssh key for user="fizbaz" at "/.ssh/fizbaz_rsa"
```
Diagnostic/verifier excerpt:
```
VERIFIED
< #local(()), env(()): <last_reboot = -1, os_distribution = "RedHat", os_family = "RedHat", time_counter = 0 > > { 4 branch } assuming < e_group(?loop(111)) [ 3, 2 : pos ] , e_group(?loop(136)) [ 1, 0 : pos ] , e_group(∀106) [ 3, 2 : pos ] , e_group(∀131) [ 1, 0 : pos ] , e_user("fizbaz") [ 3, 2, 1, 0 : pos ] : < default_shell = [ 2: ∀116 | 3: ∀121 | 0: ∀141 | 1: ∀147 ], homedir = [ 3, 2: ∀108 | 1, 0: ∀133 ], primary_group = [ 3, 2: ∀106 | 1, 0: ∀131 ], supplemental_groups = [ 3, 2: ∀110 | 1, 0: ∀135 ] >, env(()) : < hostname = [ 3, 2, 1, 0: ∀33 ] >, fs((∀108, file_system::remote(()))) [ 3 : pos | 2 : neg ] , fs((∀133, file_system::remote(()))) [ 1 : pos | 0 : neg ] , fs((cons_path((∀108, '/.ssh/fizbaz')), file_system::remote(()))) [ 3, 2 : neg ] , fs((cons_path((∀133, '/.ssh/fizbaz')), file_system::remote(()))) [ 1, 0 : neg ]  > and equal((add_ext((cons_path((∃133, '/.ssh/fizbaz')), ".pub")), '/.ssh/fizbaz_rsa.pub')) = [ 1, 0 : true ], equal((add_ext((cons_path((∃108, '/.ssh/fizbaz')), ".pub")), '/.ssh/fizbaz_rsa.pub')) = [ 3, 2 : true ], equal((cons_path((∃133, '/.ssh/fizbaz')), '/.ssh/fizbaz_rsa')) = [ 1, 0 : true ], equal((cons_path((∃108, '/.ssh/fizbaz')), '/.ssh/fizbaz_rsa')) = [ 3, 2 : true ], equal(('/.ssh/fizbaz_rsa.pub', add_ext((cons_path((∃133, '/.ssh/fizbaz')), ".pub")))) = [ 1, 0 : true ], equal(('/.ssh/fizbaz_rsa.pub', add_ext((cons_path((∃108, '/.ssh/fizbaz')), ".pub")))) = [ 3, 2 : true ], equal(('/.ssh/fizbaz_rsa', cons_path((∃133, '/.ssh/fizbaz')))
```

