#! /bin/bash
domain=$1
base_data_dir=$2
docker_network_name=$3

SAMBA_USER_NAME=$(`dirname $0`/get-args.sh SAMBA_USER_NAME "smb's userName")
if [ ! -n "$SAMBA_USER_NAME" ]; then
    ## input your SAMBA_USER_NAME,or defaut is amdin
    read -p "请输入用户名默认,admin" SAMBA_USER_NAME
    if [ ! -n "$SAMBA_USER_NAME" ]; then
        SAMBA_USER_NAME="amdin"
    fi
    `dirname $0`/set-args.sh SAMBA_USER_NAME $SAMBA_USER_NAME
fi

echo "user name:$SAMBA_USER_NAME"
SAMBA_USER_PASSWORD=$(`dirname $0`/get-args.sh SAMBA_USER_PASSWORD "smb's userPassword" )
if [ ! -n "$SAMBA_USER_PASSWORD" ]; then
    ## input your SAMBA_USER_PASSWORD,or random
    read -p "请输入密码，为空则自动生成" SAMBA_USER_PASSWORD
    if [ ! -n "$SAMBA_USER_PASSWORD" ]; then
        SAMBA_USER_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
    fi
    `dirname $0`/set-args.sh SAMBA_USER_PASSWORD $SAMBA_USER_PASSWORD
fi
echo "password: $SAMBA_USER_PASSWORD"

`dirname $0`/stop-container.sh samba

echo "即将启动samba"

docker run -d --restart=always --name=samba \
--network=$docker_network_name \
-p 139:139 -p 445:445 \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-e SHARE="www;/mount/;yes;no;no;all;none" \
-e USER="$SAMBA_USER_NAME;$SAMBA_USER_PASSWORD" \
-e USERID=$(id -u) \
-e GROUPID=$(id -g) \
-v $base_data_dir/public:/mount \
dperson/samba

echo "samba启动完成"
echo "请调整防火墙规则，允许内网访问 139/445 端口"
# 调整防火墙规则，允许内网访问 139/445 端口
echo "修改下方命令的192.168.31.0/24段，替换为你的内网IP段"
echo "如 sudo ufw from 192.168.31.0/24 to any port 139,445 proto tcp"
