# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3
`dirname $0`/create-docker-macvlan-network.sh
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
    --label 'traefik.http.routers.v2raya.service=v2raya' \
    --label "traefik.http.routers.v2raya.tls=true" \
    --label "traefik.http.routers.v2raya.tls.certresolver=traefik" \
    --label "traefik.http.routers.v2raya.tls.domains[0].main=v2raya.$domain" \
    --label "traefik.http.services.v2raya.loadbalancer.server.port=2017" \
    --label "traefik.enable=true" \
    -v $base_data_dir/v2raya:/etc/v2raya \
  mzz2017/v2raya

docker_macvlan_network_name=$(`dirname $0`/get-args.sh docker_macvlan_network_name "macvlan的网络名")

docker network connect $docker_network_name v2raya


echo "加入到macvlan网络中..."
docker network connect $docker_macvlan_network_name v2raya --alias v2raya-macvlan
