# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/create-dir.sh $base_data_dir/qbittorrent
`dirname $0`/create-dir.sh $base_data_dir/qbittorrent/config

docker_macvlan_network_name=$(`dirname $0`/get-args.sh docker_macvlan_network_name "macvlan的网络名")
# 如果为空,需要设置
if [ -z "$docker_macvlan_network_name" ]; then
    read -p "请输入macvlan的网络名:" docker_macvlan_network_name
    if [ -z "$docker_macvlan_network_name" ]; then
        echo "macvlan的网络名使用默认值: macvlan"
        docker_macvlan_network_name="macvlan"
    fi
    `dirname $0`/set-args.sh docker_macvlan_network_name "$docker_macvlan_network_name"
fi
docker_network_exists=$(docker network ls | grep $docker_macvlan_network_name | awk '{print $2}')
if [ -n "$docker_network_exists" ]; then
    echo "容器网络 $docker_macvlan_network_name 已存在"
    #if $docker_macvlan_network_name's driver != macvlan exit
    docker_network_driver=$(docker network inspect $docker_macvlan_network_name | grep Driver | awk '{print $2}' | grep macvlan)
    if [ -z "$docker_network_driver" ]; then
        echo "容器网络 $docker_macvlan_network_name 的驱动不是macvlan,请检查"
        exit 0
    fi
else
    the_gateway=$(ip route get 1.1.1.1 | awk 'N=3 {print $N}')
    the_subnet=$(echo $the_gateway | cut -d"." -f1-3).0/24
    docker network create $docker_macvlan_network_name -d macvlan --subnet=$the_subnet --gateway=$the_gateway
    echo "容器网络 $docker_macvlan_network_name 创建成功"
fi

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
-e PUID=`id -u` -e PGID=`id -g` \
-v $base_data_dir/qbittorrent/config:/config \
-v $base_data_dir/public/downloads:/downloads \
-v $base_data_dir/public/:/data \
--label 'traefik.http.routers.qbittorrent.rule=Host(`qbittorrent.'$domain'`)' \
--label "traefik.http.routers.qbittorrent.tls=true" \
--label "traefik.http.routers.qbittorrent.tls.certresolver=traefik" \
--label "traefik.http.routers.qbittorrent.tls.domains[0].main=qbittorrent.$domain" \
--label "traefik.http.services.qbittorrent.loadbalancer.server.port=8080" \
--label "traefik.enable=true" \
lscr.io/linuxserver/qbittorrent:$arch-latest

echo "加入到bridge网络中..."
docker network connect $docker_macvlan_network_name qbittorrent --alias qbittorrent
echo "启动qbittorrent容器"
echo "访问 https://qbittorrent.$domain "
echo "默认用户名: admin 密码: adminadmin"