#! /bin/bash
set -e
echo "开始更新本项目"
git pull

domain=`./scripts/get-args.sh domain "主域名(如 baidu.com或者app.baidu.com)"`
if [ -z "$domain" ]; then
    read -p "请输入主域名(如 baidu.com或者app.baidu.com)：" domain
    if [ -z "$domain" ]; then
        echo "主域名不能为空"
        exit 0
    else
        ./scripts/set-args.sh domain $domain
    fi
fi
base_data_dir=`./scripts/get-args.sh base_data_dir "数据目录(如 /docker_data)"`
if [ -z "$base_data_dir" ]; then
    echo "数据目录为空,使用默认值 /docker_data"
    base_data_dir=/docker_data
    `./scripts/set-args.sh base_data_dir "$base_data_dir"`
    exit 0
fi

docker_network_name=`./scripts/get-args.sh docker_network_name "Docker网络名称(如 ingress)"`

if [ -z "$docker_network_name" ]; then
    echo "Docker网络名称为空,使用默认值 ingress"
    `./scripts/set-args.sh docker_network_name ingress`
    docker_network_name=ingress
fi

echo "开始创建根目录"

if [ ! -d $base_data_dir ]; then
    mkdir -p $base_data_dir
    printf "$CREATE_BASE_DATA_DIR_SUCCESS_LANG" "$base_data_dir"
else
    read -p "文件目录已存在,是否备份 [y/n]:" yn
    case $yn in
        [Yy]* )
            backup_dir=$base_data_dir.bak.$(date +%Y%m%d%H%M%S)
            cp -r $base_data_dir $backup_dir
            printf "备份成功,备份目录: %s" "$base_data_dir $backup_dir"
            ;;
        [Nn]* )
            ;;
        * )
            ;;
    esac
fi

echo "开始创建网络"
# check if docker network $docker_network_name exist
docker_network_exists=$(docker network ls | grep $docker_network_name | awk '{print $2}')
if [ -n "$docker_network_exists" ]; then
    echo "容器网络 $docker_network_name 已存在"
    docker_network_exists=y
else
    docker network create $docker_network_name
    echo "容器网络 $docker_network_name 创建成功"
    docker_network_exists=n
fi

echo "开始部署ddns服务"
./scripts/install-ddns.sh $domain $base_data_dir $docker_network_name

echo "即将部署traefik"
./scripts/install-traefik.sh $domain $base_data_dir $docker_network_name

read -p "是否需要部署adguardhome? [y/n]:" yn
case $yn in
    [Yy]* )
        ./scripts/install-adguardhome.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要部署portainer? [y/n]:" yn
case $yn in
    [Yy]* )
        ./scripts/install-portainer.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要部署aria2? [y/n]:" yn
case $yn in
    [Yy]* )
        ./scripts/install-aria2.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要部署vaultwarden [y/n]:" yn
case $yn in
    [Yy]* )
        ./scripts/install-vaultwarden.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要部署webdav [y/n]:" yn
case $yn in
    [Yy]* )
        ./scripts/install-webdav.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要部署freshrss [y/n]:" yn
case $yn in
    [Yy]* )
        ./scripts/install-freshrss.sh $domain $base_data_dir $docker_network_name
        ;;
esac