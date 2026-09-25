# What the valid repaired queries actually mean

Of 21 final outputs in the corrected-grammar, one-retry condition, six pass the
real semantic analyzer and code generator. Only a01 matches the normalized
reference effect tree. The other five contain inspectable differences:

| Task | Difference in upstream semantic output |
|---|---|
| a04 | Paths become `scratch:/file.txt` and `home/user:/data.txt`, differing from `/scratch/file.txt` and `/home/user/data.txt`. |
| a07 | Generates directory creation instead of copying matching `.war` files from the controller. |
| a12 | Retains the Debian guard but drops the reboot-needed guard. |
| a15 | Uses exact OS names in place of OS families and nests the Red Hat branch under the Debian branch. |
| a18 | The action sequence differs from the supplied conditional installation/copy sequence; review the full structured difference before assigning intent fidelity. |

These are derived from Astrogator's actual semantic AST, not from a second model's
judgment. See `fql-effect-comparison.jsonl` for the full expected/generated trees
and field-level differences. They explain why successful parsing and code generation
alone are weak evidence of a good query. Tree mismatch is not generally a proof of
semantic inequivalence; the concrete changed operations and guards above are the
reviewable evidence.

`generated-query-verifier.jsonl` applies these final queries to the supplied
programs. `generated-query-transfer.json` records stage transitions against the
supplied-query run. Interpret the result as sensitivity to the query, not as
accuracy without an independent correctness oracle.

The transfer run is complete for all 2,310 attempts. Of 2,238 processed programs,
1,590 encounter an invalid generated query; the six lowered queries cover the other
648. Those produce 235 accepts with possible residuals, 220 verifier rejections,
and 193 Ansible-lowering errors. Missing processed files remain 72.

Among the six tasks, 125 programs switch from supplied-query acceptance to
generated-query rejection (99 on a04, 17 on a07, 9 on a18); three a15 programs switch
the other way. The a04 path distortion gives a concrete reason for many changed
decisions. The a18 comparison also retains the explicitly disclosed domain policy.
The a12 missing reboot guard causes no categorical outcome changes in this corpus:
unchanged decisions do not establish that the generated query preserved intent.

## Retrieval comparison

| Demonstrations / decoding | Parsed | Semantic + codegen | Normalized effect match |
|---|---:|---:|---:|
| Four retrieved original examples | 14/21 | 9/21 | 6/21 |
| Four retrieved examples from expanded pool | 13/21 | 9/21 | 7/21 |
| Same expanded-pool prompts + v2 grammar | 21/21 | 9/21 | 7/21 |

The original-pool matches are a01, a02, a04, a05, a07, a08; the expanded pool adds
a17. The grammar improves syntax without increasing lowering success or effect
matches in this run. These are single samples from one small quantized model, with
same-family demonstrations allowed and the target ID excluded. Expanded candidates
are not independently reviewed gold; one extra match is not a reliable improvement
estimate. The retrieval results are separate from the repaired-query transfer run.
