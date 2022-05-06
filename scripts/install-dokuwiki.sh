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


`dirname $0`/stop-container.sh dokuwiki
docker run -d --name=dokuwiki \
--restart=always \
-m 128M --memory-swap=256M \
--network=$docker_network_name \
--network-alias=dokuwiki \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e PUID=`id -u` -e PGID=`id -g` \
-v $base_data_dir/dokuwiki/config:/config \
-v $base_data_dir/dokuwiki/data:/data \
--label 'traefik.http.routers.dokuwiki.rule=Host(`dokuwiki'.$domain'`)' \
--label "traefik.http.routers.dokuwiki.tls=true" \
--label "traefik.http.routers.dokuwiki.tls.certresolver=traefik" \
--label "traefik.http.routers.dokuwiki.tls.domains[0].main=dokuwiki.$domain" \
--label "traefik.http.services.dokuwiki.loadbalancer.server.port=80" \
--label "traefik.enable=true" \
lscr.io/linuxserver/dokuwiki:$arch-latest

echo "启动dokuwiki容器"
echo "访问 https://dokuwiki.$domain "