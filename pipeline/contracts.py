from typing import Literal, TypedDict


ExitStatus = int | Literal["timeout"]


class SpecTheorem(TypedDict):
    name: str
    informal: str


class Mismatch(TypedDict):
    args: list[str]
    stdin: list[str]
    model_out: list[str]
    oracle_out: list[str]
    model_code: ExitStatus
    oracle_code: ExitStatus


class DiffCounts(TypedDict):
    passed: int
    trials: int


class DifferentialResult(DiffCounts):
    oracle: str
    mismatches: list[Mismatch]


class CheckResult(TypedDict):
    failures: list[str]
    mismatches: list[Mismatch]
    guard_hits: list[str]
    build_ok: bool | None
    axioms_ok: bool | None
    diff: DiffCounts | None
    build_log: str
    axioms_log: str
    secs: dict[str, float]
