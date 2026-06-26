> Generator: Claude (claude-opus-4-8) subagents, NOT the gpt-5.5 driver. NON-CANONICAL (see _GENERATOR.json). De-homogenized: impl and tests written by separate subagents with no shared context. Full write-up: `runs/_claude_sweep_2026-06-22.md`.

# sudo observations (round 1)

- real-gnu 26/29, rust 24/29. mut@k 0.138, DEPC 4. Highest signal of the four.
- **CAVEAT**: oracle runs as root, so all authentication/authorization gates are
  bypassed. These numbers measure arg-parsing + env/identity fidelity only.
- **012_chdir_directory: candidate KILLED on hardening (2026-06-26).** Not a
  manpage defect. The `-D` entry's second sentence ("The security policy may
  return an error if the user does not have permission to specify the working
  directory") documents the `runcwd` gate the test ignored; the test quoted only
  the first sentence. Probe confirms `-D` works once `Defaults runcwd=*` is set,
  refuses without it, identically root and non-root. False-positive of substring
  grounding. See `_hardening/`.
- **manpage_underspec 018_shell_option_command**: `-s` passing a command to the
  shell; real exits 127. Likely test-construction (command not a valid sh
  simple command), not a clean defect.
- **Divergences**: 020 `-i` HOME (login-shell command mishandled), 023
  SUDO_COMMAND includes the `sh -c` wrapper, 027 duplicate `-u` not rejected,
  029 `-K`-with-command not rejected. 027/029 are documented errors the impl
  fails to enforce.
- **shared_bug 021**: `-i -u daemon` (daemon has no login shell): both fail,
  test-design artifact.
