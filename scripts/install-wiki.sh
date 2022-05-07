#! /bin/bash

domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/stop-container.sh wikijs
docker run -d \
--restart=always \
--network $docker_network_name \
--network-alias=wikijs \
--name wikijs \
-m 128M --memory-swap=256M \
-v $base_data_dir/wikijs/data:/data \
-v $base_data_dir/wikijs/config:/config \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e UID=`id -u` \
-e GID=`id -g` \
--label 'traefik.http.routers.wikijs.rule=Host(`wikijs.'$domain'`)' \
--label "traefik.http.routers.wikijs.tls=true" \
--label "traefik.http.routers.wikijs.tls.certresolver=traefik" \
--label "traefik.http.routers.wikijs.tls.domains[0].main=wikijs.$domain" \
--label "traefik.http.services.wikijs.loadbalancer.server.port=3000" \
--label "traefik.enable=true" \
lscr.io/linuxserver/wikijs
