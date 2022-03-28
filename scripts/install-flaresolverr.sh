# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3
# 获取docker网络的网段
docker_network_subnet=$(docker network inspect $docker_network_name | grep -w Subnet | awk -F '"' '{print $4}')

`dirname $0`/stop-container.sh flaresolverr
docker run -d \
--restart=always \
--name=flaresolverr \
--network=$docker_network_name \
--network-alias=flaresolverr \
-e LANG="zh_CN.UTF-8" \
-e TZ="Asia/Shanghai" \
-e LOG_LEVEL=debug \
-e HEADLESS=true \
-e HOST="$docker_network_subnet" \
-m 64M --memory-swap=128M \
flaresolverr/flaresolverr:latest