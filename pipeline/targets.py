"""Scoped utility targets matching the Lean argv/stdin-lines contract; specs use the pinned POSIX mirror."""

import random
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

REPO = Path(__file__).resolve().parent.parent
POSIX_UTILITIES = REPO / "archive" / "v1" / "docs" / "posix" / "utilities"

Case = tuple[list[str], list[str]]  # argv, stdin lines

WORDS = ["alpha", "beta", "beta", "gamma", "", "a b c", "42", "x",
         "the quick brown fox jumps over", "z", "  padded  ", "beta"]

PATHS = ["/usr/lib", "/usr/", "usr", "/", "//", ".", "..", "a/b/c", "a/b/",
         "trailing///", "no_slash", "/a", "a//b"]


def _lines(rng: random.Random, lo: int = 0, hi: int = 8) -> list[str]:
    return [rng.choice(WORDS) for _ in range(rng.randint(lo, hi))]


@dataclass(frozen=True)
class Target:
    name: str
    scope: str
    gen_case: Callable[[random.Random], Case]
    # Ignore permitted output padding, such as wc count alignment.
    normalize: Callable[[list[str]], list[str]] = staticmethod(lambda ls: ls)

    def doc_text(self) -> str:
        return (POSIX_UTILITIES / f"{self.name}.md").read_text()


def oracle_cmd(target: Target) -> str:
    prefix = "g" if sys.platform == "darwin" else ""
    return prefix + target.name


def _uniq(rng: random.Random) -> Case:
    return [], _lines(rng)


def _fold(rng: random.Random) -> Case:
    return ["-w", str(rng.randint(1, 12))], _lines(rng)


def _cut(rng: random.Random) -> Case:
    a = rng.randint(1, 6)
    return ["-c", f"{a}-{rng.randint(a, 10)}"], _lines(rng)


def _path_case(rng: random.Random) -> Case:
    return [rng.choice(PATHS)], []


def _wc(rng: random.Random) -> Case:
    return ["-l"], _lines(rng)


TARGETS = {t.name: t for t in [
    Target("uniq", "no options; read stdin, write stdout; collapse ADJACENT "
           "duplicate lines to one occurrence", _uniq),
    Target("fold", "only `-w WIDTH` with WIDTH >= 1; read stdin; break each line "
           "into chunks of at most WIDTH characters (no tab/column subtleties: "
           "count plain characters)", _fold),
    Target("cut", "only `-c A-B` with 1 <= A <= B (a single closed character "
           "range); read stdin; per line emit characters A..B (1-indexed); lines "
           "shorter than A become empty lines", _cut),
    Target("basename", "exactly one PATH operand, no suffix argument; print the "
           "last pathname component per the POSIX algorithm (trailing slashes, "
           "`//`, and `/` cases included); stdin is empty and ignored", _path_case),
    Target("dirname", "exactly one PATH operand; print the parent directory per "
           "the POSIX algorithm; stdin is empty and ignored", _path_case),
    Target("wc", "only `-l`; read stdin; print the number of lines (each line in "
           "the stdin list counts as one). Print just the decimal count, no "
           "filename", _wc,
           normalize=staticmethod(lambda ls: [" ".join(l.split()) for l in ls])),
]}


if __name__ == "__main__":
    rng = random.Random(0)
    for t in TARGETS.values():
        assert (POSIX_UTILITIES / f"{t.name}.md").is_file(), f"no POSIX page for {t.name}"
        args, stdin = t.gen_case(rng)
        assert all(isinstance(a, str) for a in args + stdin), t.name
        assert all("\n" not in l for l in stdin), t.name
    print(f"targets ok: {', '.join(TARGETS)}")
