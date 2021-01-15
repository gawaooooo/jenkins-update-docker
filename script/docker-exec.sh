#!/bin/bash

###
# docker-exec.sh - Docker Containerにログインする
###

# container name
CONTAINER_NAME=${1:-web-jenkins}

echo "container name -> $CONTAINER_NAME"

# docker exec
docker exec -it $CONTAINER_NAME /bin/bash
