#!/usr/bin/env bash
set -e
set -o pipefail

# Make sure to start with a clean 'manifests' dir
rm -rf manifests/
mkdir -p manifests/

docker run --rm -v $(pwd):$(pwd) --workdir $(pwd) quay.io/coreos/jsonnet-ci jb update
docker run --rm -v $(pwd):$(pwd) --workdir $(pwd) quay.io/coreos/jsonnet-ci jsonnet -J vendor -m manifests/ "${1-kube-prometheus.jsonnet}" | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml; rm -f {}' -- {}