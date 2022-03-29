#! /bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3




acme_email=$(`dirname $0`/get-args.sh acme_email acme的email)
if [ -z "$acme_email" ]; then
    read -p "请输入acme的email: " acme_email
    if [ -z "$acme_email" ]; then
        echo "cloudflare的email不能为空"
        exit 1
    else
        `dirname $0`/set-args.sh acme_email $acme_email
    fi
fi
 
echo "停止dockerproxy"

docker_container_name=dockerproxy

docker ps -a -q --filter "name=$docker_container_name" | grep -q . && docker rm -fv $docker_container_name

docker run \
    --privileged \
    -m 32M --memory-swap 64M \
    -e CONTAINERS=1 \
    -e NETWORKS=1 \
    -d --restart=always \
    --network=$docker_network_name --network-alias=dockerproxy \
    --name dockerproxy \
    -v /var/run/docker.sock:/var/run/docker.sock \
    tecnativa/docker-socket-proxy


docker_container_name=traefik



TRAEFIK_AUTH_USER=$(`dirname $0`/get-args.sh TRAEFIK_AUTH_USER 用户名)
if [ -z "$TRAEFIK_AUTH_USER" ]; then
    read -p "请输入用户名:" TRAEFIK_AUTH_USER
    if [ -z "$TRAEFIK_AUTH_USER" ]; then
        echo "用户名使用默认值: admin"
        TRAEFIK_AUTH_USER="admin"
    fi
    `dirname $0`/set-args.sh TRAEFIK_AUTH_USER "$TRAEFIK_AUTH_USER"
fi

TRAEFIK_AUTH_PASSWORD=$(`dirname $0`/get-args.sh TRAEFIK_AUTH_PASSWORD 密码)
if [ -z "$TRAEFIK_AUTH_PASSWORD" ]; then
    read -p "请输入密码:" TRAEFIK_AUTH_PASSWORD
    if [ -z "$TRAEFIK_AUTH_PASSWORD" ]; then
        echo "随机生成密码"
        TRAEFIK_AUTH_PASSWORD=`$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)`
    fi
    `dirname $0`/set-args.sh TRAEFIK_AUTH_PASSWORD "$TRAEFIK_AUTH_PASSWORD"
fi

echo "用户名: $TRAEFIK_AUTH_USER"
echo "密码: $TRAEFIK_AUTH_PASSWORD"
digest="$(printf "%s:%s:%s" "$TRAEFIK_AUTH_USER" "traefik" "$TRAEFIK_AUTH_PASSWORD" | md5sum | awk '{print $1}' )"
userlist=$(printf "%s:%s:%s\n" "$TRAEFIK_AUTH_USER" "traefik" "$digest")

echo "停止之前的traefik容器"
docker_container_name=traefik
docker ps -a -q --filter "name=$docker_container_name" | grep -q . && docker rm -fv $docker_container_name

echo "启动traefik容器"
docker run --name=traefik \
--restart=always -d -m 64M --memory-swap 128M \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-p 80:80 -p 443:443 \
--network=$docker_network_name --network-alias=traefik \
--label 'traefik.http.routers.traefik.rule=Host(`traefik'.$domain'`)' \
--label "traefik.http.routers.traefik.tls=true" \
--label "traefik.http.routers.traefik.tls.certresolver=traefik" \
--label "traefik.http.routers.traefik.tls.domains[0].main=traefik.$domain" \
--label "traefik.http.services.traefik.loadbalancer.server.port=8080" \
--label "traefik.http.middlewares.traefik-auth.digestauth.users=$userlist" \
--label "traefik.http.routers.traefik.middlewares=traefik-auth@docker" \
--label "traefik.enable=true" \
-v $base_data_dir/traefik/acme:/acme traefik \
--api \
--api.dashboard=true \
--api.insecure=true \
--providers.docker=true \
--providers.docker.endpoint=tcp://dockerproxy:2375 \
--providers.docker.exposedbydefault=false \
--entrypoints.web.address=":80" \
--entrypoints.web.http.redirections.entryPoint.to=websecure \
--entrypoints.web.http.redirections.entryPoint.scheme=https \
--entrypoints.websecure.address=":443" \
--certificatesresolvers.traefik.acme.httpChallenge=true \
--certificatesresolvers.traefik.acme.httpChallenge.entryPoint=web \
--certificatesresolvers.traefik.acme.email=$acme_email \
--certificatesresolvers.traefik.acme.storage=/acme/acme.json