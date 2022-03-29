#! /bin/bash
docker_container_name=$1

echo "正在停止容器: $docker_container_name"

docker ps -a -q --filter "name=$docker_container_name" | grep -q . && docker rm -fv $docker_container_name
