# `client.responses.create()` — verified parameter list

Source of truth: installed `openai==2.35.1` at
`.venv/lib/python3.12/site-packages/openai/resources/responses/responses.py`,
the `@overload` block starting at line 131. Verbatim parameter signatures
and docstrings are taken from that file. Do not edit this document; refresh
via `scripts/sync_openai_docs.sh`.

The exact `inspect.signature(Responses.create)` output is at
`docs/openai/_responses_create_signature.txt`.

## Parameters accepted (keyword-only)

Every parameter is keyword-only. Default `omit` means "do not send the field".

| Name | Type | Notes |
|------|------|-------|
| `background` | `Optional[bool]` | Run in background. |
| `context_management` | `Optional[Iterable[ContextManagement]]` | Context-mgmt config. |
| `conversation` | `Optional[Conversation]` | Conversation handle (input items prepended). Mutually exclusive with `previous_response_id`. |
| `include` | `Optional[List[ResponseIncludable]]` | Extra fields to include in output. Notable values: `reasoning.encrypted_content`, `message.output_text.logprobs`, `web_search_call.action.sources`, `code_interpreter_call.outputs`, `computer_call_output.output.image_url`, `file_search_call.results`, `message.input_image.image_url`. |
| `input` | `Union[str, ResponseInputParam]` | **String OR a list of input items.** Plain string is the simple path; the multi-modal/multi-message path is a list. |
| `instructions` | `Optional[str]` | System/developer message inserted into the model's context. Equivalent to a `role:"system"` item in `input` for the simple case. |
| `max_output_tokens` | `Optional[int]` | Upper bound including reasoning tokens AND visible output tokens. |
| `max_tool_calls` | `Optional[int]` | Cap on built-in tool calls per response. |
| `metadata` | `Optional[Metadata]` | Up to 16 string-string pairs. Keys ≤64 chars, values ≤512 chars. |
| `model` | `ResponsesModel` | e.g. `"gpt-5.5-2026-04-23"`, `"gpt-5.1"`, `"o3"`. |
| `parallel_tool_calls` | `Optional[bool]` | Parallel tool calls. |
| `previous_response_id` | `Optional[str]` | Multi-turn chaining. Mutually exclusive with `conversation`. |
| `prompt` | `Optional[ResponsePromptParam]` | Reusable prompt template reference. |
| `prompt_cache_key` | `str` | Replaces `user` for prompt-caching bucket key. Use this, not `user`. |
| `prompt_cache_retention` | `Optional[Literal["in_memory", "24h"]]` | Extended caching. |
| `reasoning` | `Optional[Reasoning]` | `{"effort": ..., "summary": ...}`. **gpt-5 / o-series only.** See `reasoning.md`. |
| `safety_identifier` | `str` | Stable hashed user id. Replaces `user`. |
| `service_tier` | `Optional[Literal["auto","default","flex","scale","priority"]]` | Processing tier. |
| `store` | `Optional[bool]` | Persist response server-side for later retrieval. |
| `stream` | `Optional[Literal[False]] \| Literal[True]` | SSE streaming. |
| `stream_options` | `Optional[StreamOptions]` | Only when `stream=True`. |
| `temperature` | `Optional[float]` | **NOT supported by gpt-5 / reasoning models.** API rejects with "Unsupported parameter". |
| `text` | `ResponseTextConfigParam` | `{"format": ..., "verbosity": ...}`. See `structured_outputs.md`. |
| `tool_choice` | `ToolChoice` | Tool selection policy. |
| `tools` | `Iterable[ToolParam]` | Tool definitions (built-in / MCP / custom function). |
| `top_logprobs` | `Optional[int]` | 0–20 token-level logprobs. |
| `top_p` | `Optional[float]` | Nucleus sampling. **Like `temperature`, gpt-5 reasoning models reject it.** |
| `truncation` | `Optional[Literal["auto","disabled"]]` | Default `disabled` = oversize input → 400. |
| `user` | `str` | **Deprecated.** Use `safety_identifier` + `prompt_cache_key`. |
| `extra_headers` | `Headers \| None` | Per-call header override. |
| `extra_query` | `Query \| None` | Extra URL query params. |
| `extra_body` | `Body \| None` | Extra JSON body fields (escape hatch for new server-side params not yet in SDK). |
| `timeout` | `float \| httpx.Timeout \| None` | Per-call timeout override. |

## Parameters that DO NOT exist on `responses.create`

The Python SDK signature does not accept any of the following. Passing them
raises `TypeError: Responses.create() got an unexpected keyword argument 'X'`
*at the SDK layer*, before any HTTP request fires.

- `seed` — historical Chat Completions param, never on Responses.
- `max_completion_tokens` — Chat Completions name. Use `max_output_tokens`.
- `max_tokens` — also Chat Completions only.
- `response_format` — Chat Completions name. Use `text.format` instead.
- `messages` — Chat Completions name. Use `input` (string or list).
- `n` — no multi-sample on Responses.
- `presence_penalty`, `frequency_penalty`, `logit_bias`, `logprobs` — not on Responses (note `top_logprobs` IS accepted).
- `stop`, `stop_sequences` — not on Responses.
- `system` — use `instructions` or a system role inside an `input` list.
- `seed`, `system_fingerprint` — neither parameter nor returned-field exists in the Responses types.

## Response object — important fields

Defined at `openai/types/responses/response.py` and supporting modules.
The driver currently calls `resp.model_dump()` and accesses by key. Useful
keys (verified):

- `id: str` — server-side response id, usable as `previous_response_id`.
- `model: str` — model that served the request.
- `output: list[ResponseOutputItem]` — list of output items (messages, reasoning items, tool calls, etc.).
- `output_text: str` — convenience accumulator: concatenated text of all `message`-type items in `output`. Empty string if model produced no text output (e.g. only tool calls).
- `usage: ResponseUsage`:
    - `input_tokens: int`
    - `input_tokens_details.cached_tokens: int`
    - `output_tokens: int`
    - `output_tokens_details.reasoning_tokens: int` ← reasoning tokens land here
    - `total_tokens: int`
- `status: Literal["completed","incomplete","in_progress","failed","cancelled"]`
- `incomplete_details: Optional[...]` — populated when `status=="incomplete"` (e.g. `reason="max_output_tokens"`).
- `error: Optional[ResponseError]` — populated when `status=="failed"`.

**Not present** on the Response: `system_fingerprint`, `seed`. Don't log them
— they will silently be `None`. The Responses API uses `prompt_cache_key`
hits and `id` chaining instead of fingerprints for reproducibility.

## What the GPT-5.5 endpoint accepts

Confirmed at the SDK signature level (we are not calling the API in this
audit — see `decisions.md` constraint). The SDK lets every parameter
through; runtime validity per-model is enforced server-side. Known
GPT-5.5-specific rejections from the OpenAI dev community:

- `temperature` → 400 "Unsupported parameter".
- `top_p` → same family of rejection on reasoning models.
- `reasoning.effort` → accepted; `none` not valid pre-`gpt-5.1`.

If unsure, use `extra_body` to send a parameter the SDK doesn't model yet
and let the server arbitrate. Don't invent kwargs on the SDK call.
