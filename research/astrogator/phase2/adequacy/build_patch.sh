#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
docker run --rm --init --name astro-phase2-permission-build --network=none --memory=768m --cpus=.75 --pids-limit=128 \
 -v "$ROOT:/suite" astrogator-lab:20260924-v2 sh -c '
cp /suite/phase2/adequacy/patched-source/lib/fql/codegen.ml /opt/astrogator/lib/fql/codegen.ml
cp /suite/phase2/adequacy/patched-source/test/dune /opt/astrogator/test/dune
cp /suite/phase2/adequacy/patched-source/test/permission_regression.ml /opt/astrogator/test/permission_regression.ml
cd /opt/astrogator
opam exec -- dune build --profile release -j 1 bin/verify.exe bin/fql_probe.exe test/permission_regression.exe
mkdir -p /suite/phase2/adequacy/.cache/bin
cp _build/default/bin/verify.exe _build/default/bin/fql_probe.exe /suite/phase2/adequacy/.cache/bin/
_build/default/test/permission_regression.exe > /suite/phase2/adequacy/patch-regression.txt
'
