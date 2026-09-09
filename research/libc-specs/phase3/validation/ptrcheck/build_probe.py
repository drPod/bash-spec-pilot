"""Serial, bounded probe builds with symbol checks, using a private frozen-source copy.

With dry_run=True, return planned commands without building."""
from __future__ import annotations

import hashlib
import resource
import shutil
import subprocess
import time
from pathlib import Path

from .mutations import MUTANTS, apply_mutant

BASE_CFLAGS = ["-std=c11", "-Wall", "-Wextra", "-U_FORTIFY_SOURCE"]
ALLOWED_EXTRA_UNDEF = {"__stack_chk_fail", "_GLOBAL_OFFSET_TABLE_"}
COMPILER_AS_BYTES = 1024 * 1024 * 1024
COMPILER_WALL_SECONDS = 60
COMPILER_CPU_SECONDS = 60
MACRO_DEFS = ["-Dread=probe_read", "-Dwrite=probe_write"]
WRAP_LDFLAGS = ["-Wl,--wrap=read", "-Wl,--wrap=write"]


def sha256_file(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def _limit(kind, requested: int) -> str:
    hard = resource.getrlimit(kind)[1]
    n = requested if hard == resource.RLIM_INFINITY else min(requested, hard)
    return f"{n}:{n}"


def bounded_command(cmd: list[str]) -> list[str]:
    return ["timeout", "--kill-after=2s", f"{COMPILER_WALL_SECONDS}s", "prlimit",
            "--as=" + _limit(resource.RLIMIT_AS, COMPILER_AS_BYTES),
            "--cpu=" + _limit(resource.RLIMIT_CPU, COMPILER_CPU_SECONDS), "--", *cmd]


class Builder:
    def __init__(self, cc: str, log: list, dry_run: bool):
        self.cc, self.log, self.dry_run = cc, log, dry_run

    def run(self, cmd: list[str]) -> None:
        entry = {"cmd": cmd, "bounded": bounded_command(cmd), "returncode": None, "stderr": "", "seconds": None}
        self.log.append(entry)
        if self.dry_run:
            return
        t0 = time.monotonic()
        cp = subprocess.run(entry["bounded"], capture_output=True, text=True, timeout=COMPILER_WALL_SECONDS + 5)
        entry["returncode"] = cp.returncode
        entry["stderr"] = cp.stderr[-4000:]
        entry["seconds"] = round(time.monotonic() - t0, 4)
        if cp.returncode != 0:
            raise RuntimeError(f"command failed ({cp.returncode}): {' '.join(cmd)}\n{cp.stderr}")


def nm_symbols(obj: Path) -> dict:
    cp = subprocess.run(["nm", str(obj)], capture_output=True, text=True, check=True, timeout=10)
    undefined, defined = set(), set()
    for line in cp.stdout.splitlines():
        parts = line.split()
        if len(parts) == 2 and parts[0] == "U":
            undefined.add(parts[1])
        elif len(parts) == 3:
            defined.add(parts[2])
    return {"undefined": sorted(undefined), "defined": sorted(defined)}


def check_relay_object(obj: Path, expect_undef: set, forbid: set) -> dict:
    syms = nm_symbols(obj)
    undef = set(syms["undefined"])
    problems = []
    if not expect_undef <= undef:
        problems.append(f"missing expected undefined symbols {sorted(expect_undef - undef)}")
    extra = undef - expect_undef - ALLOWED_EXTRA_UNDEF
    if extra:
        problems.append(f"unexpected undefined symbols {sorted(extra)}")
    if undef & forbid:
        problems.append(f"forbidden symbols referenced {sorted(undef & forbid)}")
    if set(syms["defined"]) != {"relay"}:
        problems.append(f"defined symbols {syms['defined']} != ['relay']")
    return {"object": str(obj), **syms, "ok": not problems, "problems": problems}


def build_all(source: Path, probe_src: Path, build_dir: Path, cc: str = "cc", with_mutants: bool = True,
              dry_run: bool = False) -> dict:
    log: list = []
    symbol_checks: list = []
    executables: dict = {}
    b = Builder(cc, log, dry_run)
    frozen = build_dir / "relay_frozen.c"
    if not dry_run:
        build_dir.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, frozen)
        if sha256_file(frozen) != sha256_file(source):
            raise RuntimeError("private copy hash differs from source (concurrent modification?)")

    drv_macro = build_dir / "probe_macro.o"
    drv_wrap = build_dir / "probe_wrap.o"
    b.run([cc, *BASE_CFLAGS, "-O2", "-DPROBE_MACRO", "-c", str(probe_src), "-o", str(drv_macro)])
    b.run([cc, *BASE_CFLAGS, "-O2", "-DPROBE_WRAP", "-c", str(probe_src), "-o", str(drv_wrap)])

    def relay_obj(name: str, opt: str, macro: bool, src: Path = frozen) -> Path:
        obj = build_dir / f"{name}.o"
        cmd = [cc, *BASE_CFLAGS, opt]
        if macro:
            cmd += MACRO_DEFS
        cmd += ["-c", str(src), "-o", str(obj)]
        b.run(cmd)
        if dry_run:
            return obj
        if macro:
            chk = check_relay_object(obj, {"probe_read", "probe_write"}, {"read", "write", "__read_chk", "__write_chk"})
        else:
            chk = check_relay_object(obj, {"read", "write"}, {"probe_read", "probe_write", "__read_chk", "__write_chk"})
        chk["name"] = name
        symbol_checks.append(chk)
        if not chk["ok"]:
            raise RuntimeError(f"symbol check failed for {name}: {chk['problems']}")
        return obj

    def link(name: str, objs: list, wrap: bool, role: str, kind: str, extra: dict | None = None) -> None:
        exe = build_dir / name
        cmd = [cc, "-O2", *[str(o) for o in objs], "-o", str(exe)]
        if wrap:
            cmd += WRAP_LDFLAGS
        b.run(cmd)
        executables[name] = {"path": str(exe), "role": role, "kind": kind,
                             "sha256": None if dry_run else sha256_file(exe), **(extra or {})}

    o = relay_obj("relay_macro_O2", "-O2", macro=True)
    link("orig_macro_O2", [drv_macro, o], wrap=False, role="original", kind="macro-substitution -O2")
    o = relay_obj("relay_macro_O0", "-O0", macro=True)
    link("orig_macro_O0", [drv_macro, o], wrap=False, role="original", kind="macro-substitution -O0")
    plain_o2 = relay_obj("relay_plain_O2", "-O2", macro=False)
    link("orig_wrap_O2", [drv_wrap, plain_o2], wrap=True, role="original", kind="ld --wrap -O2")
    # unshimmed control: probe driver + plain relay.o, no wrap => relay's read/write hit libc and
    # must fail under fd isolation (status 1, zero probe events)
    link("unshimmed_control", [drv_macro, plain_o2], wrap=False, role="control", kind="plain relay.o, real syscalls")

    mutant_info = []
    if with_mutants:
        mdir = build_dir / "mutants"
        text = source.read_text() if dry_run else frozen.read_text()
        if not dry_run:
            mdir.mkdir(exist_ok=True)
        for m in MUTANTS:
            msrc = mdir / f"relay_{m['name']}.c"
            mutated = apply_mutant(text, m)
            if not dry_run:
                msrc.write_text(mutated)
            o = relay_obj(f"relay_mut_{m['name']}", "-O2", macro=True, src=msrc)
            link(f"mut_{m['name']}", [drv_macro, o], wrap=False, role="mutant", kind="macro-substitution -O2",
                 extra={"mutant": m["name"]})
            mutant_info.append({**m, "source": str(msrc),
                                "source_sha256": hashlib.sha256(mutated.encode()).hexdigest()})

    cc_version = None
    if not dry_run:
        cc_version = subprocess.run([cc, "--version"], capture_output=True, text=True, timeout=10).stdout.splitlines()[0]
    return {
        "dry_run": dry_run,
        "compiler": cc_version,
        "cflags": BASE_CFLAGS,
        "source_copy": str(frozen),
        "source_sha256": sha256_file(source),
        "probe_sha256": sha256_file(probe_src),
        "executables": executables,
        "symbol_checks": symbol_checks,
        "mutants": mutant_info,
        "log": log,
        "compiler_invocations": len(log),
        "compile_seconds": None if dry_run else round(sum(e["seconds"] for e in log), 3),
        "warnings": [] if dry_run else [e["stderr"] for e in log if e["stderr"].strip()],
        "limits": {"compiler_address_space_bytes": COMPILER_AS_BYTES, "compiler_wall_seconds": COMPILER_WALL_SECONDS,
                   "compiler_cpu_seconds": COMPILER_CPU_SECONDS, "parallel_compilers": 1},
    }
