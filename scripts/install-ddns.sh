#! /bin/bash
set -e

domain=$1
base_data_dir=$2
docker_network_name=$3

CF_Account_ID= `dirname $0`/get-args.sh CF_Account_ID cloudflare的账户ID
if [ -z "$CF_Account_ID" ]; then
    read -p "请输入cloudflare的账户ID: " CF_Account_ID
    if [ -z "$CF_Account_ID" ]; then
        echo "cloudflare的账户ID不能为空"
        exit 1
    else
        `dirname $0`/set-args.sh CF_Account_ID $CF_Account_ID
    fi
fi
CF_Token= `dirname $0`/get-args.sh CF_Token cloudflare的token
if [ -z "$CF_Token" ]; then
    read -p "请输入cloudflare的token: " CF_Token
    if [ -z "$CF_Token" ]; then
        echo "cloudflare的token不能为空"
        exit 1
    else
        `dirname $0`/set-args.sh CF_Token $CF_Token
    fi
fi

CF_Zone_ID= `dirname $0`/get-args.sh CF_Zone_ID cloudflare的zoneID
if [ -z "$CF_Zone_ID" ]; then
    read -p "请输入cloudflare的zoneID: " CF_Zone_ID
    if [ -z "$CF_Zone_ID" ]; then
        echo "cloudflare的zoneID不能为空"
        exit 1
    else
        `dirname $0`/set-args.sh CF_Zone_ID $CF_Zone_ID
    fi
fi
CF_EMAIL= `dirname $0`/get-args.sh CF_EMAIL cloudflare的email
if [ -z "$CF_EMAIL" ]; then
    read -p "请输入cloudflare的email: " CF_EMAIL
    if [ -z "$CF_EMAIL" ]; then
        echo "cloudflare的email不能为空"
        exit 1
    else
        `dirname $0`/set-args.sh CF_EMAIL $CF_EMAIL
    fi
fi

echo "即将部署的配置如下: "
echo "cloudflare的账户ID: $CF_Account_ID"
echo "cloudflare的token: $CF_Token"
echo "cloudflare的zoneID: $CF_Zone_ID"
echo "cloudflare的email: $CF_EMAIL"

echo "正在复制配置文件"
`dirname $0`/create-dir.sh $base_data_dir/ddns

cp -f `dirname $0`/../ddns/config.json $base_data_dir/ddns/config.json

echo "将以host网络模式启动ddns..."
docker run --name=ddns \
--network=host \
-u `id -u`:`id -g`\
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
--restart=always -d -m 50M \
-v $base_data_dir/ddns/config.json:/config.json \
timothyjmiller/cloudflare-ddns:latest
echo "安装完成"

