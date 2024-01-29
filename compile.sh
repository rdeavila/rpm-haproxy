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
  # 2.9
  "2.9.0"
  "2.9.1"
  "2.9.2"
  "2.9.3"

  # 2.8
  "2.8.0"
  "2.8.1"
  "2.8.2"
  "2.8.3"
  "2.8.4"
  "2.8.5"

  # 2.7
  "2.7.0"
  "2.7.1"
  "2.7.2"
  "2.7.3"
  "2.7.4"
  "2.7.5"
  "2.7.6"
  "2.7.7"
  "2.7.8"
  "2.7.9"
  "2.7.10"
  "2.7.11"

  # 2.6
  "2.6.0"
  "2.6.1"
  "2.6.2"
  "2.6.3"
  "2.6.4"
  "2.6.5"
  "2.6.6"
  "2.6.7"
  "2.6.8"
  "2.6.9"
  "2.6.10"
  "2.6.11"
  "2.6.12"
  "2.6.13"
  "2.6.14"
  "2.6.15"
  "2.6.16"

  # 2.4
  "2.4.15"
  "2.4.16"
  "2.4.17"
  "2.4.18"
  "2.4.19"
  "2.4.20"
  "2.4.21"
  "2.4.22"
  "2.4.23"
  "2.4.24"
  "2.4.25"
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
