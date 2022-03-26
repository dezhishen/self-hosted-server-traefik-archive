# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

docker build https://ghproxy.sdniu.workers.dev/https://github.com/dezhishen/docker-nginx-webdav.git -t dezhishen/docker-nginx-webdav

WEBDAV_AUTH_USER=$(`dirname $0`/get-args.sh WEBDAV_AUTH_USER 用户名)
if [ -z "$WEBDAV_AUTH_USER" ]; then
    read -p "请输入webdav用户名:" WEBDAV_AUTH_USER
    if [ -z "$WEBDAV_AUTH_USER" ]; then
        echo "webdav用户名使用默认值: admin"
        WEBDAV_AUTH_USER="admin"
    fi
    `dirname $0`/set-args.sh WEBDAV_AUTH_USER "$WEBDAV_AUTH_USER"
fi

WEBDAV_AUTH_PASSWORD=$(`dirname $0`/get-args.sh WEBDAV_AUTH_PASSWORD 密码)
if [ -z "$WEBDAV_AUTH_PASSWORD" ]; then
    read -p "请输入webdav密码:" WEBDAV_AUTH_PASSWORD
    if [ -z "$WEBDAV_AUTH_PASSWORD" ]; then
        echo "随机生成密码"
        WEBDAV_AUTH_PASSWORD=`$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)`
    fi
    `dirname $0`/set-args.sh WEBDAV_AUTH_PASSWORD "$WEBDAV_AUTH_PASSWORD"
fi

echo "webdav用户名: $WEBDAV_AUTH_USER"
echo "webdav密码: $WEBDAV_AUTH_PASSWORD"

`dirname $0`/stop-container.sh webdav

rule='Host(`webdav.'$domain'`)'
docker run --name webdav \
--restart=always -d \
-m 128M --memory-swap=256M \
-v $base_data_dir/public:/media \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e UID=`id -u` \
-e GID=`id -g` \
-e USERNAME=$WEBDAV_AUTH_USER \
-e PASSWORD=$WEBDAV_AUTH_PASSWORD \
--label "traefik.http.routers.webdav.rule=$rule" \
--label "traefik.http.routers.webdav.tls=true" \
--label "traefik.http.routers.webdav.tls.certresolver=traefik" \
--label "traefik.http.routers.webdav.tls.domains[0].main=webdav.$domain" \
--label "traefik.http.services.webdav.loadbalancer.server.port=80" \
--label "traefik.enable=true" \
dezhishen/docker-nginx-webdav
