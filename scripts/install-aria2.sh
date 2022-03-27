#! /bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/stop-container.sh aria2

`dirname $0`/create-dir.sh $base_data_dir/aria2
`dirname $0`/create-dir.sh $base_data_dir/public
`dirname $0`/create-dir.sh $base_data_dir/public/downloads


ARIA2_RPC_SECRET=$(`dirname $0`/get-args.sh ARIA2_RPC_SECRET aria2远程密钥)
if [ -z "$ARIA2_RPC_SECRET" ]; then
    read -p "请输入aria2远程密钥: " ARIA2_RPC_SECRET
    if [ -z "$ARIA2_RPC_SECRET" ]; then
        echo "aria2远程密钥为空,即将随机生成"
        ARIA2_RPC_SECRET=`$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)`
    fi
    `dirname $0`/set-args.sh ARIA2_RPC_SECRET $ARIA2_RPC_SECRET
fi

echo "aria2远程密钥: $ARIA2_RPC_SECRET"
rule='Host(`aria2-rpc.'$domain'`)'
echo "即将启动aria2"
docker run -d   --name aria2   --restart unless-stopped   --log-opt max-size=1m \
--network=$docker_network_name --network-alias=aria2 \
-e PUID=`id -u` -e PGID=`id -g` \
-e UMASK_SET=022 \
-e RPC_SECRET=$ARIA2_RPC_SECRET \
-e LANG=zh_CN.UTF-8 \
-e "TZ=Asia/Shanghai" \
-e RPC_PORT=6800 \
-e LISTEN_PORT=6888 \
-m 50M --memory-swap=128M \
-v $base_data_dir/aria2:/config \
-v $base_data_dir/public/downloads:/downloads \
-v $base_data_dir/public/:/public \
--label "traefik.http.routers.aria2.rule=$rule" \
--label "traefik.http.routers.aria2.tls=true" \
--label "traefik.http.routers.aria2.tls.certresolver=traefik" \
--label "traefik.http.routers.aria2.tls.domains[0].main=aria2-rpc.$domain" \
--label "traefik.http.services.aria2.loadbalancer.server.port=6800" \
--label "traefik.enable=true" \
p3terx/aria2-pro
echo "aria2启动完成"