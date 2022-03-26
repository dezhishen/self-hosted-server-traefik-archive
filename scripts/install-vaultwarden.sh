#! /bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/create-dir.sh $base_data_dir/vaultwarden
`dirname $0`/create-dir.sh $base_data_dir/vaultwarden/data

`dirname $0`/stop-container.sh vaultwarden

rule='Host(`vaultwarden.'$domain'`)'

docker run -d --name vaultwarden \
--restart=always \
-e TZ="Asia/Shanghai" \
-e SIGNUPS_ALLOWED="false" \
-m 50M \
-e LANG="zh_CN.UTF-8" \
-u $(id -u):$(id -g) \
--network=$docker_network_name \
-v $base_data_dir/vaultwarden/data:/data/  \
--label "traefik.http.routers.vaultwarden.rule=$rule" \
--label "traefik.http.routers.vaultwarden.tls=true" \
--label "traefik.http.routers.vaultwarden.tls.certresolver=traefik" \
--label "traefik.http.routers.vaultwarden.tls.domains[0].main=vaultwarden.$domain" \
--label "traefik.http.services.vaultwarden.loadbalancer.server.port=80" \
--label "traefik.enable=true" \
vaultwarden/server:latest

read -p "是否需要安装备份服务?(y/n)" yn
# 如果yn不为y|Y，则退出
case $yn in
    y|Y|yes|YES|Yes)
        echo "安装备份服务"
        `dirname $0`/install-vaultwarden-backup.sh $domain $base_data_dir $docker_network_name
    ;;
esac