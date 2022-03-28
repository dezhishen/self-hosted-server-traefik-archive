#! /bin/bash
set -e
read -p "是否需要更新本项目[y/n]: " yn
case $yn in
    y|Y|yes|YES|Yes)
        echo "正在更新本项目"
        git pull
        ;;
    n|N|no|NO|No)
        echo "本项目不需要更新"
        ;;
    *)
        echo "输入错误，默认为不更新"
        ;;
esac

domain=`./scripts/get-args.sh domain "主域名(如 baidu.com或者app.baidu.com)"`
if [ -z "$domain" ]; then
    read -p "请输入主域名(如 baidu.com或者app.baidu.com):" domain
    if [ -z "$domain" ]; then
        echo "主域名不能为空"
        exit 0
    else
        ./scripts/set-args.sh domain $domain
    fi
fi
base_data_dir=`./scripts/get-args.sh base_data_dir "数据目录(如 /docker_data)"`
if [ -z "$base_data_dir" ]; then
    read -p "请输入数据目录(如 /docker_data):" base_data_dir
    if [ -z "$base_data_dir" ]; then
        echo "数据目录为空,使用默认值 /docker_data"
        base_data_dir=/docker_data
    fi
    ./scripts/set-args.sh base_data_dir $base_data_dir
fi

docker_network_name=`./scripts/get-args.sh docker_network_name "Docker网络名称(如 traefik)"`

if [ -z "$docker_network_name" ]; then
    read -p "请输入Docker网络名称(如 traefik):" docker_network_name
    if [ -z "$docker_network_name" ]; then
        echo "Docker网络名称为空,使用默认值 traefik"
        docker_network_name=traefik
    fi
    docker_network_name=traefik
    ./scripts/set-args.sh docker_network_name $docker_network_name
fi

echo "开始创建根目录"

if [ ! -d $base_data_dir ]; then
    mkdir -p $base_data_dir
    printf "创建成功%s" "$base_data_dir"
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
sh ./scripts/install-ddns.sh $domain $base_data_dir $docker_network_name

read -p "是否需要安装(重装) traefik [y/n]: " yn

case $yn in
    y|Y|yes|YES|Yes)
    sh ./scripts/install-traefik.sh $domain $base_data_dir $docker_network_name
esac

read -p "是否需要安装/重装 adguardhome? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-adguardhome.sh $domain $base_data_dir $docker_network_name
    ;;
esac

read -p "是否需要安装/重装 aliyundrive-webdav? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-aliyundrive-webdav.sh $domain $base_data_dir $docker_network_name
    ;;
esac

read -p "是否需要安装/重装 aria2? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-aria2.sh $domain $base_data_dir $docker_network_name
        ;;
esac
read -p "是否需要安装/重装 emby? [y/n]:" yn

case $yn in
    [Yy]* )
        sh ./scripts/install-emby.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 fastgithub? [y/n]:" yn

case $yn in
    [Yy]* )
        sh ./scripts/install-fastgithub.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 flaresolverr ? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-flaresolverr.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 filebrowser ? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-filebrowser.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 freshrss [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-freshrss.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 jellyfin? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-jellyfin.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 lidarr? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-lidarr.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 nzbget? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-nzbget.sh $domain $base_data_dir $docker_network_name
        ;;
esac



read -p "是否需要安装/重装 ombi? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-ombi.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 portainer? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-portainer.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 prowlarr? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-prowlarr.sh $domain $base_data_dir $docker_network_name
        ;;
esac


read -p "是否需要安装/重装 qbittorrent ? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-qbittorrent.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 radarr? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-radarr.sh $domain $base_data_dir $docker_network_name
        ;;
esac


read -p "是否需要安装/重装 samba? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-samba.sh $domain $base_data_dir $docker_network_name
        ;;
esac


read -p "是否需要安装/重装 sonarr ? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-sonarr.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 vaultwarden [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-vaultwarden.sh $domain $base_data_dir $docker_network_name
        ;;
esac

read -p "是否需要安装/重装 webdav? [y/n]:" yn
case $yn in
    [Yy]* )
        sh ./scripts/install-webdav.sh $domain $base_data_dir $docker_network_name
        ;;
esac