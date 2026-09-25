#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
docker run --rm --init --network=none --memory=768m --cpus=.75 --pids-limit=128 -v "$ROOT:/suite" astrogator-lab:20260924-v2 sh -c '
cp /suite/phase2/description_guard/source/lib/fql/semant.ml /opt/astrogator/lib/fql/semant.ml
cp /suite/phase2/description_guard/source/test/dune /opt/astrogator/test/dune
cp /suite/phase2/description_guard/source/test/description_regression.ml /opt/astrogator/test/description_regression.ml
cp /suite/scripts/fql_probe.ml /opt/astrogator/bin/description_probe.ml
printf "\n(executable (name description_probe) (libraries fql))\n" >> /opt/astrogator/bin/dune
cd /opt/astrogator
opam exec -- dune build --profile release -j 1 bin/description_probe.exe test/description_regression.exe
mkdir -p /suite/phase2/description_guard/.cache/bin
cp _build/default/bin/description_probe.exe /suite/phase2/description_guard/.cache/bin/description_probe.exe
_build/default/test/description_regression.exe > /suite/phase2/description_guard/regressions.txt
'
