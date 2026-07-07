# Adversarial prompts (wave-4)

Two prompt templates run in fresh session IDs separate from impl-gen, to
break the homogenization trap (Ma et al. 2025, SAGA; Wang et al. 2026,
Code-A1) where the same model writes impl + tests and the tests inherit
the impl's blind spots.

## Templates

| File | Variables | When |
|---|---|---|
| `cold_section.md` | `{{manpage}}`, `{{slice_name}}`, `{{slice_focus_hint}}` | Blind cold flavor. Model sees manpage only, no impl. |
| `posthoc.md` | `{{manpage}}`, `{{rust_cargo_toml}}`, `{{rust_main_rs}}` | Whitebox flavor. Model sees manpage and frozen baseline impl. |

## Slice vocabulary (cold flavor only)

`{{slice_name}}` is a thematic frame, not a literal manpage section header.
Manpages are too inconsistent to extract by section name (e.g. `mv` has no
ERRORS / ENVIRONMENT block; all behavioral content lives inside DESCRIPTION).
The slice biases the model's attention without constraining its parsing.

| Slice | Frame |
|---|---|
| `errors` | Documented error conditions: existing target, missing source, permission, target-is-directory traps, cross-device caveats. |
| `flags` | Per-flag semantics, including documented interactions (`-i` vs `-f`, `-T` vs `-t`, `--backup` variants). |
| `environment` | Env-var influence on behavior (`POSIXLY_CORRECT`, `LC_*`, `TMPDIR`, locale-sensitive operations). |
| `examples` | Documented invocation patterns and edge cases (trailing slashes, special-character filenames in the documented set). |

The driver injects a per-slice focus hint inline via `{{slice_focus_hint}}`.

## Schema

Output schema matches `prompts/baseline/tests.md`. `run_tests.py` and the
divergence classifier consume both with one parser.

Each test carries a required `manpage_quote` (string): the exact verbatim
manpage span the assertion relies on, or an empty string when the test is
not tied to a specific documented span. The classifier whitespace-normalizes
this quote and substring-checks it against the frozen `utils/<util>/manpage.txt`
to split the `hallucinated_spec` quadrant — a grounded quote whose behavior
the real binary contradicts becomes `manpage_underspec` (the manpage
under-specifies what the binary enforces); an ungrounded or empty quote stays
`hallucinated_spec`.

## Why not auto-AST mutation

Wang 2024 (arXiv 2406.09843) reports 26.6 pp higher non-compilability when
test bodies are AST-mutated post-generation. Wave-4 stays prompt-level
only; auto-mutation is explicitly out of scope.

See `docs/research/adversarial_prior_art.md` for the full survey.
