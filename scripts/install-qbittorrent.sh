# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/create-dir.sh $base_data_dir/qbittorrent
`dirname $0`/create-dir.sh $base_data_dir/qbittorrent/config


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
--label 'traefik.http.routers.qbittorrent.rule=Host(`qbittorrent.'$domain'`)' \
--label "traefik.http.routers.qbittorrent.tls=true" \
--label "traefik.http.routers.qbittorrent.tls.certresolver=traefik" \
--label "traefik.http.routers.qbittorrent.tls.domains[0].main=qbittorrent.$domain" \
--label "traefik.http.services.qbittorrent.loadbalancer.server.port=8080" \
--label "traefik.enable=true" \
lscr.io/linuxserver/qbittorrent:$arch
echo "启动qbittorrent容器"
echo "访问 https://qbittorrent.$domain "
echo "默认用户名: admin 密码: adminadmin"