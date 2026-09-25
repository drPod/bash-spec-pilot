# Traced end-to-end outcomes

These are descriptive post-hoc examples, not an additional evaluation set. Full original and generated verifier residuals and runtime observations are in `traces.json`.

## compact / gpt6 / repeat0: deepseek/p10/9

Category: **program_lowering_unavailable**. Supplied query: `ansible_lowering_error`. Generated query: `ansible_lowering_error`. Strict local label: `failed_local_checks_or_execution`.

Natural language: Disable the password for the `service' user

Generated FQL:
```
disable password for user=service
```
Supplied FQL control:
```
disable password for user=service
```
Normalized semantic-effect agreement proxy: True. This is not a proof of intent equivalence.

Runtime cases: baseline=execution_error, adversarial=execution_error.

## compact / gpt6 / repeat0: deepseek/p13/0

Category: **program_lowering_unavailable**. Supplied query: `ansible_lowering_error`. Generated query: `ansible_lowering_error`. Strict local label: `failed_local_checks_or_execution`.

Natural language: Create the file /etc/file.txt with the contents ``beginning'' if it does not already exist

Generated FQL:
```
if file "/etc/file.txt" not exists then create file at "/etc/file.txt" with content="beginning"
```
Supplied FQL control:
```
if file "/etc/file.txt" not exists then create file at "/etc/file.txt" with content="beginning"
```
Normalized semantic-effect agreement proxy: True. This is not a proof of intent equivalence.

Runtime cases: baseline=execution_error, adversarial=execution_error.

## handbook / gpt6 / repeat0: deepseek/p10/9

Category: **program_lowering_unavailable**. Supplied query: `ansible_lowering_error`. Generated query: `ansible_lowering_error`. Strict local label: `failed_local_checks_or_execution`.

Natural language: Disable the password for the `service' user

Generated FQL:
```
disable password for user="service"
```
Supplied FQL control:
```
disable password for user=service
```
Normalized semantic-effect agreement proxy: True. This is not a proof of intent equivalence.

Runtime cases: baseline=execution_error, adversarial=execution_error.

## compact / gpt6 / repeat0: deepseek/p10/2

Category: **unchanged_status**. Supplied query: `verification_rejected`. Generated query: `verification_rejected`. Strict local label: `failed_local_checks_or_execution`.

Natural language: Disable the password for the `service' user

Generated FQL:
```
disable password for user=service
```
Supplied FQL control:
```
disable password for user=service
```
Normalized semantic-effect agreement proxy: True. This is not a proof of intent equivalence.

Runtime cases: baseline=oracle_rejected, adversarial=oracle_rejected.

## compact / gpt6 / repeat0: deepseek/p13/2

Category: **unchanged_status**. Supplied query: `verification_rejected`. Generated query: `verification_rejected`. Strict local label: `failed_local_checks_or_execution`.

Natural language: Create the file /etc/file.txt with the contents ``beginning'' if it does not already exist

Generated FQL:
```
if file "/etc/file.txt" not exists then create file at "/etc/file.txt" with content="beginning"
```
Supplied FQL control:
```
if file "/etc/file.txt" not exists then create file at "/etc/file.txt" with content="beginning"
```
Normalized semantic-effect agreement proxy: True. This is not a proof of intent equivalence.

Runtime cases: baseline=oracle_rejected, adversarial=oracle_rejected.

## compact / gpt6 / repeat0: gpt-5-mini/p10/7

Category: **unchanged_status**. Supplied query: `accepted_with_possible_residuals`. Generated query: `accepted_with_possible_residuals`. Strict local label: `failed_local_checks_or_execution`.

Natural language: Disable the password for the `service' user

Generated FQL:
```
disable password for user=service
```
Supplied FQL control:
```
disable password for user=service
```
Normalized semantic-effect agreement proxy: True. This is not a proof of intent equivalence.

Runtime cases: baseline=oracle_rejected, adversarial=passed.

## compact / gpt6 / repeat0: granite/p13/7

Category: **unchanged_status**. Supplied query: `accepted_with_possible_residuals`. Generated query: `accepted_with_possible_residuals`. Strict local label: `failed_local_checks_or_execution`.

Natural language: Create the file /etc/file.txt with the contents ``beginning'' if it does not already exist

Generated FQL:
```
if file "/etc/file.txt" not exists then create file at "/etc/file.txt" with content="beginning"
```
Supplied FQL control:
```
if file "/etc/file.txt" not exists then create file at "/etc/file.txt" with content="beginning"
```
Normalized semantic-effect agreement proxy: True. This is not a proof of intent equivalence.

Runtime cases: baseline=passed, adversarial=oracle_rejected.

## compact / gpt6 / repeat0: qwen3.5/p05/0

Category: **unchanged_status**. Supplied query: `verification_rejected`. Generated query: `verification_rejected`. Strict local label: `failed_local_checks_or_execution`.

Natural language: Delete the directory /home/mydata/web

Generated FQL:
```
delete directory at /home/mydata/web
```
Supplied FQL control:
```
delete directory at /home/mydata/web
```
Normalized semantic-effect agreement proxy: True. This is not a proof of intent equivalence.

Runtime cases: baseline=passed, adversarial=oracle_rejected.

## handbook / gpt6 / repeat0: deepseek/p10/2

Category: **unchanged_status**. Supplied query: `verification_rejected`. Generated query: `verification_rejected`. Strict local label: `failed_local_checks_or_execution`.

Natural language: Disable the password for the `service' user

Generated FQL:
```
disable password for user="service"
```
Supplied FQL control:
```
disable password for user=service
```
Normalized semantic-effect agreement proxy: True. This is not a proof of intent equivalence.

Runtime cases: baseline=oracle_rejected, adversarial=oracle_rejected.

## handbook / gpt6 / repeat0: gpt-5-mini/p10/7

Category: **unchanged_status**. Supplied query: `accepted_with_possible_residuals`. Generated query: `accepted_with_possible_residuals`. Strict local label: `failed_local_checks_or_execution`.

Natural language: Disable the password for the `service' user

Generated FQL:
```
disable password for user="service"
```
Supplied FQL control:
```
disable password for user=service
```
Normalized semantic-effect agreement proxy: True. This is not a proof of intent equivalence.

Runtime cases: baseline=oracle_rejected, adversarial=passed.

### Evidence: compact / gpt6 / r0 / deepseek/p10/9

First1,200 characters of generated-query stage/verifier output (full residual branches remain in JSON):
```
ERROR: While lowering Ansible, encountered
Could not find module ansible.posix.user
```
Original local checks:
```python
assert user_exists('service'); h=next(x.split(':')[1] for x in read('/etc/shadow').splitlines() if x.startswith('service:')); assert h.startswith(('!','*'))
```

### Evidence: compact / gpt6 / r0 / deepseek/p13/0

First1,200 characters of generated-query stage/verifier output (full residual branches remain in JSON):
```
ERROR: While lowering Ansible, encountered
No argument content for module ansible.builtin.file
```
Original local checks:
```python
assert read('/etc/file.txt') == ('existing content' if adversarial else 'beginning')
```

### Evidence: handbook / gpt6 / r0 / deepseek/p10/9

First1,200 characters of generated-query stage/verifier output (full residual branches remain in JSON):
```
ERROR: While lowering Ansible, encountered
Could not find module ansible.posix.user
```
Original local checks:
```python
assert user_exists('service'); h=next(x.split(':')[1] for x in read('/etc/shadow').splitlines() if x.startswith('service:')); assert h.startswith(('!','*'))
```

### Evidence: compact / gpt6 / r0 / deepseek/p10/2

First1,200 characters of generated-query stage/verifier output (full residual branches remain in JSON):
```
FAILED TO VERIFY
```
Original local checks:
```python
assert user_exists('service'); h=next(x.split(':')[1] for x in read('/etc/shadow').splitlines() if x.startswith('service:')); assert h.startswith(('!','*'))
```

### Evidence: compact / gpt6 / r0 / deepseek/p13/2

First1,200 characters of generated-query stage/verifier output (full residual branches remain in JSON):
```
FAILED TO VERIFY
```
Original local checks:
```python
assert read('/etc/file.txt') == ('existing content' if adversarial else 'beginning')
```

### Evidence: compact / gpt6 / r0 / gpt-5-mini/p10/7

First1,200 characters of generated-query stage/verifier output (full residual branches remain in JSON):
```
VERIFIED
< #local(()), env(()): <last_reboot = -1, os_distribution = "RedHat", os_family = "RedHat", time_counter = 0 > > { 2 branch } assuming < e_user("service") [ 1, 0 : neg ] , env(()) : < hostname = [ 1, 0: ∀16 ] >, fs(('/home/service', file_system::remote(()))) [ 1 : pos | 0 : neg ]  > and can_become(("#local_user", "root")) = [ 1, 0 : true ] performing < e_group("service") [ 1, 0 : pos ] , e_user("service") : < default_shell = [ 0: ∃18 | 1: ∃19 ], homedir = [ 1, 0: '/home/service' ], primary_group = [ 1, 0: "service" ], supplemental_groups = [ 1, 0: nil::<string>() ], system = [ 1, 0: false ] >, fs(('/home/service', file_system::remote(()))) [ 0 : pos ] : < fs_type = [ 0: file_type::directory(nil::<path>()) ], owner = [ 0: "service" ] > >
< #local(()), env(()): <last_reboot = -1, os_distribution = "Debian", os_family = "Debian", time_counter = 0 > > { 2 branch } assuming < e_user("service") [ 1, 0 : neg ] , env(()) : < hostname = [ 1, 0: ∀16 ] >, fs(('/home/service', file_system::remote(()))) [ 1 : pos | 0 : neg ]  > and can_become(("#local_user", "root")) = [ 1, 0 : true ] performing < e_group("service") [ 1, 0 : pos ] , e_user("service") : < default_shell = [ 0: ∃18 | 1: ∃
```
Original local checks:
```python
assert user_exists('service'); h=next(x.split(':')[1] for x in read('/etc/shadow').splitlines() if x.startswith('service:')); assert h.startswith(('!','*'))
```

### Evidence: compact / gpt6 / r0 / granite/p13/7

First1,200 characters of generated-query stage/verifier output (full residual branches remain in JSON):
```
VERIFIED
< #local(()), env(()): <last_reboot = -1, os_distribution = "RedHat", os_family = "RedHat", time_counter = 0 >, fs(('/etc/file.txt', file_system::remote(()))): <fs_type = file_type::file(∀13) > > { 1 branch } assuming < env(()) : < hostname = [ 0: ∀40 ] >, fs(('/etc/file.txt', file_system::remote(()))) : < mode = [ 0: ∀44 ] > > and can_become(("#local_user", "root")) = [ 0 : true ] performing < fs(('/etc/file.txt', file_system::remote(()))) [ 0 : pos ] : < fs_type = [ 0: file_type::file("beginning") ], mode = [ 0: ∀44 ], owner = [ 0: "root" ], owner_group = [ 0: "root" ] > >
< #local(()), env(()): <last_reboot = -1, os_distribution = "RedHat", os_family = "RedHat", time_counter = 0 >, not fs(('/etc/file.txt', file_system::remote(()))) > { 1 branch } assuming < env(()) : < hostname = [ 0: ∀40 ], umask = [ 0: ∀42 ] > > and can_become(("#local_user", "root")) = [ 0 : true ] performing < fs(('/etc/file.txt', file_system::remote(()))) : < mode = [ 0: mode_of_umask(∀42) ], owner = [ 0: "root" ], owner_group = [ 0: "root" ] > >
< #local(()), env(()): <last_reboot = -1, os_distribution = "Debian", os_family = "Debian", time_counter = 0 >, fs(('/etc/file.txt', file_system::remote((
```
Original local checks:
```python
assert read('/etc/file.txt') == ('existing content' if adversarial else 'beginning')
```

### Evidence: compact / gpt6 / r0 / qwen3.5/p05/0

First1,200 characters of generated-query stage/verifier output (full residual branches remain in JSON):
```
FAILED TO VERIFY
```
Original local checks:
```python
assert not P('/home/mydata/web').exists()
```

### Evidence: handbook / gpt6 / r0 / deepseek/p10/2

First1,200 characters of generated-query stage/verifier output (full residual branches remain in JSON):
```
FAILED TO VERIFY
```
Original local checks:
```python
assert user_exists('service'); h=next(x.split(':')[1] for x in read('/etc/shadow').splitlines() if x.startswith('service:')); assert h.startswith(('!','*'))
```

### Evidence: handbook / gpt6 / r0 / gpt-5-mini/p10/7

First1,200 characters of generated-query stage/verifier output (full residual branches remain in JSON):
```
VERIFIED
< #local(()), env(()): <last_reboot = -1, os_distribution = "RedHat", os_family = "RedHat", time_counter = 0 > > { 2 branch } assuming < e_user("service") [ 1, 0 : neg ] , env(()) : < hostname = [ 1, 0: ∀16 ] >, fs(('/home/service', file_system::remote(()))) [ 1 : pos | 0 : neg ]  > and can_become(("#local_user", "root")) = [ 1, 0 : true ] performing < e_group("service") [ 1, 0 : pos ] , e_user("service") : < default_shell = [ 0: ∃18 | 1: ∃19 ], homedir = [ 1, 0: '/home/service' ], primary_group = [ 1, 0: "service" ], supplemental_groups = [ 1, 0: nil::<string>() ], system = [ 1, 0: false ] >, fs(('/home/service', file_system::remote(()))) [ 0 : pos ] : < fs_type = [ 0: file_type::directory(nil::<path>()) ], owner = [ 0: "service" ] > >
< #local(()), env(()): <last_reboot = -1, os_distribution = "Debian", os_family = "Debian", time_counter = 0 > > { 2 branch } assuming < e_user("service") [ 1, 0 : neg ] , env(()) : < hostname = [ 1, 0: ∀16 ] >, fs(('/home/service', file_system::remote(()))) [ 1 : pos | 0 : neg ]  > and can_become(("#local_user", "root")) = [ 1, 0 : true ] performing < e_group("service") [ 1, 0 : pos ] , e_user("service") : < default_shell = [ 0: ∃18 | 1: ∃
```
Original local checks:
```python
assert user_exists('service'); h=next(x.split(':')[1] for x in read('/etc/shadow').splitlines() if x.startswith('service:')); assert h.startswith(('!','*'))
```

