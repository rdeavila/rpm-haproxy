#!/usr/bin/env bash
 
set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")"

USE_PROMETHEUS=${USE_PROMETHEUS:-1}
USE_PODMAN=${USE_PODMAN:-1}
RELEASE=${RELEASE:-1}

COMPILE_FOR_EL9=${COMPILE_FOR_EL9:-1}
COMPILE_FOR_EL8=${COMPILE_FOR_EL8:-1}

# Last versions compiled on every serie
VERSIONS=(
  # "3.1.3"
  # "3.0.8"
  # "2.9.14"
  "2.8.14"
)

mkdir -p RPMS

build() {
    VERSION=$1
    MAINVERSION=$(echo "${VERSION}" | cut -d "." -f-2)
    CONTAINER_RUNTIME="docker"

    if [[ "$USE_PODMAN" == "1" ]]; then
      CONTAINER_RUNTIME="podman"
    fi

    echo "==> Downloading haproxy-${VERSION}..."
    curl -sf -o ./SOURCES/haproxy-${VERSION}.tar.gz https://www.haproxy.org/download/${MAINVERSION}/src/haproxy-${VERSION}.tar.gz || { echo "Download failed"; exit 1; }

    if [[ "$COMPILE_FOR_EL9" == "1" ]]; then
      echo "==> Compiling $CONTAINER_RUNTIME image..."
      $CONTAINER_RUNTIME build -t rdeavila/rpm-haproxy-el9:latest -f Dockerfile-el9 .

      echo "==> Compiling package..."
     	$CONTAINER_RUNTIME run --rm \
        -v ./RPMS:/RPMS -v ./SOURCES:/SOURCES -v ./SPECS:/SPECS \
        -e MAINVERSION=${MAINVERSION} \
        -e VERSION=${VERSION} \
        -e RELEASE=${RELEASE} \
        -e USE_PROMETHEUS=${USE_PROMETHEUS} \
        rdeavila/rpm-haproxy-el9:latest
    fi

    if [[ "$COMPILE_FOR_EL8" == "1" ]]; then
      echo "==> Compiling $CONTAINER_RUNTIME image..."
      $CONTAINER_RUNTIME build -t rdeavila/rpm-haproxy-el8:latest -f Dockerfile-el8 .

      echo "==> Compiling package..."
      $CONTAINER_RUNTIME run --rm \
        -v ./RPMS:/RPMS -v ./SOURCES:/SOURCES -v ./SPECS:/SPECS \
        -e MAINVERSION=${MAINVERSION} \
        -e VERSION=${VERSION} \
        -e RELEASE=${RELEASE} \
        -e USE_PROMETHEUS=${USE_PROMETHEUS} \
        rdeavila/rpm-haproxy-el8:latest

    fi

    echo "==> Cleaning up..."
    rm -f ./SOURCES/haproxy-${VERSION}.tar.gz || true

    echo "==> Done."
    echo
}

for i in "${VERSIONS[@]}"; do
  build "${i}"
done
