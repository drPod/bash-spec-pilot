# Reasoning models on the Responses API

Source: installed `openai==2.35.1`.
Type at `openai/types/shared_params/reasoning.py`.
Effort literal at `openai/types/shared/reasoning_effort.py`.
Token accounting at `openai/types/responses/response_usage.py`.

## `reasoning` parameter shape

```python
reasoning = {
    "effort": "low" | "medium" | "high" | "minimal" | "none" | "xhigh" | None,
    "summary": "auto" | "concise" | "detailed" | None,
}
```

Verbatim from `Reasoning(TypedDict, total=False)`:

- `effort: Optional[ReasoningEffort]` where
  `ReasoningEffort = Optional[Literal["none", "minimal", "low", "medium", "high", "xhigh"]]`.
- `summary: Optional[Literal["auto", "concise", "detailed"]]`.
- `generate_summary` — **deprecated**, use `summary`.

### Effort defaults / constraints (from upstream docstring)

- `gpt-5.1` defaults to `none` (no reasoning). Supported: `none`, `low`, `medium`, `high`. Tool calls work for all values.
- All models before `gpt-5.1` default to `medium`. They do NOT support `none`.
- `gpt-5-pro` defaults to and only supports `high`.
- `xhigh` only on models after `gpt-5.1-codex-max`.

Implication for **gpt-5.5-2026-04-23** (predates gpt-5.1): default effort is
`medium`, and `none` is not valid. The driver's optional
`OPENAI_REASONING_EFFORT` env var should be one of
`minimal | low | medium | high` for this model.

## Where reasoning tokens land in the response

Type at `openai/types/responses/response_usage.py`, verbatim:

```python
class OutputTokensDetails(BaseModel):
    reasoning_tokens: int

class ResponseUsage(BaseModel):
    input_tokens: int
    input_tokens_details: InputTokensDetails   # {cached_tokens}
    output_tokens: int
    output_tokens_details: OutputTokensDetails  # {reasoning_tokens}
    total_tokens: int
```

So:

```python
resp.usage.output_tokens                     # visible tokens + reasoning tokens
resp.usage.output_tokens_details.reasoning_tokens  # reasoning portion
visible = resp.usage.output_tokens - resp.usage.output_tokens_details.reasoning_tokens
```

Reasoning tokens count against `max_output_tokens`. If you set
`max_output_tokens=16000` and the model burns 14000 on reasoning, you have
2000 left for visible JSON output. For our impl-generation prompts that
write a Cargo.toml plus a Rust main.rs, **set `max_output_tokens` high
enough to cover both**. Bumping to ~32000 is reasonable when effort is
`medium` or higher; check `reasoning_tokens` in the first run's `log.jsonl`
to calibrate.

If the response comes back with `status="incomplete"` and
`incomplete_details.reason="max_output_tokens"`, that's the reasoning
budget eating the cap.

## Non-shape notes

- The `include` array on `responses.create` accepts
  `"reasoning.encrypted_content"` to round-trip reasoning through stateless
  multi-turn requests. Not relevant for one-shot generation.
- Reasoning items appear in `resp.output` as items with type
  `reasoning`; they are not part of `resp.output_text` (which is the
  text-message concatenation only).
