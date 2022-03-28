# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3



echo "请选择服务架构: "
echo "1. x86-64	"
echo "2. arm64"
echo "3. armhf"
read -p "请输入序号: " num
case $num in
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

`dirname $0`/stop-container.sh jackett
docker run -d --name=jackett \
--restart=always \
-m 128M --memory-swap=256M \
--network=$docker_network_name \
--network-alias=jackett \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e PUID=`id -u` -e PGID=`id -g` \
-v $base_data_dir/jackett/config:/config \
-v $base_data_dir/public/downloads:/downloads \
-v $base_data_dir/public/:/data \
--label 'traefik.http.routers.jackett.rule=Host(`jackett'.$domain'`)' \
--label "traefik.http.routers.jackett.tls=true" \
--label "traefik.http.routers.jackett.tls.certresolver=traefik" \
--label "traefik.http.routers.jackett.tls.domains[0].main=jackett.$domain" \
--label "traefik.http.services.jackett.loadbalancer.server.port=8686" \
--label "traefik.enable=true" \
lscr.io/linuxserver/jackett:$arch-latest

echo "启动jackett容器"
echo "访问 https://jackett.$domain "