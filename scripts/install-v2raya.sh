# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

docker_container_name=v2raya
docker ps -a -q --filter "name=$docker_container_name" | grep -q . && docker rm -fv $docker_container_name

docker run -d \
    --name v2raya \
    --restart=always \
    -e LANG=C.UTF-8 \
    -e TZ=Asia/Shanghai \
    --network=$docker_network_name \
    --network-alias=v2raya \
    --label 'traefik.http.routers.v2raya.rule=Host(`v2raya'.$domain'`)' \
    --label 'traefik.http.routers.v2raya.priority=1000' \
    --label 'traefik.http.routers.v2raya.entrypoints=web' \
    --label "traefik.http.services.v2raya.loadbalancer.server.port=2017" \
    --label 'traefik.http.routers.v2raya-proxy.rule=Host(`v2raya-proxy'.$domain'`)' \
    --label "traefik.http.routers.v2raya-proxy.tls=false" \
    --label "traefik.http.services.v2raya-proxy.loadbalancer.server.port=20171" \
    --label 'traefik.http.routers.v2raya-proxy-rule.rule=Host(`v2raya-proxy-rule'.$domain'`)' \
    --label "traefik.http.routers.v2raya-proxy-rule.tls=false" \
    --label "traefik.http.services.v2raya-proxy-rule.loadbalancer.server.port=20172" \
    --label "traefik.enable=true" \
    -v $base_data_dir/v2raya:/etc/v2raya \
  mzz2017/v2raya
