# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/stop-container.sh fastgithub

docker run -d --restart=always
--network=$docker_network_name \
--network-alias=fastgithub \
--name=fastgithub \
-m=64M \
dezhishuai/fastgithub:latest 