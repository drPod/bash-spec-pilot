"""Merge measurements with hashes.json.gz, applying res_fix.json last to override bad column picks."""
import gzip
import json


def load(with_hashes=True):
    res = {}
    for f in ("res1.json", "res2.json", "res_fix.json"):
        with open(f, encoding="utf-8") as fh:
            res.update(json.load(fh))
    if with_hashes:
        with gzip.open("hashes.json.gz", "rt", encoding="utf-8") as fh:
            for k, v in json.load(fh).items():
                res.setdefault(k, {"id": k}).update(v)
    return res
