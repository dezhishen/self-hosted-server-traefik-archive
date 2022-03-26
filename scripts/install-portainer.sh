#! /bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/create-dir.sh $base_data_dir/portainer
`dirname $0`/create-dir.sh $base_data_dir/portainer/data

`dirname $0`/stop-container.sh portainer
echo "即将启动portainer"

rule='Host(`portainer'.$domain'`)'

docker run -d --restart=always \
--name=portainer \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-m 50M \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $base_data_dir/portainer/data:/data \
--network=$docker_network_name  \
--label "traefik.http.routers.portainer.rule=$rule" \
--label "traefik.http.routers.portainer.tls=true" \
--label "traefik.http.routers.portainer.tls.certresolver=traefik" \
--label "traefik.http.routers.portainer.tls.domains[0].main=portainer.$domain" \
--label "traefik.http.services.portainer.loadbalancer.server.port=9000" \
--label "traefik.enable=true" \
portainer/portainer-ce