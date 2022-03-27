# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/create-data-dir.sh $base_data_dir/qbittorrent
`dirname $0`/create-data-dir.sh $base_data_dir/qbittorrent/config
rule='Host(`qbittorrent.'$domain'`)'

`dirname $0`/stop-container.sh qbittorrent

docker run -d --name=qbittorrent \
--restart=always \
-m 50M --memory-swap=100M \
--network=$docker_network_name \
--network-alias=qbittorrent \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e AUTH=$CLOUD_T_AUTH_USER:$CLOUD_T_AUTH_PASSWORD \
-e PUID=`id -u` -e PGID=`id -g` \
-v $base_data_dir/qbittorrent/config:/config \
-v $base_data_dir/public/downloads:/downloads \
--label "traefik.http.routers.qbittorrent.rule=$rule" \
--label "traefik.http.routers.qbittorrent.tls=true" \
--label "traefik.http.routers.qbittorrent.tls.certresolver=traefik" \
--label "traefik.http.routers.qbittorrent.tls.domains[0].main=qbittorrent.$domain" \
--label "traefik.http.services.qbittorrent.loadbalancer.server.port=8080" \
--label "traefik.enable=true" \
lscr.io/linuxserver/qbittorrent