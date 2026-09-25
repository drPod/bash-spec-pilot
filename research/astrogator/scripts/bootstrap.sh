#!/bin/sh
# All package installation occurs in a new resource-limited Docker container.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
NAME=astrogator-lab-build
BASE=debian:trixie-slim@sha256:a99cfc517144bc59b1978475ec53b46ecabec7e43635402ee5b77cc54cd1b20a
if docker inspect "$NAME" >/dev/null 2>&1; then
  echo "Build container $NAME already exists. Reuse scripts/build_image.sh, or remove only this build container before a clean rebuild." >&2
  exit 1
fi
docker run -d --name "$NAME" --memory=768m --cpus=1 --pids-limit=128 "$BASE" sleep infinity
docker exec "$NAME" sh -c 'apt-get update -qq && apt-get install -y --no-install-recommends ocaml-dune ocaml-findlib libfindlib-ocaml-dev ocaml opam build-essential pkg-config libyaml-dev ca-certificates ansible-core python3-yaml python3-apt xz-utils git sudo cron procps curl'
docker exec "$NAME" sh -c 'opam init --disable-sandboxing -y --bare && opam switch create lab ocaml-system -y && opam install -y yaml.3.2.0 jingoo.1.5.4 angstrom.0.16.1 re.1.14.0 ocolor.1.3.1 --jobs=1'
docker cp "$ROOT/data/source/upstream-7c62afa.tar.gz" "$NAME:/tmp/upstream.tar.gz"
docker exec "$NAME" sh -c 'mkdir -p /opt/astrogator; tar -xzf /tmp/upstream.tar.gz -C /opt/astrogator; touch /opt/astrogator-lab-marker'
docker cp "$ROOT/scripts/make_packages.py" "$NAME:/tmp/make_packages.py"
docker exec "$NAME" sh -c 'python3 /tmp/make_packages.py; /etc/init.d/cron stop'
sh "$ROOT/scripts/build_image.sh"
docker tag astrogator-lab:20260924 astrogator-lab:20260924-v2
