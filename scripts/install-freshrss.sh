#! /bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3
`dirname $0`/stop-container.sh freshrss

rule='Host(`freshrss.'$domain'`)'
read -p "是否使用arm机器[y/n]: " use_arm
case $use_arm
in
    y|Y|yes|YES|Yes)
        echo "使用arm机器"
        image=freshrss/freshrss:arm
    ;;
    n|N|no|NO|No)
        echo "使用x86机器"
        image=freshrss/freshrss
    ;;
    *)
        echo "默认使用x86机器"
        image=freshrss/freshrss
    ;;
esac

docker run -d --restart unless-stopped \
--log-opt max-size=10m -m 50M \
-v $base_data_dir/freshrss/data:/var/www/FreshRSS/data \
-v $base_data_dir/extensions:/var/www/FreshRSS/extensions   \
-e 'CRON_MIN=4,34' -e TZ=Asia/Shanghai \
--network=$docker_network_name --network-alias=freshrss \
--name freshrss \
--label "traefik.http.routers.freshrss.rule=$rule" \
--label "traefik.http.routers.freshrss.tls=true" \
--label "traefik.http.routers.freshrss.tls.certresolver=traefik" \
--label "traefik.http.routers.freshrss.tls.domains[0].main=freshrss.$domain" \
--label "traefik.http.services.freshrss.loadbalancer.server.port=80" \
--label "traefik.enable=true" \
 $image