#! /bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3
`dirname $0`/stop-container.sh aliyundrive-webdav

`dirname $0`/create-dir.sh $base_data_dir/aliyundrive-webdav

ALIYUNDRIVE_RFRESH_TOKEN=`cat $base_data_dir/aliyundrive-webdav/refresh_token`
if [ -z "$ALIYUNDRIVE_RFRESH_TOKEN" ]; then
    read -p "请输入aliyundrive的refresh_token" ALIYUNDRIVE_RFRESH_TOKEN
    if [ -z "$ALIYUNDRIVE_RFRESH_TOKEN" ]; then
        echo "aliyundrive的refresh_token不能为空"
        exit 0
    else
        echo $ALIYUNDRIVE_RFRESH_TOKEN > $base_data_dir/aliyundrive-webdav/refresh_token
    fi
fi

ALIYUNDRIVE_WEBDAV_AUTH_USERNAME=$(`dirname $0`/get-args.sh ALIYUNDRIVE_WEBDAV_AUTH_USERNAME aliyundrive-webdav的用户名)
if [ -z "$ALIYUNDRIVE_WEBDAV_AUTH_USERNAME" ]; then
    read -p "请输入aliyundrive-webdav的用户名: " ALIYUNDRIVE_WEBDAV_AUTH_USERNAME
    if [ -z "$ALIYUNDRIVE_WEBDAV_AUTH_USERNAME" ]; then
        echo "aliyundrive-webdav的用户名为空,使用默认值,admin"
    fi
    `dirname $0`/set-args.sh ALIYUNDRIVE_WEBDAV_AUTH_USERNAME $ALIYUNDRIVE_WEBDAV_AUTH_USERNAME
fi

ALIYUNDRIVE_WEBDAV_PASSWORD=$(`dirname $0`/get-args.sh ALIYUNDRIVE_WEBDAV_PASSWORD aliyundrive-webdav的密码_
if [ -z "$ALIYUNDRIVE_WEBDAV_PASSWORD" ]; then
    read -p "请输入aliyundrive-webdav的密码: " ALIYUNDRIVE_WEBDAV_PASSWORD
    if [ -z "$ALIYUNDRIVE_WEBDAV_PASSWORD" ]; then
        echo "aliyundrive-webdav的密码为空,即将随机生成"
        ALIYUNDRIVE_WEBDAV_PASSWORD=`$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)`
    fi
    `dirname $0`/set-args.sh ALIYUNDRIVE_WEBDAV_PASSWORD $ALIYUNDRIVE_WEBDAV_PASSWORD
    echo "aliyundrive-webdav的密码: $ALIYUNDRIVE_WEBDAV_PASSWORD"
fi

rule='Host(`aliyundrive-webdav.'$domain'`)'
echo "启动aliyundrive-webdav容器"
docker run --name=aliyundrive-webdav \
--restart=always -m 128M \
--network=$docker_network_name \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e REFRESH_TOKEN=$ALIYUNDRIVE_RFRESH_TOKEN \
-e WEBDAV_AUTH_USER=$ALIYUNDRIVE_WEBDAV_AUTH_USERNAME \
-e WEBDAV_AUTH_PASSWORD=$ALIYUNDRIVE_WEBDAV_PASSWORD \
-v $base_data_dir/aliyundrive-webdav:/etc/aliyundrive-webdav \
--label "traefik.http.routers.aliyundrive-webdav.rule=$rule" \
--label "traefik.http.routers.aliyundrive-webdav.tls=true" \
--label "traefik.http.routers.aliyundrive-webdav.tls.certresolver=traefik" \
--label "traefik.http.routers.aliyundrive-webdav.tls.domains[0].main=aliyundrive-webdav.$domain" \
--label "traefik.http.services.aliyundrive-webdav.loadbalancer.server.port=8080" \
--label "traefik.enable=true" \
messense/aliyundrive-webdav

echo "启动aliyundrive-webdav容器完成"