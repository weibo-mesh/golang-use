#!/bin/sh

### BEGIN ###
# Author: idevz
# Since: 2018/03/12
# Description:       Build and push Docker image.
### END ###

set -e
BASE_DIR=$(dirname $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))

. .building_versions_info.sh

DEFAULT_GOOS=linux
DEFAULT_GOARCH=amd64

GOLANG_VERSION=${GOLANG_VERSION=$DEFAULT_GOLANG_VERSION}
GOLANG_GOOS=${GOLANG_GOOS=$DEFAULT_GOOS}
GOLANG_GOARCH=${GOLANG_GOARCH=$DEFAULT_GOARCH}

IMAGE=golang:${GOLANG_VERSION}

NOTIC_PREFIX="\n - --- --- "
NOTIC_SUFFIX=" --- --- -\n "

xnotic() {
    echo ${NOTIC_PREFIX}$1${NOTIC_SUFFIX}
}
################################################  Docker images Build Start  ################################################

cross_build() {
    ONE=$1
    docker run --rm \
    -v "${BASE_DIR}/${ONE}":/go/src/weibo-mesh/golang-use/${ONE} \
    -w /go/src/weibo-mesh/golang-use/${ONE} \
    -e CGO_ENABLED=0 \
    -e GOARCH=${GOLANG_GOARCH} \
    -e GOOS=${GOLANG_GOOS} \
    ${IMAGE} go build -a -installsuffix cgo -o weibo-mesh-${ONE} \
    weibo-mesh/golang-use/${ONE}
    xnotic "cross build done."
}

images_bp() {
    ONE=$1
    docker build -t weibocom/weibo-mesh-demo-${ONE}:${WEIBO_MESH_VERSION} ${BASE_DIR}/${ONE}
    xnotic "docker build done."
    if [ `uname` == "Darwin" ]; then
        docker push weibocom/weibo-mesh-demo-${ONE}:${WEIBO_MESH_VERSION}
        xnotic "docker push to public hub done."
    fi
}

clean_image_building_tpms() {
    ONE=$1
    rm ${BASE_DIR}/${ONE}/weibo-mesh-${ONE}
    xnotic "docker building tmps cleaned."
}


################################################ build images
build_docker_images() {
    for one in client server;
    do
        cross_build                 $one
        images_bp                   $one
        clean_image_building_tpms   $one
        xnotic "build docker images done."
    done
}


################################################ run

build_docker_images
