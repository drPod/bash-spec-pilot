# Setup

Onboarding for the man-page → LLM → Rust impl + Bash test suite experiment. Read `README.md` first if you have not already. This file documents the **stack choices** that go upstream of any code: which model, which logging approach, which prompt-engineering reference, how the determinism story actually works on the API surface we use.

All decisions verified live on **2026-05-07**. If you are reading this more than ~3 months later, re-verify the model ID and pricing — OpenAI ships fast.

---

## 1. LLM under test: GPT-5.5

We pin the **dated snapshot** rather than the floating `gpt-5.5` alias so re-runs months from now hit the same weights.

| Field | Value |
|---|---|
| Model alias | `gpt-5.5` |
| **Pinned snapshot** | **`gpt-5.5-2026-04-23`** |
| Released | 2026-04-23 (GA, not preview) |
| Knowledge cutoff | 2025-12-01 |
| Context window | 1,050,000 input / 128,000 output tokens |
| Pricing | $5.00 / 1M input · $30.00 / 1M output · $0.50 / 1M cached input |
| Long-input surcharge | Prompts >272K input tokens: 2x input, 1.5x output |
| Source | `https://developers.openai.com/api/docs/models/gpt-5.5` |

`gpt-5.5-pro` exists ($30 / $180 per 1M) and gives higher accuracy on hard reasoning tasks. **Skip it for now** — it's 6x more expensive and a man page fits comfortably in base GPT-5.5's context. Revisit only if base GPT-5.5 fails badly on `find` or `sudo`.

Do **not** use `gpt-5.5-instant` — it is the ChatGPT-product default, not the recommended API model for offline batch jobs.

### Why pin the dated snapshot, and how determinism actually works here

OpenAI rotates the floating alias when they ship a new minor revision. Two papers run a month apart against `gpt-5.5` are not testing the same model. Pinning the snapshot is therefore the *first* lever for reproducibility.

The historically-recommended second lever — `seed` + `temperature=0` + `system_fingerprint` — **does not apply to this project's API surface**. GPT-5.5 is a reasoning model on the Responses API, and:

- `temperature` is rejected by GPT-5.5 with `"Unsupported parameter: 'temperature' is not supported with this model."`
- `top_p` is rejected the same way.
- `seed` is not on `responses.create()` at all (it was a Chat Completions parameter that never migrated). The SDK `openai==2.35.1` signature does not accept it; passing it raises `TypeError` before any HTTP call.
- `system_fingerprint` is not a field on the Responses API response object.

So the actual determinism story for this project is:

> dated model snapshot (`OPENAI_MODEL=gpt-5.5-2026-04-23`)
> · `sha256(prompt template)` logged per round
> · `sha256(manpage)` logged per round
> · `response.id` logged per round (for server-side recall via `previous_response_id`)

All four are written to `_logs/log.jsonl` per round by `scripts/driver.py`. A drift in any of them is detectable by diffing the log alone. See `docs/openai/responses_create.md` for the SDK-verified parameter list.

---

## 2. OpenAI account + `.env` setup

1. Sign up at <https://platform.openai.com/signup> (or sign in if you already have an OpenAI account).
2. Add a payment method and a small credit balance at <https://platform.openai.com/settings/organization/billing>. A full run of the four utilities at $5/$30 per 1M is on the order of a few dollars; budget $20 for iteration. (See "Cost" section below for the round-1 number.)
3. Create an API key at <https://platform.openai.com/api-keys>. Name it `formal-verification-experiment`. Copy the key once — you cannot retrieve it again.
4. In the repo root:
   ```bash
   cp .env.example .env
   $EDITOR .env   # paste the key into OPENAI_API_KEY=
   ```
5. `.env` is gitignored. Never commit the key. If you leak it, revoke immediately on the API-keys page.

---

## 3. Python deps (install via `uv`)

This project does not exist yet as a Python package. To bootstrap:

```bash
uv init --no-readme --no-pin-python   # creates pyproject.toml
uv python pin 3.13                    # pin one minor behind latest stable
uv add openai python-dotenv
uv add --dev pytest ruff              # optional, but undergrad-friendly
```

Three packages are all you need:

- **`openai`** — official SDK. We use the `responses` API (newer, structured) over `chat.completions`. Pinned to `openai==2.35.1`; SDK signature is mirrored locally at `docs/openai/`.
- **`python-dotenv`** — loads `.env` into `os.environ` so the driver doesn't need a shell wrapper.
- *(no `anthropic`, no `langchain`, no `litellm`)* — single-provider, single-model experiment. Don't add abstraction the experiment doesn't need.

Rust toolchain (for evaluating generated impls) is separate. It is baked into the Docker oracle image — see "Docker oracle" below — so the dev box doesn't need a host `rustup`.

---

## 4. Reasoning effort

GPT-5.5 is a reasoning model, and the amount of thinking it does per call is controlled by the optional `reasoning.effort` parameter. The driver reads it from `OPENAI_REASONING_EFFORT`:

| Value     | When to use |
|-----------|-------------|
| `minimal` | Smoke tests, syntactic checks. Cheapest. |
| `low`     | Round 1 on simple utilities (`mv`). |
| `medium`  | Default when unset. Reasonable starting point. |
| `high`    | Iteration rounds on tricky utilities (`find`, `sudo`), or when the previous round shows obvious LLM-side reasoning gaps in the failure log. |

`xhigh` and `none` are listed in the SDK but are not valid on `gpt-5.5-2026-04-23` (per `docs/openai/reasoning.md`).

**Gotcha:** `OPENAI_MAX_OUTPUT_TOKENS` is a **hard cap that includes reasoning tokens.** If you set it to 16000 and the model burns 14000 on reasoning, the visible JSON output gets only 2000 tokens before the response comes back with `status="incomplete"` and `incomplete_details.reason="max_output_tokens"`. When you raise `OPENAI_REASONING_EFFORT` to `high`, **raise `OPENAI_MAX_OUTPUT_TOKENS` in tandem** (~32000 is reasonable). Calibrate from `output_tokens_details.reasoning_tokens` in the first round's `log.jsonl`.

---

## 5. Prompt engineering reference

**Pick:** Schulhoff et al., *The Prompt Report: A Systematic Survey of Prompt Engineering Techniques* (arXiv 2406.06608, v6 Feb 2025). Downloaded to `literature/schulhoff_2024_prompt_report.pdf`.

A PRISMA systematic review of 1,565 prompting papers, distilled into a controlled vocabulary of 33 terms and a taxonomy of 58 text-prompting techniques. We pick this over the OpenAI Cookbook or Anthropic's docs because (a) it's vendor-neutral and citation-grade, (b) we are doing research-grade single-shot prompts on a deterministic-sampling reasoning model, which puts us squarely in the zero-shot / decomposition / structured-output regime the survey covers in depth, and (c) it gives us shared vocabulary to **name** what each prompt template is doing in the eventual write-up instead of inventing ad-hoc terms. Skip the agentic / multi-turn sections — out of scope for this experiment.

The applied / rejected technique list is in `decisions.md` § "Prompt engineering choices."

Secondary reference (skim, don't depend on): the OpenAI Cookbook prompt-engineering articles at <https://cookbook.openai.com>. Useful for OpenAI-specific quirks (`text.format`, structured outputs, JSON mode) but not citation-grade.

---

## 6. Logging / experiment tracking

**Pick:** plain **structured JSONL + git-versioned prompts + per-run directories**. No external tool.

### Justification

Surveyed the obvious candidates and rejected each for this scope:

- **MLflow / Weights & Biases / Hydra** — heavy, ML-training-oriented, target hyperparameter sweeps and model checkpoints we do not have. Costs an undergrad a week of setup before producing any data.
- **LangSmith / Langfuse / Helicone / Phoenix** — LLM observability platforms. Useful when you have a multi-step agentic pipeline you cannot reproduce locally, or a production deployment with real users. We have neither: ~hundreds of single-shot calls, all reproducible from `(prompt template, man page input, snapshot id)` triplet plus the iteration-feedback hash. The dashboard is dead weight.
- **Promptfoo / Inspect AI** — eval harnesses. Right shape for prompt-vs-prompt A/B comparisons, but our story is a longitudinal failure taxonomy on four utilities, not a benchmark sweep. Adopting Inspect AI's task abstraction would force re-shaping the experiment around the tool.

For ~hundreds of API calls across four utilities, plain files win on every axis: zero setup, zero auth, fully diffable, fully reproducible by re-running, no SaaS dependency that can disappear after the project ends.

### Layout the driver follows

```
runs/<util>/<session_id>/round_NN/
  _logs/
    <prompt>_prompt.txt        # full rendered prompt (after template + man-page + feedback substitution)
    <prompt>_response.json     # full raw OpenAI response object (resp.model_dump())
    <prompt>_raw.json          # convenience: just resp.output_text
    <prompt>_error.json        # only if call failed; request shape + error class + body
    log.jsonl                  # one line per call: model, response_id, status, usage, sha256s
  impl/
    Cargo.toml
    src/main.rs
    _deps_rationale.txt
  tests/
    NNN_<slug>.sh
    _manifest.json             # per-test metadata: exercises, expected, expected_to_fail
  results_real.jsonl           # tests vs. real utility on host
  results_real-gnu.jsonl       # tests vs. real utility inside Docker GNU oracle
  results_impl.jsonl           # tests vs. LLM Rust impl
  _observations.md             # qualitative analyst notes (manual)
```

Where `<session_id>` is an ISO 8601 UTC timestamp with colons replaced for filesystem safety: `YYYY-MM-DDTHH-MM-SSZ`. One session = one iteration trajectory (rounds 1, 2, 3, ...). Rerunning a util mints a fresh session.

### Minimal usage pattern

```python
import json, os, time, pathlib
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()
client = OpenAI(timeout=300, max_retries=3)

resp = client.responses.create(
    model=os.environ["OPENAI_MODEL"],         # gpt-5.5-2026-04-23
    input=prompt,
    max_output_tokens=int(os.environ["OPENAI_MAX_OUTPUT_TOKENS"]),
    reasoning={"effort": os.environ["OPENAI_REASONING_EFFORT"]},  # optional
    text={"format": {"type": "json_schema", "name": "impl_artifact",
                     "schema": IMPL_SCHEMA, "strict": True}},
)

run_dir = pathlib.Path("runs/cp") / time.strftime("%Y-%m-%dT%H-%M-%SZ", time.gmtime()) / "round_01"
(run_dir / "_logs").mkdir(parents=True, exist_ok=True)
(run_dir / "_logs" / "impl_response.json").write_text(resp.model_dump_json(indent=2))
```

Note: no `temperature`, no `top_p`, no `seed`, no `system_fingerprint` logging — see Section 1 above for why.

The driver script (`scripts/driver.py`) wraps that pattern, plus iteration-feedback rendering for rounds ≥ 2. **Critical:** dump the full response object, not just `output_text` — token-usage and reasoning-token counts belong in the failure analysis. `runs/` is gitignored; share specific runs by zipping the directory.

If this scaffolding ever feels limiting (e.g. you want web-UI diffing across runs, or live cost dashboards), then graduate to **Langfuse self-hosted** — it ingests OpenAI calls via a one-line client-side wrapper and is the lightest of the LLM-observability tools. Don't pre-optimize.

---

## 7. Docker oracle

The experiment targets Linux/GNU userland (see `decisions.md` § "Canonical man-page source per utility"). Running tests against macOS BSD utilities silently uses the wrong oracle and produced contaminated round-1 results — see `runs/cp/legacy_pre_session/_README.md` for the postmortem.

Fix is a Docker image: `docker/Dockerfile` builds `formal-verification:trixie` from `debian:trixie-20260421-slim` with GNU coreutils, findutils, and sudo pinned to the same package versions as the man-page freeze (`coreutils 9.7-3`, `findutils 4.10.0-3`, `sudo 1.9.16p2-3+deb13u1`), plus a stable-channel Rust toolchain.

```bash
docker/build.sh                                    # build image (idempotent; layer-cache friendly)
docker/build.sh --no-cache                         # full rebuild
docker/run.sh bash -lc 'cp --version'              # exec a command in the oracle
```

`docker/run.sh` bind-mounts the repo at `/work` and runs `--rm`. `scripts/run_tests.py --target real-gnu` (and any future `coverage_rust.sh`) routes through `docker/run.sh` so the test results are deterministic regardless of dev-box OS.

---

## 8. Cost

Round 1 of `cp` (impl + tests, two calls) used:

| call  | input tokens | output tokens (incl. reasoning) | reasoning portion | total |
|-------|-------------:|--------------------------------:|------------------:|------:|
| impl  | 2,619        | 11,258                          | 3,946             | 13,877 |
| tests | 2,748        | 10,139                          | 4,324             | 12,887 |
| **sum** | **5,367**  | **21,397**                      | **8,270**         | **26,764** |

Source: `runs/cp/legacy_pre_session/round_01/_logs/log.jsonl`.

At GPT-5.5 list pricing ($5/1M input, $30/1M output):

- input cost = 5,367 × $5/1,000,000 = **$0.0268**
- output cost = 21,397 × $30/1,000,000 = **$0.6419**
- **round-1 cost ≈ $0.67**

Extrapolating: a ~10-round trajectory per util × 4 utils ≈ $25, with `find`'s long man page and `high` reasoning effort pushing the number up. The $20 budget in Section 2 is light for a full run; bump to $50 if you intend to iterate aggressively on `find` and `sudo`.

---

## 9. What to do next

- [ ] Build the Docker oracle (`docker/build.sh`) and run `cp --version` inside it as a smoke test.
- [ ] Mint a fresh `cp` session against `--target real-gnu` to replace the contaminated `legacy_pre_session` baseline. Use `scripts/eval_round.sh <util> <session> <round>` for the one-line metrics roll-up.
- [ ] Read `literature/caruca_2025_spec_mining.pdf` and `literature/schulhoff_2024_prompt_report.pdf` (zero-shot + structured-output sections) before designing follow-on prompts.
- [ ] Freeze `mv`, `find`, `sudo` man pages via `scripts/freeze_manpage.sh` so the input is reproducible on any host.
- [ ] Calibrate `OPENAI_MAX_OUTPUT_TOKENS` against the first round's `reasoning_tokens` reading before pushing effort to `high`.
- [ ] Skim `taxonomy.md` so observations land in a consistent schema (Tambon-2025 categories + Astrogator-style verifier-result decomposition).
