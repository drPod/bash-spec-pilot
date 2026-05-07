# Error / exception classes

Source: installed `openai==2.35.1` at `openai/_exceptions.py`. All names
below are also re-exported from the top-level `openai` package
(`openai/__init__.py`), so either of the following imports works:

```python
from openai import BadRequestError, RateLimitError       # preferred
from openai._exceptions import BadRequestError            # also valid
```

## Class hierarchy (verbatim)

```
OpenAIError(Exception)
├── SubjectTokenProviderError
├── APIError
│   ├── APIResponseValidationError
│   ├── APIStatusError
│   │   ├── BadRequestError              # HTTP 400
│   │   ├── AuthenticationError          # HTTP 401
│   │   │   └── OAuthError
│   │   ├── PermissionDeniedError        # HTTP 403
│   │   ├── NotFoundError                # HTTP 404
│   │   ├── ConflictError                # HTTP 409
│   │   ├── UnprocessableEntityError     # HTTP 422
│   │   ├── RateLimitError               # HTTP 429
│   │   └── InternalServerError          # HTTP 5xx
│   ├── APIConnectionError               # network / DNS / TCP
│   │   └── APITimeoutError              # request timed out
├── LengthFinishReasonError              # response capped (Chat Completions)
├── ContentFilterFinishReasonError       # safety stop
└── (a few transport-level exceptions)
```

`InvalidWebhookSignatureError(ValueError)` is also exported but unrelated
to `responses.create`.

## When each one fires

- `BadRequestError` — malformed request body, unsupported parameter for
  the chosen model (e.g. `temperature` on a reasoning model). The `seed`
  failure the student hit was actually a `TypeError` raised by the SDK
  *before* HTTP, because `seed` isn't in the SDK signature. SDK-layer
  invalid kwargs do NOT come back as `BadRequestError`.
- `RateLimitError` — 429. Has `response`, `body`, and standard headers
  exposing retry-after. The SDK retries 429 automatically (see retries
  below).
- `APITimeoutError` — request exceeded `timeout`. Subclass of
  `APIConnectionError`.
- `APIConnectionError` — generic transport failure (DNS, TCP reset,
  TLS). The SDK retries these too.
- `InternalServerError` — 5xx. Retried automatically.

## Retries (built into the SDK)

Defaults from `openai/_constants.py`:

```python
DEFAULT_TIMEOUT = httpx.Timeout(timeout=600, connect=5.0)  # 10-min total
DEFAULT_MAX_RETRIES = 2
```

Override globally on the client or per-call:

```python
from openai import OpenAI
client = OpenAI(timeout=120, max_retries=4)

# per-call timeout
client.with_options(timeout=300).responses.create(...)

# or directly
client.responses.create(..., timeout=300)
```

The SDK retries on: connection errors, 408, 409 (conflict), 429
(rate-limit), 5xx. It does NOT retry on 4xx that are not 408/409/429
(your bug stays a bug).

## Recommended driver pattern

```python
from openai import (
    OpenAI,
    APITimeoutError,
    APIConnectionError,
    BadRequestError,
    RateLimitError,
    APIStatusError,
)

client = OpenAI(timeout=300, max_retries=3)

try:
    resp = client.responses.create(...)
except BadRequestError as e:
    # request body / param shape problem — save and exit, don't retry
    save_error("bad_request", e)
    raise
except RateLimitError as e:
    # SDK already retried max_retries times; surface to caller
    save_error("rate_limit", e)
    raise
except APITimeoutError as e:
    save_error("timeout", e)
    raise
except APIStatusError as e:
    # catches 401/403/404/409/422/5xx
    save_error(f"http_{e.status_code}", e)
    raise
except APIConnectionError as e:
    save_error("connection", e)
    raise
```

The driver currently has no error handling around `client.responses.create`,
so any of the above bubbles up as an uncaught exception and the run dies
without writing the prompt-side log. See `audit_findings.md` notes in this
folder.
