# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/create-dir.sh $base_data_dir/adguardhome
`dirname $0`/create-dir.sh $base_data_dir/adguardhome/work
`dirname $0`/create-dir.sh $base_data_dir/adguardhome/conf

`dirname $0`/stop-container.sh adguardhome

rule1='Host(`adguardhome.'$domain'`)'
rule2='Host(`adguardhome-installer.'$domain'`)'
docker run -d --restart=always \
--name=adguardhome \
-m 50M \
-p 53:53 \
-p 53:53/udp \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
--network=$docker_network_name \
-v $base_data_dir/adguardhome/work:/opt/adguardhome/work \
-v $base_data_dir/adguardhome/conf:/opt/adguardhome/conf \
--label "traefik.http.routers.adguardhome.rule=$rule1" \
--label "traefik.http.routers.adguardhome.tls=true" \
--label "traefik.http.routers.adguardhome.service=adguardhome" \
--label "traefik.http.routers.adguardhome.tls.certresolver=traefik" \
--label "traefik.http.routers.adguardhome.tls.domains[0].main=adguardhome.$domain" \
--label "traefik.http.services.adguardhome.loadbalancer.server.port=80" \
--label 'traefik.http.routers.adguardhome-installer.rule=rule2' \
--label "traefik.http.routers.adguardhome-installer.tls=true" \
--label "traefik.http.routers.adguardhome-installer.service=adguardhome-installer" \
--label "traefik.http.routers.adguardhome-installer.tls.certresolver=traefik" \
--label "traefik.http.routers.adguardhome-installer.tls.domains[0].main=adguardhome-installer.$domain" \
--label "traefik.http.services.adguardhome-installer.loadbalancer.server.port=3000" \
--label "traefik.enable=true" \
adguard/adguardhome
printf "START_SUCCESS_LANG" "adguardhome"
echo ""
printf "$PLEASE_VISIT_ADDRESS_LANG $INIT_CONFIG_LANG" "$http_scheme://adguardhome-init.$domain"
echo ""
printf "$PLEASE_VISIT_ADDRESS_LANG" "$http_scheme://adguardhome.$domain"