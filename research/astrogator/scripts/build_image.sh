#!/bin/sh
# Rebuild from pinned source; Docker contains all system mutations.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
NAME=astrogator-lab-build
docker inspect "$NAME" >/dev/null
docker cp "$ROOT/scripts/fql_probe.ml" "$NAME:/opt/astrogator/bin/fql_probe.ml"
docker cp "$ROOT/scripts/fql_json.ml" "$NAME:/opt/astrogator/bin/fql_json.ml"
docker cp "$ROOT/scripts/compat.py" "$NAME:/tmp/compat.py"
docker exec "$NAME" python3 /tmp/compat.py
docker exec "$NAME" sh -c 'grep -q "name fql_probe" /opt/astrogator/bin/dune || printf "\n(executable (name fql_probe) (libraries fql modules))\n" >> /opt/astrogator/bin/dune'
docker exec "$NAME" sh -c 'grep -q "name fql_json" /opt/astrogator/bin/dune || printf "\n(executable (name fql_json) (libraries fql modules))\n" >> /opt/astrogator/bin/dune'
docker exec "$NAME" sh -c 'cd /opt/astrogator && opam exec -- dune build --profile release -j 1 bin/fql_probe.exe bin/fql_json.exe bin/verify.exe bin/query_interp.exe'
docker exec "$NAME" sh -c 'opam list --installed --columns=name,version > /opt/opam-lock.txt; dpkg-query -W > /opt/dpkg-lock.txt'
docker commit "$NAME" astrogator-lab:20260924
