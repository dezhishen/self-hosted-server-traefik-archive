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

`dirname $0`/stop-container.sh nzbget
docker run -d --name=nzbget \
--restart=always \
-m 128M --memory-swap=256M \
--network=$docker_network_name \
--network-alias=nzbget \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e PUID=`id -u` -e PGID=`id -g` \
-v $base_data_dir/nzbget/config:/config \
-v $base_data_dir/public/downloads:/downloads \
-v $base_data_dir/public/:/data \
--label 'traefik.http.routers.nzbget.rule=Host(`nzbget'.$domain'`)' \
--label "traefik.http.routers.nzbget.tls=true" \
--label "traefik.http.routers.nzbget.tls.certresolver=traefik" \
--label "traefik.http.routers.nzbget.tls.domains[0].main=nzbget.$domain" \
--label "traefik.http.services.nzbget.loadbalancer.server.port=6789" \
--label "traefik.enable=true" \
lscr.io/linuxserver/nzbget:$arch-latest

echo "启动nzbget容器"
echo "访问 https://nzbget.$domain "