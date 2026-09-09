"""Run one bounded process group at a time; capture only size-checked regular scratch files.

Never read redirected devices such as /dev/full to EOF: they can return unbounded data."""
from __future__ import annotations

import os
import resource
import signal
import stat
import subprocess
import threading
import time
from dataclasses import dataclass, field
from pathlib import Path

EXE_AS_BYTES = 256 * 1024 * 1024
EXE_CPU_SECONDS = 3
EXE_WALL_SECONDS = 3.0
EXE_FSIZE_BYTES = 16 * 1024 * 1024
CAPTURE_CAP = 8 * 1024 * 1024


@dataclass
class RunResult:
    status: int            # exit code, or -signal
    stdout: bytes
    stderr: bytes
    trace: bytes           # raw JSONL written by the probe (b"" if none)
    wall: float
    maxrss_kb: int
    timed_out: bool
    argv: list = field(default_factory=list)

    @property
    def stderr_text(self) -> str:
        return self.stderr.decode("utf-8", errors="replace")


class Scratch:
    def __init__(self, directory: Path, tag: str = "run"):
        directory.mkdir(parents=True, exist_ok=True)
        self.dir = directory
        self.stdin = directory / f"{tag}.in"
        self.stdout = directory / f"{tag}.out"
        self.stderr = directory / f"{tag}.err"
        self.trace = directory / f"{tag}.trace.jsonl"


def limit_arg(kind, requested: int) -> str:
    hard = resource.getrlimit(kind)[1]
    n = requested if hard == resource.RLIM_INFINITY else min(requested, hard)
    return f"{n}:{n}"


def read_capture(path: Path, cap: int = CAPTURE_CAP, missing_ok: bool = False) -> bytes:
    """Read a bounded regular file. Never follows symlinks, never reads devices."""
    try:
        fd = os.open(path, os.O_RDONLY | os.O_NONBLOCK | os.O_NOFOLLOW | os.O_CLOEXEC)
    except FileNotFoundError:
        if missing_ok:
            return b""
        raise
    with os.fdopen(fd, "rb") as stream:
        info = os.fstat(stream.fileno())
        if not stat.S_ISREG(info.st_mode):
            raise ValueError(f"capture {path} is not a regular file")
        if info.st_size > cap:
            raise ValueError(f"capture {path} exceeds cap ({info.st_size} > {cap})")
        data = stream.read(cap + 1)
        if len(data) > cap:
            raise ValueError(f"capture {path} exceeded cap while reading")
        return data


_active = threading.Lock()


def run_bounded(argv: list[str], stdin_bytes: bytes, scratch: Scratch, wall: float = EXE_WALL_SECONDS,
                as_bytes: int = EXE_AS_BYTES, cpu_seconds: int = EXE_CPU_SECONDS, fsize: int = EXE_FSIZE_BYTES,
                env: dict | None = None) -> RunResult:
    if not _active.acquire(blocking=False):
        raise RuntimeError("run_bounded is not reentrant: one tested program at a time")
    try:
        scratch.stdin.write_bytes(stdin_bytes)
        scratch.trace.unlink(missing_ok=True)
        bounded = ["prlimit", "--as=" + limit_arg(resource.RLIMIT_AS, as_bytes),
                   "--cpu=" + limit_arg(resource.RLIMIT_CPU, cpu_seconds), "--core=0:0",
                   "--fsize=" + limit_arg(resource.RLIMIT_FSIZE, fsize), "--", *argv]
        timed_out = {"v": False}
        with open(scratch.stdin, "rb") as fin, open(scratch.stdout, "wb") as fout, open(scratch.stderr, "wb") as ferr:
            t0 = time.monotonic()
            p = subprocess.Popen(bounded, stdin=fin, stdout=fout, stderr=ferr, close_fds=True,
                                 start_new_session=True, env=env if env is not None else {"PATH": os.environ.get("PATH", "/usr/bin:/bin")})

            def killer():
                timed_out["v"] = True
                try:
                    os.killpg(p.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass

            timer = threading.Timer(wall, killer)
            timer.start()
            try:
                _, raw_status, ru = os.wait4(p.pid, 0)
            finally:
                timer.cancel()
                timer.join()
            wall_s = time.monotonic() - t0
            code = os.waitstatus_to_exitcode(raw_status)
            p.returncode = code
        return RunResult(status=code, stdout=read_capture(scratch.stdout), stderr=read_capture(scratch.stderr),
                         trace=read_capture(scratch.trace, missing_ok=True), wall=wall_s,
                         maxrss_kb=ru.ru_maxrss, timed_out=timed_out["v"], argv=list(argv))
    finally:
        _active.release()
