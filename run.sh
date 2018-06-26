#!/bin/sh

### BEGIN ###
# Author: idevz
# Since: 2018/03/12
# Description:       Run a Golang service with Weibo-Mesh.
# ./run.sh                                run hello world demo
# ./run.sh x                              clean the container and network
# ./run.sh -h                             show this help
### END ###

set -e

BASE_DIR=$(dirname $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
GO_SERVER_IMAGE=weibocom/weibo-mesh-demo-server:0.0.4
GO_CLIENT_IMAGE=weibocom/weibo-mesh-demo-client:0.0.4
ZK_IMAGE=zookeeper
GO_SERVER_CONTAINER_NAME=gserver
GO_CLIENT_CONTAINER_NAME=gclient
ZK_CONTAINER_NAME=weibo-mesh-zk

do_weibo_mesh_hello_world() {
    if [ -z "$(docker network ls --format {{.Name}} |grep -e '^weibo-mesh$')" ]; then
        docker network create --subnet=172.18.0.0/16 weibo-mesh
    fi

    sleep 1

    docker run --rm --name ${ZK_CONTAINER_NAME} \
    --net weibo-mesh \
    --ip 172.18.0.09 \
    -d ${ZK_IMAGE}

    sleep 2

    docker run --rm --name ${GO_SERVER_CONTAINER_NAME} \
    -v ${BASE_DIR}/server:/run/server \
    -v ${BASE_DIR}/weibo-mesh:/run/weibo-mesh \
    -v ${BASE_DIR}/weibo-mesh/server:/run/weibo-mesh/server \
    -w /run/weibo-mesh/server \
    --net weibo-mesh \
    --ip 172.18.0.10 \
    --link ${ZK_CONTAINER_NAME}:zookeeper \
    ${GO_SERVER_IMAGE} /run/weibo-mesh/server_run.sh &

    sleep 1

    docker run --rm --name ${GO_CLIENT_CONTAINER_NAME} \
    -v ${BASE_DIR}/client:/run/client \
    -v ${BASE_DIR}/weibo-mesh:/run/weibo-mesh \
    -v ${BASE_DIR}/weibo-mesh/client:/run/weibo-mesh/client \
    -w /run/weibo-mesh/client \
    --net weibo-mesh \
    --ip 172.18.0.20 \
    -p 80:9999 \
    --link=${GO_SERVER_CONTAINER_NAME} \
    --link ${ZK_CONTAINER_NAME}:zookeeper \
    ${GO_CLIENT_IMAGE} /run/weibo-mesh/client_run.sh &
}

dc_clean() {
    docker stop ${GO_CLIENT_CONTAINER_NAME} ${GO_SERVER_CONTAINER_NAME} ${ZK_CONTAINER_NAME}
    docker network rm weibo-mesh
}


if [ $# != 0 ]; then
    if [ $1 == "x" ]; then
        dc_clean
    elif [ $1 == "-h" ]; then
        echo "
        ./run.sh                                run hello world demo
        ./run.sh x                              clean the container and network
        ./run.sh -h                             show this help
        "
    fi
else
    do_weibo_mesh_hello_world
fi
