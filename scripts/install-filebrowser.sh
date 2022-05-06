#! /bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3
`dirname $0`/create-dir.sh $base_data_dir/filebrowser

`dirname $0`/stop-container.sh filebrowser
if [ ! -f $base_data_dir/filebrowser/filebrowser.db ];then
    echo "filebrowser.db 不存在，复制./filebrowser/filebrowser.db到$base_data_dir/filebrowser/filebrowser.db"
    cp  -f `dirname $0`/../filebrowser/filebrowser.db $base_data_dir/filebrowser/filebrowser.db 
else
    echo "filebrowser.db 已存在，不需要复制,filebrowser.db already exist"
fi
if [ ! -f $base_data_dir/filebrowser/filebrowser.json ];then
    echo "filebrowser.json 不存在，复制./filebrowser/filebrowser.json到$base_data_dir/filebrowser/filebrowser.json"
    cp  -f `dirname $0`/../filebrowser/filebrowser.json $base_data_dir/filebrowser/filebrowser.json
else
    echo "filebrowser.json 已存在，不需要复制,filebrowser.json already exist"
fi

docker run -d --restart=always --name=filebrowser \
-m 128M \
--health-cmd "curl -f http://localhost:8080/health || exit 1" \
--network=$docker_network_name --network-alias=filebrowser \
-u $(id -u):$(id -g) \
-v $base_data_dir:/srv \
-v "$base_data_dir/filebrowser/filebrowser.db:/database.db" \
-v "$base_data_dir/filebrowser/filebrowser.json:/.filebrowser.json" \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
--label 'traefik.http.routers.filebrowser.rule=Host(`filebrowser.'$domain'`)' \
--label "traefik.http.routers.filebrowser.tls=true" \
--label "traefik.http.routers.filebrowser.tls.certresolver=traefik" \
--label "traefik.http.routers.filebrowser.tls.domains[0].main=filebrowser.$domain" \
--label "traefik.http.services.filebrowser.loadbalancer.server.port=8080" \
--label "traefik.enable=true" \
 filebrowser/filebrowser
