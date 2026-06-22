> Generator: Claude (claude-opus-4-8) subagents, NOT the gpt-5.5 driver. NON-CANONICAL (see _GENERATOR.json). De-homogenized: impl and tests written by separate subagents with no shared context. Full write-up: `runs/_claude_sweep_2026-06-22.md`.

# sudo observations (round 1)

- real-gnu 26/29, rust 24/29. mut@k 0.138, DEPC 4. Highest signal of the four.
- **CAVEAT**: oracle runs as root, so all authentication/authorization gates are
  bypassed. These numbers measure arg-parsing + env/identity fidelity only.
- **manpage_underspec 012_chdir_directory**: candidate NEW finding. Manpage:
  "-D directory ... Run the command in the specified directory." Real sudo
  refuses ("not permitted to use the -D option") unless sudoers grants `runcwd`,
  a precondition SUDO(8) never states. Worth a canonical re-run.
- **manpage_underspec 018_shell_option_command**: `-s` passing a command to the
  shell; real exits 127. Likely test-construction (command not a valid sh
  simple command), not a clean defect.
- **Divergences**: 020 `-i` HOME (login-shell command mishandled), 023
  SUDO_COMMAND includes the `sh -c` wrapper, 027 duplicate `-u` not rejected,
  029 `-K`-with-command not rejected. 027/029 are documented errors the impl
  fails to enforce.
- **shared_bug 021**: `-i -u daemon` (daemon has no login shell): both fail,
  test-design artifact.
