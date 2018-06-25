#!/bin/sh

### BEGIN ###
# Author: idevz
# Since: 2018/03/12
# Description:       Run a Weibo-Mesh Container, with PHP Or OpenResty.
#	User input a build type, program will do the building things:
#	like:
#   ./x_run.sh
### END ###

set -ex

/weibo-mesh-server -c /run/server/server.yaml &
/weibo-mesh -c /run/weibo-mesh/server-mesh.yaml