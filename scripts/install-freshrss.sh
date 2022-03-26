#! /bin/bash
docker run -d --restart unless-stopped \
--log-opt max-size=10m -m 50M \
-v $base_data_dir/freshrss/data:/var/www/FreshRSS/data \
-v $base_data_dir/extensions:/var/www/FreshRSS/extensions   \
-e 'CRON_MIN=4,34' -e TZ=Asia/Shanghai \
--network=$docker_network_name \
--name freshrss \
--label 'traefik.http.routers.freshrss.rule=Host(`freshrss.$domain`)' \
--label "traefik.http.routers.freshrss.tls=true" \
--label "traefik.http.routers.freshrss.tls.certresolver=traefik" \
--label "traefik.http.routers.freshrss.tls.domains[0].main=freshrss.$domain" \
--label "traefik.http.services.freshrss.loadbalancer.server.port=80" \
--label "traefik.enable=true" \
 freshrss/freshrss:arm