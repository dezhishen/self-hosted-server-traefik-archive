# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/stop-container.sh chinesesubfinder

docker run -d \
--restart=always \
--name=chinesesubfinder \
-m 128M --memory-swap=256M \
--network=$docker_network_name \
--network-alias=chinesesubfinder \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e PUID=`id -u` -e PGID=`id -g` \
-v $base_data_dir/chinesesubfinder/config:/config \
-v $base_data_dir/public/:/data \
--label 'traefik.http.routers.chinesesubfinder.rule=Host(`chinesesubfinder'.$domain'`)' \
--label "traefik.http.routers.chinesesubfinder.tls=true" \
--label "traefik.http.routers.chinesesubfinder.tls.certresolver=traefik" \
--label "traefik.http.routers.chinesesubfinder.tls.domains[0].main=chinesesubfinder.$domain" \
--label "traefik.http.services.chinesesubfinder.loadbalancer.server.port=19035" \
--label "traefik.enable=true" \
allanpk716/chinesesubfinder