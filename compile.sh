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
COMPILE_FOR_EL7=${COMPILE_FOR_EL7:-1}

VERSIONS=(
  "2.8.1"
  "2.7.9"
  "2.6.14"
  "2.4.23"
)

mkdir -p RPMS

function build {
    VERSION=$1
    MAINVERSION=$(echo ${VERSION} | cut -d "." -f-2)
    CONTAINER_RUNTIME="docker"

    if [ "$USE_PODMAN" == "1" ]; then
      CONTAINER_RUNTIME="podman"
    fi

    echo "==> Downloading haproxy-${VERSION}..."
    curl -s -o ./SOURCES/haproxy-${VERSION}.tar.gz https://www.haproxy.org/download/${MAINVERSION}/src/haproxy-${VERSION}.tar.gz

    if [ "$COMPILE_FOR_EL9" == "1" ]; then
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

    if [ "$COMPILE_FOR_EL8" == "1" ]; then
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

    if [ "$COMPILE_FOR_EL7" == "1" ]; then
      echo "==> Compiling $CONTAINER_RUNTIME image..."
      $CONTAINER_RUNTIME build -t rdeavila/rpm-haproxy-el7:latest -f Dockerfile-el7 .

      echo "==> Compiling package..."
      $CONTAINER_RUNTIME run --rm \
        -v ./RPMS:/RPMS -v ./SOURCES:/SOURCES -v ./SPECS:/SPECS \
        -e MAINVERSION=${MAINVERSION} \
        -e VERSION=${VERSION} \
        -e RELEASE=${RELEASE} \
        -e USE_PROMETHEUS=${USE_PROMETHEUS} \
        rdeavila/rpm-haproxy-el7:latest
    fi

    echo "==> Cleaning up..."
   	rm -f ./SOURCES/haproxy-${VERSION}.tar.gz

    echo "==> Done."
    echo
}

for i in ${VERSIONS[@]}; do
  build ${i}
done
