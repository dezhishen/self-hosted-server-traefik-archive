# !/bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

`dirname $0`/create-dir.sh $base_data_dir/adguardhome
`dirname $0`/create-dir.sh $base_data_dir/adguardhome/work
`dirname $0`/create-dir.sh $base_data_dir/adguardhome/conf


# rule=Host(`adguardhome.'$domain'`)'
`dirname $0`/stop-container.sh adguardhome
# 是否为第一次安装
if [ ! -f "$base_data_dir/adguardhome/conf/AdGuardHome.yaml" ]; then
    docker run -d --restart=always \
        --name=adguardhome \
        -m 50M \
        --network=$docker_network_name \
        --network-alias=adguardhome \
        -p 53:53 -p 53:53/udp \
        -e TZ="Asia/Shanghai" \
        -e LANG="zh_CN.UTF-8" \
        -v $base_data_dir/adguardhome/work:/opt/adguardhome/work \
        -v $base_data_dir/adguardhome/conf:/opt/adguardhome/conf \
        --label 'traefik.http.routers.adguardhome.rule=Host(`adguardhome.'$domain'`)' \
        --label "traefik.http.routers.adguardhome.tls=true" \
        --label "traefik.http.routers.adguardhome.tls.certresolver=traefik" \
        --label "traefik.http.routers.adguardhome.tls.domains[0].main=adguardhome.$domain" \
        --label "traefik.http.services.adguardhome.loadbalancer.server.port=3000" \
        --label "traefik.enable=true" \
    adguard/adguardhome
    echo "请访问 https://adguardhome.$domain 初始化安装"
    echo "初始化请设置端口为80,随后重新安装"
else
    bind_port=`cat $base_data_dir/adguardhome/conf/AdGuardHome.yaml | grep -E '^bind_port:' | awk -F ':' '{print $2}' | sed 's/ //g'`
    docker run -d --restart=always \
        --name=adguardhome \
        -m 50M \
        --network=$docker_network_name \
        --network-alias=adguardhome \
        -p 53:53 -p 53:53/udp \
        -e TZ="Asia/Shanghai" \
        -e LANG="zh_CN.UTF-8" \
        -v $base_data_dir/adguardhome/work:/opt/adguardhome/work \
        -v $base_data_dir/adguardhome/conf:/opt/adguardhome/conf \
        --label 'traefik.http.routers.adguardhome.rule=Host(`adguardhome.'$domain'`)' \
        --label "traefik.http.routers.adguardhome.tls=true" \
        --label "traefik.http.routers.adguardhome.tls.certresolver=traefik" \
        --label "traefik.http.routers.adguardhome.tls.domains[0].main=adguardhome.$domain" \
        --label "traefik.http.services.adguardhome.loadbalancer.server.port=$bind_port" \
        --label "traefik.enable=true" \
    adguard/adguardhome
    echo "请访问 http://adguardhome.$domain"
fi