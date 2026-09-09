"""Sequential C builds (exactly one compiler process at a time) with symbol-table
verification that the relay object references only the intended shim symbols.
"""
from __future__ import annotations

import hashlib
import os
import resource
import shutil
import subprocess
import time
from pathlib import Path

from .mutants import MUTANTS, apply_mutant

BASE_CFLAGS = ["-std=c11", "-Wall", "-Wextra", "-U_FORTIFY_SOURCE"]
ALLOWED_EXTRA_UNDEF = {"__stack_chk_fail", "_GLOBAL_OFFSET_TABLE_"}


def sha256_file(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def bounded_limit(kind, requested):
    hard = resource.getrlimit(kind)[1]
    n = requested if hard == resource.RLIM_INFINITY else min(requested, hard)
    return f'{n}:{n}'


def _run(cmd: list[str], log: list[dict], cwd: Path | None = None) -> subprocess.CompletedProcess:
    t0 = time.monotonic()
    cp = subprocess.run(["timeout", "--kill-after=2s", "60s", "prlimit",
                         "--as=" + bounded_limit(resource.RLIMIT_AS, 1073741824), "--cpu=" + bounded_limit(resource.RLIMIT_CPU, 60), "--", *cmd],
                        cwd=cwd, capture_output=True, text=True, timeout=65)
    log.append({
        "cmd": cmd,
        "returncode": cp.returncode,
        "stderr": cp.stderr[-4000:],
        "seconds": round(time.monotonic() - t0, 4),
    })
    if cp.returncode != 0:
        raise RuntimeError(f"command failed ({cp.returncode}): {' '.join(cmd)}\n{cp.stderr}")
    return cp


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


def check_relay_object(obj: Path, expect_undef: set[str], forbid: set[str]) -> dict:
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


def build_all(source: Path, driver_dir: Path, build_dir: Path, cc: str = "cc", with_mutants: bool = True) -> dict:
    build_dir.mkdir(parents=True, exist_ok=True)
    log: list[dict] = []
    symbol_checks: list[dict] = []
    executables: dict[str, dict] = {}

    # Private copy of the frozen subject; every compile reads the copy, never the repo file.
    frozen = build_dir / "relay_frozen.c"
    shutil.copyfile(source, frozen)
    src_hash = sha256_file(frozen)
    if src_hash != sha256_file(source):
        raise RuntimeError("private copy hash differs from source (concurrent modification?)")

    driver_src = driver_dir / "relay_driver.c"
    real_main_src = driver_dir / "main_real.c"

    drv_macro = build_dir / "driver_macro.o"
    drv_wrap = build_dir / "driver_wrap.o"
    _run([cc, *BASE_CFLAGS, "-O2", "-DRELAY_SHIM_MACRO", "-c", str(driver_src), "-o", str(drv_macro)], log)
    _run([cc, *BASE_CFLAGS, "-O2", "-DRELAY_WRAP", "-c", str(driver_src), "-o", str(drv_wrap)], log)

    def relay_obj(name: str, opt: str, macro: bool, src: Path = frozen) -> Path:
        obj = build_dir / f"{name}.o"
        cmd = [cc, *BASE_CFLAGS, opt]
        if macro:
            cmd += ["-Dread=shim_read", "-Dwrite=shim_write"]
        cmd += ["-c", str(src), "-o", str(obj)]
        _run(cmd, log)
        if macro:
            chk = check_relay_object(obj, {"shim_read", "shim_write"}, {"read", "write", "__read_chk", "__write_chk"})
        else:
            chk = check_relay_object(obj, {"read", "write"}, {"shim_read", "shim_write", "__read_chk", "__write_chk"})
        chk["name"] = name
        symbol_checks.append(chk)
        if not chk["ok"]:
            raise RuntimeError(f"symbol check failed for {name}: {chk['problems']}")
        return obj

    def link(name: str, objs: list[Path], wrap: bool, role: str, kind: str, extra: dict | None = None) -> None:
        exe = build_dir / name
        cmd = [cc, "-O2", *[str(o) for o in objs], "-o", str(exe)]
        if wrap:
            cmd += ["-Wl,--wrap=read", "-Wl,--wrap=write"]
        _run(cmd, log)
        executables[name] = {"path": str(exe), "role": role, "kind": kind, "sha256": sha256_file(exe), **(extra or {})}

    for opt in ("-O2", "-O0"):
        tag = opt.lstrip("-")
        o = relay_obj(f"relay_macro_{tag}", opt, macro=True)
        link(f"orig_macro_{tag}", [drv_macro, o], wrap=False, role="original", kind=f"macro-substitution {opt}")
        o = relay_obj(f"relay_plain_{tag}", opt, macro=False)
        link(f"orig_wrap_{tag}", [drv_wrap, o], wrap=True, role="original", kind=f"ld --wrap {opt}")

    plain_o2 = build_dir / "relay_plain_O2.o"
    # unshimmed control: same driver, but relay's read/write bind to libc => must fail under fd isolation
    link("unshimmed_control", [drv_macro, plain_o2], wrap=False, role="unshimmed_control",
         kind="driver + plain relay.o (real syscalls)")
    real_main_o = build_dir / "main_real.o"
    _run([cc, *BASE_CFLAGS, "-O2", "-c", str(real_main_src), "-o", str(real_main_o)], log)
    link("relay_real", [real_main_o, plain_o2], wrap=False, role="real", kind="unmodified relay + main, no shims")

    mutant_info = []
    if with_mutants:
        mdir = build_dir / "mutants"
        mdir.mkdir(exist_ok=True)
        text = frozen.read_text()
        for m in MUTANTS:
            msrc = mdir / f"relay_{m['name']}.c"
            msrc.write_text(apply_mutant(text, m))
            o = relay_obj(f"relay_mut_{m['name']}", "-O2", macro=True, src=msrc)
            link(f"mut_{m['name']}", [drv_macro, o], wrap=False, role="mutant", kind="macro-substitution -O2",
                 extra={"mutant": m["name"]})
            mutant_info.append({**m, "source": str(msrc), "source_sha256": sha256_file(msrc)})

    cc_version = subprocess.run([cc, "--version"], capture_output=True, text=True, timeout=10).stdout.splitlines()[0]
    return {
        "compiler": cc_version,
        "cflags": BASE_CFLAGS,
        "source_copy": str(frozen),
        "source_sha256": src_hash,
        "driver_sha256": sha256_file(driver_src),
        "main_real_sha256": sha256_file(real_main_src),
        "executables": executables,
        "symbol_checks": symbol_checks,
        "mutants": mutant_info,
        "log": log,
        "compile_seconds": round(sum(e["seconds"] for e in log), 3),
    }
