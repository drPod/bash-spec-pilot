"""Subprocess execution with per-child rusage (wall, CPU, max RSS) via os.wait4 and a
kill timer.  stdin/stdout/stderr go through scratch files so arbitrary sizes cannot
deadlock and the child's exact bytes are captured.
"""
from __future__ import annotations

import os
import signal
import resource
import stat
import subprocess
import threading
import time
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class RunResult:
    status: int  # exit code, or -signal
    stdout: bytes
    stderr: bytes
    wall: float
    utime: float
    stime: float
    maxrss_kb: int
    timed_out: bool
    argv: list = field(default_factory=list)

    @property
    def stderr_text(self) -> str:
        return self.stderr.decode("utf-8", errors="replace")


class Scratch:
    """Per-thread scratch files, reused across runs."""

    def __init__(self, directory: Path, tag: str):
        directory.mkdir(parents=True, exist_ok=True)
        self.stdin = directory / f"{tag}.in"
        self.stdout = directory / f"{tag}.out"
        self.stderr = directory / f"{tag}.err"


_local = threading.local()


def scratch_for_thread(directory: Path) -> Scratch:
    s = getattr(_local, "scratch", None)
    if s is None or s.stdin.parent != directory:
        s = Scratch(directory, f"t{threading.get_ident()}")
        _local.scratch = s
    return s


def read_capture(path: Path, cap: int = 134217728) -> bytes:
    # Capture only bounded regular scratch files, even if a child replaced one.
    fd = os.open(path, os.O_RDONLY | os.O_NONBLOCK | os.O_NOFOLLOW)
    with os.fdopen(fd, "rb") as stream:
        info = os.fstat(stream.fileno())
        if not stat.S_ISREG(info.st_mode) or info.st_size > cap:
            raise ValueError("capture is not a bounded regular file")
        data = stream.read(cap + 1)
        if len(data) > cap:
            raise ValueError("capture exceeded cap")
        return data


def run_exe(argv: list[str], stdin_bytes: bytes, scratch: Scratch, timeout: float = 30.0,
            preexec_fn=None, stdout_path: str | None = None, stdin_from: str | None = None) -> RunResult:
    scratch.stdin.write_bytes(stdin_bytes)
    fin = open(stdin_from if stdin_from else scratch.stdin, "rb")
    fout = open(stdout_path if stdout_path else scratch.stdout, "wb")
    ferr = open(scratch.stderr, "wb")
    timed_out = {"v": False}
    try:
        t0 = time.monotonic()
        # Linux command-local limits; no host configuration changes. The parent validator
        # also runs under limits. No concurrent worker threads execute children.
        def limit(kind, requested):
            hard = resource.getrlimit(kind)[1]
            effective = requested if hard == resource.RLIM_INFINITY else min(requested, hard)
            return f"{effective}:{effective}"
        bounded = ["prlimit", "--as=" + limit(resource.RLIMIT_AS, 3221225472),
                   "--cpu=" + limit(resource.RLIMIT_CPU, 30), "--core=0:0",
                   "--fsize=" + limit(resource.RLIMIT_FSIZE, 134217728), "--", *argv]
        p = subprocess.Popen(bounded, stdin=fin, stdout=fout, stderr=ferr,
                             close_fds=True, preexec_fn=preexec_fn, start_new_session=True,
                             env=dict(os.environ, LEAN_NUM_THREADS='1', LEAN_STACK_SIZE_KB='16384'))

        def killer():
            timed_out["v"] = True
            try:
                os.killpg(p.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass

        timer = threading.Timer(timeout, killer)
        timer.start()
        try:
            _, raw_status, ru = os.wait4(p.pid, 0)
        finally:
            timer.cancel()
            timer.join()
        wall = time.monotonic() - t0
        code = os.waitstatus_to_exitcode(raw_status)
        p.returncode = code  # inform Popen that the child was reaped
    finally:
        fin.close()
        fout.close()
        ferr.close()
    # Redirected output is deliberately not captured. Never open a sink for reading:
    # /dev/full and /dev/zero supply an infinite stream, not the bytes written.
    out = b"" if stdout_path else read_capture(scratch.stdout)
    return RunResult(
        status=code,
        stdout=out,
        stderr=read_capture(scratch.stderr),
        wall=wall,
        utime=ru.ru_utime,
        stime=ru.ru_stime,
        maxrss_kb=ru.ru_maxrss,
        timed_out=timed_out["v"],
        argv=list(argv),
    )
