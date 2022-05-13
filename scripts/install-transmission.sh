# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/create-dir.sh $base_data_dir/transmission
`dirname $0`/create-dir.sh $base_data_dir/transmission/config

`dirname $0`/create-docker-macvlan-network.sh

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

TRANSMISSION_USER_NAME=$(`dirname $0`/get-args.sh TRANSMISSION_USER_NAME "smb's userName")
if [ ! -n "$TRANSMISSION_USER_NAME" ]; then
    ## input your TRANSMISSION_USER_NAME,or defaut is amdin
    read -p "请输入用户名默认,admin" TRANSMISSION_USER_NAME
    if [ ! -n "$TRANSMISSION_USER_NAME" ]; then
        TRANSMISSION_USER_NAME="amdin"
    fi
    `dirname $0`/set-args.sh TRANSMISSION_USER_NAME $TRANSMISSION_USER_NAME
fi

echo "user name:$TRANSMISSION_USER_NAME"
TRANSMISSION_USER_PASSWORD=$(`dirname $0`/get-args.sh TRANSMISSION_USER_PASSWORD "transmission's userPassword" )
if [ ! -n "$TRANSMISSION_USER_PASSWORD" ]; then
    ## input your TRANSMISSION_USER_PASSWORD,or random
    read -p "请输入密码，为空则自动生成" TRANSMISSION_USER_PASSWORD
    if [ ! -n "$TRANSMISSION_USER_PASSWORD" ]; then
        TRANSMISSION_USER_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
    fi
    `dirname $0`/set-args.sh TRANSMISSION_USER_PASSWORD $TRANSMISSION_USER_PASSWORD
fi
echo "password: $TRANSMISSION_USER_PASSWORD"


echo "用户名: $TRANSMISSION_USER_NAME"
echo "密码: $TRANSMISSION_USER_PASSWORD"
digest="$(printf "%s:%s:%s" "$TRANSMISSION_USER_NAME" "traefik" "$TRANSMISSION_USER_PASSWORD" | md5sum | awk '{print $1}' )"
userlist=$(printf "%s:%s:%s\n" "$TRANSMISSION_USER_NAME" "traefik" "$digest")

`dirname $0`/stop-container.sh transmission

docker run -d --name=transmission \
--restart=always \
-m 64M --memory-swap=128M \
--network=$docker_network_name \
--network-alias=transmission \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e PUID=`id -u` -e PGID=`id -g` \
-v $base_data_dir/transmission/config:/config \
-v $base_data_dir/public/downloads:/downloads \
-v $base_data_dir/public/:/data \
--label 'traefik.http.routers.transmission.rule=Host(`transmission.'$domain'`)' \
--label "traefik.http.routers.transmission.tls=true" \
--label "traefik.http.routers.transmission.tls.certresolver=traefik" \
--label "traefik.http.routers.transmission.tls.domains[0].main=transmission.$domain" \
--label "traefik.http.services.transmission.loadbalancer.server.port=9091" \
--label "traefik.http.middlewares.transmission-auth.digestauth.users=$userlist" \
--label "traefik.http.routers.transmission.middlewares=transmission-auth@docker" \
--label "traefik.enable=true" \
lscr.io/linuxserver/transmission:$arch-latest

docker_macvlan_network_name=$(`dirname $0`/get-args.sh docker_macvlan_network_name "macvlan的网络名")

docker network connect $docker_macvlan_network_name transmission --alias transmission-macvlan

echo "启动transmission容器"
echo "访问 https://transmission.$domain "

# 获取 网卡 eth1 的 ip
ip=$(docker exec -it transmission ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
echo "transmission's ip is $ip"
