#! /bin/bash
set -e

domain=$1
base_data_dir=$2
docker_network_name=$3

SISMICS_ADMIN_EMAIL=$(`dirname $0`/get-args.sh SISMICS_EMAIL "sismics's admin email")
if [ ! -n "$SISMICS_ADMIN_EMAIL" ]; then
    ## input your LIVEBOOK_PASSWORD,or defaut is amdin
    read -p "please input the admin's email of sismics" SISMICS_ADMIN_EMAIL
    if [ ! -n "$SISMICS_ADMIN_EMAIL" ]; then
        exit 1
    fi
    `dirname $0`/set-args.sh SISMICS_ADMIN_EMAIL $SISMICS_ADMIN_EMAIL
fi

`dirname $0`/stop-container.sh sismics

docker run -d --restart=always --name=sismics \
--network=$docker_network_name \
--network-alias=sismics \
-m 128M --memory-swap=256M \
--label 'traefik.http.routers.sismics.rule=Host(`sismics'.$domain'`)' \
--label 'traefik.http.routers.sismics.service=sismics' \
--label "traefik.http.routers.sismics.tls=true" \
--label "traefik.http.routers.sismics.tls.certresolver=traefik" \
--label "traefik.http.routers.sismics.tls.domains[0].main=sismics.$domain" \
--label "traefik.http.services.sismics.loadbalancer.server.port=8080" \
--label "traefik.enable=true" \
-e DOCS_BASE_URL="https://sismics.$domain" \
-e DOCS_ADMIN_EMAIL_INIT="$SISMICS_ADMIN_EMAIL"
-v $base_data_dir/sismics/data:/data \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
sismics/sismics
