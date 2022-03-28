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

`dirname $0`/stop-container.sh prowlarr
docker run -d --name=prowlarr \
--restart=always \
-m 128M --memory-swap=256M \
--network=$docker_network_name \
--network-alias=prowlarr \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e PUID=`id -u` -e PGID=`id -g` \
-v $base_data_dir/prowlarr/config:/config \
-v $base_data_dir/public/downloads:/downloads \
-v $base_data_dir/public/:/data \
--label 'traefik.http.routers.prowlarr.rule=Host(`prowlarr'.$domain'`)' \
--label "traefik.http.routers.prowlarr.tls=true" \
--label "traefik.http.routers.prowlarr.tls.certresolver=traefik" \
--label "traefik.http.routers.prowlarr.tls.domains[0].main=prowlarr.$domain" \
--label "traefik.http.services.prowlarr.loadbalancer.server.port=9696" \
--label "traefik.enable=true" \
lscr.io/linuxserver/prowlarr:$arch-develop

echo "启动prowlarr容器"
echo "访问 https://prowlarr.$domain "