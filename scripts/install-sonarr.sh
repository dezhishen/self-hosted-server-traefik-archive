# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3


`dirname $0`/stop-container.sh sonarr

docker run -d --name=sonarr \
--restart=always \
-m 50M --memory-swap=100M \
--network=$docker_network_name \
--network-alias=sonarr \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e PUID=`id -u` -e PGID=`id -g` \
-v $base_data_dir/sonarr/config:/config \
-v $base_data_dir/public/downloads:/downloads \
-v $base_data_dir/public/:/data \
--label 'traefik.http.routers.sonarr.rule=Host(`sonarr'.$domain'`)' \
--label "traefik.http.routers.sonarr.tls=true" \
--label "traefik.http.routers.sonarr.tls.certresolver=traefik" \
--label "traefik.http.routers.sonarr.tls.domains[0].main=sonarr.$domain" \
--label "traefik.http.services.sonarr.loadbalancer.server.port=8989" \
--label "traefik.enable=true" \
lscr.io/linuxserver/sonarr

echo "启动sonarr容器"
echo "访问 https://sonarr.$domain "
echo "默认用户名: admin 密码: adminadmin"