#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
docker run --rm --init --name astro-permission-semantics-build --network=none --memory=768m --cpus=.75 --pids-limit=128 \
 -v "$ROOT:/suite" astrogator-lab:20260924-v2 sh -c '
cp /suite/phase2/permission_semantics/source/lib/modules/permission_mode.ml /opt/astrogator/lib/modules/permission_mode.ml
cp /suite/phase2/permission_semantics/source/lib/fql/codegen.ml /opt/astrogator/lib/fql/codegen.ml
cp /suite/phase2/permission_semantics/source/lib/ansible/semant.ml /opt/astrogator/lib/ansible/semant.ml
cp /suite/phase2/permission_semantics/source/bin/verify.ml /opt/astrogator/bin/verify.ml
cp /suite/phase2/permission_semantics/mode_probe.ml /opt/astrogator/bin/mode_probe.ml
printf "\n(executable (name mode_probe) (libraries modules))\n" >> /opt/astrogator/bin/dune
cp /suite/phase2/permission_semantics/source/test/dune /opt/astrogator/test/dune
cp /suite/phase2/permission_semantics/source/test/mode_regression.ml /opt/astrogator/test/mode_regression.ml
cp /suite/phase2/adequacy/patched-source/test/permission_regression.ml /opt/astrogator/test/permission_regression.ml
cd /opt/astrogator
opam exec -- dune build --profile release -j 1 bin/verify.exe bin/mode_probe.exe test/mode_regression.exe test/permission_regression.exe
_build/default/test/permission_regression.exe > /suite/phase2/permission_semantics/base-regression.txt
_build/default/test/mode_regression.exe > /suite/phase2/permission_semantics/mode-regression.txt
mkdir -p /suite/phase2/permission_semantics/.cache/bin
cp _build/default/bin/verify.exe /suite/phase2/permission_semantics/.cache/bin/verify.exe.new
mv /suite/phase2/permission_semantics/.cache/bin/verify.exe.new /suite/phase2/permission_semantics/.cache/bin/verify.exe
cp _build/default/bin/mode_probe.exe /suite/phase2/permission_semantics/.cache/bin/mode_probe.exe
'
