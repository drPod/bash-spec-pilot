# Structured outputs on the Responses API

Source: installed `openai==2.35.1`. Type definitions at
`openai/types/responses/response_text_config_param.py` and
`openai/types/responses/response_format_text_json_schema_config_param.py`.

## Shape of `text` (correct as of 2.35.1)

```python
text = {
    "format": {
        "type": "json_schema",          # required, literal "json_schema"
        "name": "impl_artifact",        # required, ^[A-Za-z0-9_-]{1,64}$
        "schema": { ... JSON Schema ... },  # required, dict
        "description": "...",           # optional
        "strict": True,                  # optional bool
    },
    "verbosity": "low",                  # optional, "low"|"medium"|"high"
}
```

Verbatim from `ResponseTextConfigParam`:

- `format: ResponseFormatTextConfigParam` — the format spec.
- `verbosity: Optional[Literal["low", "medium", "high"]]` — controls output verbosity.

`format` for JSON-schema mode is `ResponseFormatTextJSONSchemaConfigParam`:

- `name: Required[str]` — must match `[A-Za-z0-9_-]{1,64}`.
- `schema: Required[Dict[str, object]]` — JSON Schema object.
- `type: Required[Literal["json_schema"]]` — always the literal string.
- `description: str` — optional, used by model to interpret the schema.
- `strict: Optional[bool]` — strict adherence; subset of JSON Schema only.

Other allowed `format.type` literals: `"text"` (default plain text),
`"json_object"` (older JSON-mode, NOT recommended for gpt-4o+ — use
`json_schema` instead).

## NOT THE SAME AS Chat Completions

Chat Completions used `response_format={"type":"json_schema","json_schema":{...}}`.
The Responses API moved this onto `text.format` and **flattened** the inner
object: there is no nested `json_schema` key. The driver currently writes
the correct shape (`text.format = {type, name, schema, strict}`) — confirmed
matches the SDK type.

## Reading the parsed result

For raw access:

```python
resp = client.responses.create(model=..., input=..., text={"format": {...}})
text = resp.output_text          # string
data = json.loads(text)          # parsed JSON, schema-conformant
```

For SDK-managed parsing (Pydantic / dataclass-style), use `responses.parse`:

```python
from pydantic import BaseModel
class Impl(BaseModel):
    cargo_toml: str
    main_rs: str
    deps_rationale: str

parsed = client.responses.parse(model=..., input=..., text_format=Impl)
impl: Impl = parsed.output_parsed
```

`responses.parse` is defined at `openai/resources/responses/responses.py`
line 1179. It accepts the same signature as `create` plus a `text_format`
keyword that takes a Pydantic model class. Mutually exclusive with passing
`text.format` yourself — raises `TypeError` if both are set.

This project uses `create()` + `json.loads(resp.output_text)` because the
schema is defined inline as a dict and we want raw control. `parse()` would
require defining Pydantic models for each schema; equivalent fidelity, more
boilerplate.

## Strict-mode JSON Schema gotchas

When `strict=True`:

- `additionalProperties` must be `false` on every object.
- All properties must be listed in `required`.
- Only a subset of JSON Schema is allowed (no `oneOf` / `anyOf` mixing
  scalar+object, no `format`, no `pattern` on string with regex features
  outside ECMA, etc.). Refer to OpenAI's structured-outputs guide for the
  full subset.

The driver's `IMPL_SCHEMA` and `TESTS_SCHEMA` already comply.
