# !/bin/bash

domain=$1
base_data_dir=$2
docker_network_name=$3
# 选择架构
echo "请选择架构:"
echo "1. x86_64"
echo "2. arm64v8"
echo "3. armhf"
read -p "请输入架构编号: " arch_num
case $arch_num in
    1 )
        arch="amd64"
        ;;
    2 )
        arch="arm64v8"
        ;;
    3 )
        arch="arm32v7"
        ;;
    * )
        echo "输入错误,即将退出安装..."
        exit 0
        ;;
esac


`dirname $0`/stop-container.sh ombi
docker run -d --name=ombi \
--restart=always \
-m 128M --memory-swap=256M \
--network=$docker_network_name \
--network-alias=ombi \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e PUID=`id -u` -e PGID=`id -g` \
-v $base_data_dir/ombi/config:/config \
-v $base_data_dir/public/downloads:/downloads \
-v $base_data_dir/public/:/data \
--label 'traefik.http.routers.ombi.rule=Host(`ombi'.$domain'`)' \
--label "traefik.http.routers.ombi.tls=true" \
--label "traefik.http.routers.ombi.tls.certresolver=traefik" \
--label "traefik.http.routers.ombi.tls.domains[0].main=ombi.$domain" \
--label "traefik.http.services.ombi.loadbalancer.server.port=3579" \
--label "traefik.enable=true" \
lscr.io/linuxserver/ombi:$arch-latest

echo "启动ombi容器"
echo "访问 https://ombi.$domain "