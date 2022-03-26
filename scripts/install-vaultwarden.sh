#! /bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3


`dirname $0`/create-dir.sh $base_data_dir/vaultwarden
`dirname $0`/create-dir.sh $base_data_dir/vaultwarden/data

`dirname $0`/stop-container.sh vaultwarden
rule='Host(`vaultwarden.'$domain'`)'
docker run -d --name vaultwarden \
--restart=always \
-e TZ="Asia/Shanghai" \
-e SIGNUPS_ALLOWED="false" \
-m 50M \
-e LANG="zh_CN.UTF-8" \
-u $(id -u):$(id -g) \
--network=$docker_network_name \
-v $base_data_dir/vaultwarden/data:/data/  \
--label "traefik.http.routers.vaultwarden.rule=$rule" \
--label "traefik.http.routers.vaultwarden.tls=true" \
--label "traefik.http.routers.vaultwarden.tls.certresolver=traefik" \
--label "traefik.http.routers.vaultwarden.tls.domains[0].main=vaultwarden.$domain" \
--label "traefik.http.services.vaultwarden.loadbalancer.server.port=80" \
--label "traefik.enable=true" \
vaultwarden/server:latest

read -p "是否需要安装备份服务？(y/n)" yn
# 如果yn不为y|Y，则退出
if [ "$yn" != "y" ] || [ "$yn" != "Y" ];then
    echo "退出安装"
    exit 0
fi

echo "拉取镜像..."
docker pull ttionya/vaultwarden-backup

`dirname $0`/create-dir.sh $base_data_dir/vaultwarden-backup
`dirname $0`/create-dir.sh $base_data_dir/vaultwarden-backup/config

config_text=`docker run --rm -it -v $base_data_dir/vaultwarden-backup/config:/config  ttionya/vaultwarden-backup:latest rclone show config`
if [ -z "$config_text" ]; then
    echo "当前没有配置文件,即将启动rclone配置引导"
    docker run --rm -it \
        -v $base_data_dir/vaultwarden-backup/config:/config \
        ttionya/vaultwarden-backup:latest \
        rclone config
else
    echo "当前rclone配置如下: "
    echo "$config_text"
    read -p "是否需要修改配置文件？(y/n)" resetConfig
    case $resetConfig in
        [Yy]* )
            docker run --rm -it \
            -v $base_data_dir/vaultwarden-backup/config:/config \
            ttionya/vaultwarden-backup:latest \
            rclone config
        ;;
    esac
fi
for i in {0..5} ;
do
    echo "读取配置文件:($i/5)..."
    config_text=`docker run --rm -it -v $base_data_dir/vaultwarden-backup/config:/config  ttionya/vaultwarden-backup:latest rclone show config`
    if [ -z "$config_text" ]; then
        echo "没有配置文件,即将重启rclone配置引导"
        docker run --rm -it \
        -v $base_data_dir/vaultwarden-backup/config:/config \
        ttionya/vaultwarden-backup:latest \
        rclone config
    fi
done 
if [ -z "$config_text" ]; then
    echo "配置文件未找到,即将退出备份程序安装..."
    exit 0
fi

echo "即将启动备份服务..."

vaultwarden_backup_zip_password=`$dirname $0`/get-args.sh vaultwarden_backup_zip_password 备份压缩文件的密码
if [ -z "$vaultwarden_backup_zip_password" ]; then
    echo "备份压缩文件的密码为空"
else
    echo "备份压缩文件的密码为: $vaultwarden_backup_zip_password"
fi

vaultwarden_backup_rclone_remote=`$dirname $0`/get-args.sh vaultwarden_backup_rclone_remote 备份到的rclone远程名称

if [ -z "$vaultwarden_backup_rclone_remote" ]; then
    echo "当前rclone的配置如下:"
    echo "$config_text"
    read -p "请输入备份到的rclone远程名称: " vaultwarden_backup_rclone_remote
    if [ -z "$vaultwarden_backup_rclone_remote" ]; then
        echo "备份到的rclone远程名称为空,即将退出备份程序安装..."
        exit 0
    fi
    `dirname $0`/set-args.sh vaultwarden_backup_rclone_remote $vaultwarden_backup_rclone_remote
else
    echo "备份到的rclone远程目录为: $vaultwarden_backup_rclone_remote"
fi
echo "即将启动备份服务..."
docker run -d \
--restart=always \
-m 50M \
--name vaultwarden_backup \
-v $base_data_dir/vaultwarden-backup/config:/config \
-v $base_data_dir/vaultwarden/data:/vaultwarden/data \
-e ZIP_PASSWORD=$vaultwarden_backup_zip_password \
-e RCLONE_REMOTE_NAME="$vaultwarden_backup_rclone_remote" \
-e TZ=Asia/Shanghai \
-e LANG=zh_CN.UTF-8 \
ttionya/vaultwarden-backup:latest
echo "备份服务启动完成"