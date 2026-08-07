"""Load the merged measurement records with their command hash sets attached.

`res1.json` / `res2.json` / `res_fix.json` are committed *without* their `hashes` arrays, which
are ~11 MB of hex. The hashes live next to them in `hashes.json.gz`, and `dupes.py`,
`control.py`, `refoverlap.py` and `remeasure.py` all silently produce empty results without it
(that is how the stripped-artifact problem was found in the first place).

`res_fix.json` is applied last because it supersedes the four records whose command column was
auto-detected wrongly; `hashes.json.gz` was built with that same precedence, so the overlay also
carries the corrected `cmd_col` and `samples`.
"""
import gzip
import json


def load(with_hashes=True):
    """Merge the three result files and re-attach the hash sets. -> {dataset_id: record}."""
    res = {}
    for f in ("res1.json", "res2.json", "res_fix.json"):  # res_fix last: supersedes bad picks
        with open(f, encoding="utf-8") as fh:
            res.update(json.load(fh))
    if with_hashes:
        with gzip.open("hashes.json.gz", "rt", encoding="utf-8") as fh:
            for k, v in json.load(fh).items():
                res.setdefault(k, {"id": k}).update(v)
    return res
