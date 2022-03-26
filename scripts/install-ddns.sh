#! /bin/bash
set -e

domain=$1
base_data_dir=$2
docker_network_name=$3

CF_API_KEY=$(`dirname $0`/get-args.sh "CF_API_KEY" "cloudflare的apiKey")
if [ -z "$CF_API_KEY" ]; then
    read -p "请输入cloudflare的apiKey: " CF_API_KEY
    if [ -z "$CF_API_KEY" ]; then
        echo "cloudflare的apiKey不能为空"
        exit 1
    fi
    `dirname $0`/set-args.sh CF_API_KEY $CF_API_KEY
    
fi
CF_Token=$(`dirname $0`/get-args.sh "CF_Token" "cloudflare的token")
if [ -z "$CF_Token" ]; then
    read -p "请输入cloudflare的token: " CF_Token
    if [ -z "$CF_Token" ]; then
        echo "cloudflare的token不能为空"
        exit 1
    fi
    `dirname $0`/set-args.sh CF_Token $CF_Token
fi

CF_Zone_ID=$(`dirname $0`/get-args.sh CF_Zone_ID cloudflare的zoneID)
if [ -z "$CF_Zone_ID" ]; then
    read -p "请输入cloudflare的zoneID: " CF_Zone_ID
    if [ -z "$CF_Zone_ID" ]; then
        echo "cloudflare的zoneID不能为空"
        exit 1
    fi
    `dirname $0`/set-args.sh CF_Zone_ID $CF_Zone_ID
fi
CF_EMAIL=$(`dirname $0`/get-args.sh CF_EMAIL cloudflare的email)
if [ -z "$CF_EMAIL" ]; then
    read -p "请输入cloudflare的email: " CF_EMAIL
    if [ -z "$CF_EMAIL" ]; then
        echo "cloudflare的email不能为空"
    fi
    `dirname $0`/set-args.sh CF_EMAIL $CF_EMAIL
fi

ddns_ipv4_enabled=$(`dirname $0`/get-args.sh "ddns_ipv4_enabled" "是否启用ipv4")
if [ -z "$ddns_ipv4_enabled" ]; then
    read -p "是否启用ipv4[y/n]: " ddns_ipv4_enabled
    case $ddns_ipv4_enabled in
        y|Y|yes|YES|Yes)
            ddns_ipv4_enabled=true
            ;;
        n|N|no|NO|No)
            ddns_ipv4_enabled=false
            ;;
        *)
            echo "输入错误，默认为不启用"
            ddns_ipv4_enabled=false
            ;;
    esac
    `dirname $0`/set-args.sh ddns_ipv4_enabled $ddns_ipv4_enabled
fi
ddns_ipv6_enabled=$(`dirname $0`/get-args.sh "ddns_ipv6_enabled" "是否启用ipv6")
if [ -z "$ddns_ipv6_enabled" ]; then
    read -p "是否启用ipv6[y/n]: " ddns_ipv6_enabled
    case $ddns_ipv6_enabled in
        y|Y|yes|YES|Yes)
            ddns_ipv6_enabled=true
            ;;
        n|N|no|NO|No)
            ddns_ipv6_enabled=false
            ;;
        *)
            echo "输入错误，默认为不启用"
            ddns_ipv6_enabled=false
            ;;
    esac
    `dirname $0`/set-args.sh ddns_ipv6_enabled $ddns_ipv6_enabled
fi
echo "即将部署的配置如下: "
echo "cloudflare的apiKey: $CF_API_KEY"
echo "cloudflare的token: $CF_Token"
echo "cloudflare的zoneID: $CF_Zone_ID"
echo "cloudflare的email: $CF_EMAIL"


echo "正在复制配置文件"
`dirname $0`/create-dir.sh $base_data_dir/ddns
cp -f `dirname $0`/../ddns/config.json $base_data_dir/ddns/config.json
sed -i `echo "s/\\$ipv4/$ddns_ipv4_enabled/g"` $base_data_dir/ddns/config.json
sed -i `echo "s/\\$ipv6/$ddns_ipv6_enabled/g"` $base_data_dir/ddns/config.json
sed -i `echo "s/\\$api_key/$CF_API_KEY/g"` $base_data_dir/ddns/config.json
sed -i `echo "s/\\$api_token/$CF_Token/g"` $base_data_dir/ddns/config.json
sed -i `echo "s/\\$zone_id/$CF_Zone_ID/g"` $base_data_dir/ddns/config.json
sed -i `echo "s/\\$account_email/$CF_EMAIL/g"` $base_data_dir/ddns/config.json


`dirname $0`/stop-container.sh ddns
 
echo "将以host网络模式启动ddns..."
docker run --name=ddns \
--network=host \
-u `id -u`:`id -g` \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
--restart=always -d -m 50M \
-v $base_data_dir/ddns/config.json:/config.json \
timothyjmiller/cloudflare-ddns:latest

echo "安装完成"

