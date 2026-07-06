# Demo: proof + differential validation of a Unix-utility model

A worked, end-to-end instance of the direction in `../00_positioning_and_experiment.md`.
It is small on purpose. The point is to make the two-layer trust story concrete and
runnable, not to score a pass rate.

## The claim, split into two layers

We do not embed the real GNU binary in Lean (that is the multi-year "Wall A" from the
research docs). Instead:

1. `model ⊨ spec` is proved. `Demo/Basic.lean` defines a Lean *model* of each utility
   as a total function, states its specification as theorems, and Lean's kernel checks
   the proofs. A passing proof covers every input, not a sampled few.
2. `model ≈ binary` is tested. `validate.py` runs the *same* compiled model against
   real GNU `head` (`ghead`) over random inputs and compares line-for-line.

The honest trust chain: the user validates the spec; Lean proves `model ⊨ spec`; the
differential run gives evidence `model ≈ binary`. We do not claim a formal `binary ⊨ spec`;
that needs the embedding no one has built. This is strictly more than v1 (which had
only the test layer) and explicit about where the formal guarantee stops.

## What is actually proved (`Demo/Basic.lean`)

For `head -n k`, over **all** `k` and **all** inputs:

| Theorem | Statement |
|---|---|
| `head_length_le_k` | output has at most `k` lines |
| `head_length_le_input` | output is never longer than the input |
| `head_is_prefix` | output is a genuine prefix of the input (order + content preserved) |
| `head_saturates` | if the input has `≤ k` lines, output equals the input |
| `head_zero` | `head -n 0` is empty |
| `head_succ` | consuming one more line prepends exactly the next line |

Plus `true_succeeds`, `false_fails`, `echo_one_line` for the trivial utilities.

Lemma names were taken from the Lean core docs (`Init.Data.List.TakeDrop` and
`Init.Data.List.Nat.TakeDrop`), not from memory, and the kernel is the final arbiter:
if a proof were wrong, `lake build` would fail.

## Run it

```sh
lake build                 # kernel-checks every proof; green = all specs hold
python3 validate.py        # model vs real GNU head, prints a fidelity rate
```

CI (`.github/workflows/lean-demo.yml`) runs both steps on every push that touches
`demo/`, with Ubuntu's `/usr/bin/head` (GNU coreutils) as the differential oracle.
On macOS, `validate.py` uses brew's `ghead`; override with `GHEAD=<path>`.

`validate.py` has two suites:
- Suite A (`k ≥ 0`): the modeled domain. Expect 100% match.
- Suite B (`head -n -2`, count-from-end): a deliberate model gap. `headModel` takes a
  `Nat` and cannot express negative counts; the differential layer surfaces this rather
  than hiding it. That is the method working, not failing.

## Why these four utilities

`true`, `false`, `echo`, `head` all terminate, so the models are plain total functions and
no fuel or coinduction is needed (see the "totality" note in `Demo/Basic.lean`). `head -n k`
is the first with a real behavioral spec over its input, so it carries the proof weight.
Utilities that loop or fork would move to an inductive `Prop` semantics, out of scope here.
