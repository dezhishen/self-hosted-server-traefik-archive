# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/stop-container.sh flaresolverr
docker run -d \
--restart=always \
--name=flaresolverr \
--network=$docker_network_name \
--network-alias=flaresolverr \
-e LANG="zh_CN.UTF-8" \
-e TZ="Asia/Shanghai" \
-e LOG_LEVEL=warn \
-m 64M --memory-swap=128M \
flaresolverr/flaresolverr:latest