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

echo "停止之前的traefik容器"
docker_container_name=traefik
docker ps -a -q --filter "name=$docker_container_name" | grep -q . && docker rm -fv $docker_container_name

echo "启动traefik容器"
docker run --name=traefik \
--restart=always -d -m 50M \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-p 80:80 -p 443:443 \
--network=$docker_network_name \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $base_data_dir/traefik/acme:/acme traefik \
--providers.docker=true \
--providers.docker.exposedbydefault=false \
--entrypoints.web.address=":80" \
--entrypoints.web.http.redirections.entryPoint.to=websecure \
--entrypoints.web.http.redirections.entryPoint.scheme=https \
--entrypoints.websecure.address=":443" \
--certificatesresolvers.traefik.acme.httpChallenge=true \
--certificatesresolvers.traefik.acme.httpChallenge.entryPoint=web \
--certificatesresolvers.traefik.acme.email=$acme_email \
--certificatesresolvers.traefik.acme.storage=/acme/acme.json