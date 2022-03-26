#! /bin/bash
set -e
domain=$1
base_data_dir=$2
docker_network_name=$3
# echo "拉取镜像..."
# docker pull ttionya/vaultwarden-backup

`dirname $0`/create-dir.sh $base_data_dir/vaultwarden-backup
`dirname $0`/create-dir.sh $base_data_dir/vaultwarden-backup/config

echo "当前rclone配置如下: "
docker run --rm -it -v $base_data_dir/vaultwarden-backup/config:/config ttionya/vaultwarden-backup:latest rclone config show
read -p "是否需要修改配置文件？(y/n)" resetConfig

case $resetConfig in
    [Yy]* )
        docker run --rm -it \
        -v $base_data_dir/vaultwarden-backup/config:/config \
        ttionya/vaultwarden-backup:latest \
        rclone config
    ;;
    * )
        echo "不修改配置文件"
esac
echo "当前rclone配置如下: "

docker run --rm -it -v $base_data_dir/vaultwarden-backup/config:/config ttionya/vaultwarden-backup:latest rclone config show

echo "设置备份服务配置..."

MY_BACKUP_RCLONE_REMOTE=$(`$dirname $0`/get-args.sh MY_BACKUP_RCLONE_REMOTE 远程名称)

if [ -z "$MY_BACKUP_RCLONE_REMOTE" ]; then
    read -p "rclone远程名称: " MY_BACKUP_RCLONE_REMOTE
    if [ -z "$MY_BACKUP_RCLONE_REMOTE" ]; then
        echo "备份到的rclone远程名称为空,即将退出备份程序安装..."
        exit 0
    fi
    `dirname $0`/set-args.sh MY_BACKUP_RCLONE_REMOTE $MY_BACKUP_RCLONE_REMOTE
fi


BACKUP_ZIP_PASSWORD=$(`dirname $0`/get-args.sh BACKUP_ZIP_PASSWORD 压缩密码)
if [ -z "$BACKUP_ZIP_PASSWORD" ]; then
    read -p "请输入备份压缩文件的密码,可为空:" BACKUP_ZIP_PASSWORD
    if [ -z "$BACKUP_ZIP_PASSWORD" ]; then
        echo "备份压缩文件的密码为空"
    else
        `dirname $0`/set-args.sh "BACKUP_ZIP_PASSWORD" "$BACKUP_ZIP_PASSWORD"
    fi
fi

echo "备份压缩文件的密码为: $BACKUP_ZIP_PASSWORD"


echo "备份到的rclone远程目录为: $MY_BACKUP_RCLONE_REMOTE"

docker run -d \
--restart=always \
--network=$docker_network_name \
-m 50M \
--name vaultwarden_backup \
-v $base_data_dir/vaultwarden-backup/config:/config \
-v $base_data_dir/vaultwarden/data:/vaultwarden/data \
-e ZIP_PASSWORD=$BACKUP_ZIP_PASSWORD \
-e RCLONE_REMOTE_NAME="$MY_BACKUP_RCLONE_REMOTE" \
-e TZ=Asia/Shanghai \
-e LANG=zh_CN.UTF-8 \
ttionya/vaultwarden-backup:latest
echo "备份服务启动完成"