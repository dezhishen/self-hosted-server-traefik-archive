# !/bin/sh
TARGETARCH=$1
# 如果TARGETARCH为 linux/amd64 则返回 x64
# 如果TARGETARCH为 linux/arm64 则返回 arm64
# 如果TARGETARCH为空 则返回 x64
case $TARGETARCH in
    amd64 )
        arch_version="x64"
        ;;
    arm64 )
        arch_version="arm64"
        ;;
    * )
        arch_version="x64"
        ;;
esac
wget -O latest.json https://api.github.com/repos/dotnetcore/FastGithub/releases/latest  \
&& app_version=`cat latest.json | grep tag_name | cut -d '"' -f 4` 
echo "当前版本: $app_version"
echo "当前架构: $arch_version"
download_url=https://ghproxy.com/https://github.com/dotnetcore/FastGithub/releases/download/$app_version/fastgithub_linux-$arch_version.zip
echo "下载路径:  $download_url"
wget -O fastgithub.zip $download_url
unzip fastgithub.zip -d ./
mv ./fastgithub_linux-$arch_version ./fastgithub