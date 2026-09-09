# Common pointer-event trace schema (`pointer-relay-trace/1`)

One JSON document per execution of the frozen `relay.c` under the phase2 deterministic
adapter. The same shape is produced by the C probe (`producer: "c:<exe>"`), the Python
pointer-machine reference (`"model"`) and the hand-derived vectors (`"hand"`). The
Lean adapter uses the smaller projection documented below. Field values
are plain JSON integers and lowercase hex strings; no floats, no nulls in core fields.

```json
{
  "schema": "pointer-relay-trace/1",
  "producer": "model",
  "capacity": 32,
  "case":   {"name": "hand/abc_defaults", "input_hex": "616263", "reads": [], "writes": []},
  "events": [ EVENT, ... ],
  "final":  {"status": 0, "output_hex": "616263", "consumed": 3, "pending_hex": "",
             "unread_hex": "", "read_calls": 2, "write_calls": 1}
}
```

## EVENT (core fields, in this order; all required)

| field | type | meaning | PointerRelay.lean counterpart |
|---|---|---|---|
| `seq` | int | 0-based dense index in the event list | position in the `Steps` trace (the `done` step has no event) |
| `kind` | `"read"` / `"write"` | which libc call | `Kind` |
| `fd` | int | descriptor argument; 0 for reads, 1 for writes in the frozen relay | (not modelled) |
| `block` | int | always 0: one allocation | `pointer.block` |
| `offset` | int | pointer argument minus the pointer of the **first read** (the array base), in bytes | `pointer.offset` (`0` for reads, `s.off` for writes) |
| `request` | int | the full `count` argument | `request` (`32` for reads, `s.n - s.off` for writes) |
| `action` | int | schedule value consumed by this call; default = `request` when the schedule is exhausted; every call consumes one | `action` (`BufferRelay.action` yields `request` on `[]`) |
| `action_source` | `"schedule"` / `"default"` | whether `action` came from the list or the exhaustion default | derivable |
| `result` | int | canonical signed return value: read `-1` / `min(action,32,unread)`; write `-1` / `0` / `min(action, request)` | `bytes.length` when positive |
| `bytes_hex` | hex | raw bytes actually transferred (into the array for reads, out of the array **at the given pointer** for writes); empty on error/EOF/zero | `bytes` |
| `init_before`, `init_after` | int | valid chunk length `n` (offset + result of the last non-negative read) before/after the call | `s.n` (note: `readStop` keeps the old `n`; the probe reports 0 after EOF) |
| `defined_before`, `defined_after` | int | defined prefix of the array: cells ever stored by a read (`max` over reads); never shrinks | Lean memory is total; use `≥ n` only |
| `memory_hex` | hex | snapshot of the defined prefix `[0, defined_after)` **after** the call; exactly `2*defined_after` chars; stale cells beyond the current chunk stay visible | `buffer` restricted to the defined prefix |

The C producer adds a non-core `probe` object per event: `{"base_known": bool,
"in_bounds": bool, "clamped": bool}`; a correct relay always yields `true, true, false`.
It also adds `probe_exit` (the probe's exit record) and `probe_problems` (format issues).

## FINAL (all required)

| field | meaning |
|---|---|
| `status` | process/relay status: 0 EOF, 1 read error, 2 nonpositive write, 3 harness safety abort, 64 usage |
| `output_hex` | delivered bytes (= stdout of the probe) |
| `consumed` | sum of positive read results (= `consumed=` on stderr) |
| `pending_hex` | array bytes `[off, n)` at exit, taken from the last memory snapshot: nonempty exactly for status 2 |
| `unread_hex` | input suffix after `consumed` bytes |
| `read_calls`, `write_calls` | numbers of read / write events |

Conservation `output ++ pending ++ unread == input` is checked on the reference and
original relay traces. Mutant executions may violate it.

## Canonical hash

`trace_sha256(doc)` = SHA-256 of the canonical JSON (`sort_keys`, separators `,`/`:`,
ASCII) of `{"case": …, "events": [core fields only], "final": [FINAL fields only]}`. Extra
keys never enter the hash, so identical canonical documents from different producers have the same hash.
The checker also compares fields; a digest alone is not a semantics proof. `reference_trace.py --check-doc FILE` validates any
document, runs the model-free invariants, compares it with the reference and prints its hash.

## Probe wire format (raw JSONL, one object per line)

Events are the EVENT objects above plus `probe`; the file ends with
`{"kind":"exit","status":S,"consumed":N,"read_calls":R,"write_calls":W,"base_known":B,"chunk":n,"defined":d,"memory_hex":"…"}`
or `{"kind":"abort","reason":"max_calls"|"…","seq":K,"read_calls":R,"write_calls":W}`.
`ptrcheck.trace_format.parse_probe_jsonl` + `document_from_probe` turn it into a document.

The raw exit record is auxiliary instrumentation: the decoder does not require it or
cross-check every redundant field. Canonical status/stdout come from the process, and
canonical consumption/counts come from events and are compared with stderr diagnostics.
The exit memory snapshot is used when present, with last-event fallback otherwise.
Do not describe this as validation of every raw exit-record field.

## Actual Lean comparison

`TraceMain.lean` emits direction, block, offset, full request, action, result and payload
as a JSON byte array. `compare_lean.py` projects this document's hex payloads to byte
arrays and compares those seven fields for every event, plus final delivered, unread,
pending, status and read/write counts. It does not use the full document hash above.
The result is -1 for a negative action, 0 for EOF/zero write, and payload length for a
positive transfer; a positive scheduled read quota can still return EOF.

Descriptor arguments, schedule-source tags, initialization metadata and physical memory
snapshots remain C/Python checks. Lean does not emit them. In particular, after EOF the
C probe/Python reports valid chunk length0, while Lean retains the initialized length
from the last successful read. We compare terminal pending bytes without asserting
identity of these different metadata meanings. Lean's JSON `status` is the modeled relay
status; the trace-producing host executable exits0 whenever serialization succeeds.
