#! /bin/bash
set -e

domain=$1
base_data_dir=$2
docker_network_name=$3

LIVEBOOK_PASSWORD=$(`dirname $0`/get-args.sh LIVEBOOK_PASSWORD "livebook's password")
if [ ! -n "$LIVEBOOK_PASSWORD" ]; then
    ## input your LIVEBOOK_PASSWORD,or defaut is amdin
    read -p "请输入livebook的密码 默认,livebook" LIVEBOOK_PASSWORD
    if [ ! -n "$LIVEBOOK_PASSWORD" ]; then
        LIVEBOOK_PASSWORD="livebook"
    fi
    `dirname $0`/set-args.sh LIVEBOOK_PASSWORD $LIVEBOOK_PASSWORD
fi

`dirname $0`/stop-container.sh livebook

docker run -d --restart=always --name=livebook \
--network=$docker_network_name \
--network-alias=livebook \
-m 128M --memory-swap=256M \
--label 'traefik.http.routers.livebook.rule=Host(`livebook'.$domain'`)' \
--label 'traefik.http.routers.livebook.service=livebook' \
--label "traefik.http.routers.livebook.tls=true" \
--label "traefik.http.routers.livebook.tls.certresolver=traefik" \
--label "traefik.http.routers.livebook.tls.domains[0].main=livebook.$domain" \
--label "traefik.http.services.livebook.loadbalancer.server.port=8080" \
--label "traefik.enable=true" \
-e LIVEBOOK_PASSWORD=$LIVEBOOK_PASSWORD \
-v $base_data_dir/livebook/data:/data \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-u $(id -u):$(id -g) \
livebook/livebook
