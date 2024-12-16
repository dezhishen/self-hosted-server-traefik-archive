# 自托管服务脚本
**新的项目** ===> https://github.com/dezhishen/self-hosted-server-traefik

[![](https://img.shields.io/github/license/dezhishen/self-hosted-server-traefik.svg?style=for-the-badge&logo=github)](./LICENSE)
[![](https://img.shields.io/github/stars/dezhishen/self-hosted-server-traefik.svg?style=for-the-badge&logo=github)](https://github.com/dezhishen/self-hosted-server-traefik/stargazers)
[![](https://img.shields.io/github/forks/dezhishen/self-hosted-server-traefik.svg?style=for-the-badge&logo=github)](https://github.com/dezhishen/self-hosted-server-traefik/network/members)
[![](https://img.shields.io/github/contributors/dezhishen/self-hosted-server-traefik.svg?style=for-the-badge&logo=github)](https://github.com/dezhishen/self-hosted-server-traefik/graphs/contributors)

[![](https://img.shields.io/github/commit-activity/m/dezhishen/self-hosted-server-traefik?logo=github&style=for-the-badge)](https://github.com/dezhishen/self-hosted-server-traefik/graphs/commit-activity)
[![](https://img.shields.io/github/last-commit/dezhishen/self-hosted-server-traefik.svg?style=for-the-badge&logo=github)](https://github.com/dezhishen/self-hosted-server-traefik/commits)

[![](https://img.shields.io/static/v1?label=&message=Docker&style=for-the-badge&color=blue&logo=Docker)](https://www.docker.com/)
[![](https://img.shields.io/static/v1?label=&message=traefik&style=for-the-badge&color=blue&logo=Traefik%20Mesh)](https://github.com/traefik/traefik/)
[![](https://img.shields.io/static/v1?label=&message=cloudflare&style=for-the-badge&color=blue&logo=Cloudflare)](https://www.cloudflare.com/)
## 项目目标
ddns+cloudflare(免备案，免费防御体系) 实现外网访问的个人应用
## 要求
- 一个域名，不管多少级
- 机器（树莓派等）
    - 机器需要长期开启
    - 机器需要有防火墙
- 机器具有至少一个公网地址（ipv4/ipv6）
    - 推荐ipv6,获取方式更简便
    - ipv6的获取方式-请使用搜索引擎搜索自己的光猫型号+ipv6
        - 光猫设置为桥接
        - 开启光猫的ipv6
        - 路由器开启ipv6
        - 路由器拨号
## 风险
- **因使用本项目造成的任何后果与本人无关**
- **请仔细阅读防火墙配置**
- **请仔细阅读注意事项**
- **曾出现运营商关闭账户的情况**
    - 通过防火墙协议,只允许cloudflare机器访问,即可避免被运营商扫描到端口
## 注意事项
### 环境
- 在`树莓派4B+debian`长期运行
- 但一般而言只需要支持docker都可以完成应用的安装
### 备份
- 请自行备份 docker挂载的根目录
- vaultwarden 可搭配备份服务一起运行
### 网络
#### 部分地区的宽带会封闭443/80等端口
- 请自行修改traefik的entryPoint设置,或者修改docker映射的端口
#### 局域网设置
##### dns
- adguardhome 界面初始化后需要重新安装
- 将内网的路由器ddns设置为机器的ipv4地址
- adguardhome 上游 DNS 服务器
    - 设置->DNS设置->上游 DNS 服务器
        - https://dns.cloudflare.com/dns-query
        - https://dns.alidns.com/dns-query
        - tls://dns.alidns.com
        - https://doh.pub/dns-query
- adguardhome 重定向内网dns
    - 过滤器->DNS重写
    - 域名:*.$domain 应答 机器内网  **ipv4** 地址
- 验证
    - 内网运行`nslookup adguardhome.$domain`出现内网地址
    - 外网运行`nslookup adguardhome.$domain`出现cloudflare的服务器地址
### ddns
- ddns 只支持cloudflare
    - 不会移除启用的ddns解析
### 反向代理-traefik
- https证书使用web的认证方式,强依赖于ddns

## 防火墙
### 22端口
**强烈建议使用非22端口**
```
sudo ufw allow 22
```
### 443/80 端口
#### 开放内部网段
```
sudo ufw allow from 192.168.31.0/24 to any port 80
sudo ufw allow from 192.168.31.0/24 to any port 443
```
**修改上面的网段为你的内网网段**
#### cloudflare的ip
```
for ipv4 in `curl -s https://www.cloudflare.com/ips-v4 | tee ips-v4`
do
    sudo ufw allow from $ipv4 to any port 80
    sudo ufw allow from $ipv4 to any port 443
done
for ipv6 in `curl -s https://www.cloudflare.com/ips-v6 | tee ips-v6`
do
    sudo ufw allow from $ipv6 to any port 80
    sudo ufw allow from $ipv6 to any port 443
done
```
#### 139/445(smb)端口只允许内网访问
```
sudo ufw allow from 192.168.31.0/24 to any port 139
sudo ufw allow from 192.168.31.0/24 to any port 445
```
**修改上面的网段为你的内网网段**
## 快速开始
### 安装和配置ufw
```
sudo apt install -y ufw
sudo ufw enable
sudo ufw default deny 
echo '开启ssh端口权限'
sudo ufw allow 22
sudo ufw reload
```
### 安装docker 和 配置
- 安装
```
curl -fsSL https://get.docker.com -o get-docker.sh 
sudo sh get-docker.sh 
sudo systemctl enable docker.service
```
- 配置当前用户访问docker(非root)
```
sudo gpasswd -a $USER docker 
newgrp docker
sudo systemctl restart docker
```
- 部分情况需要授权允许sock的权限

### 安装应用
```
git clone https://github.com/dezhishen/self-hosted-server-traefik.git
cd self-hosted-server-traefik
chmod +x ./start.sh
chmod +x -R ./scripts
./start.sh
```

## 预期结果
**使用过的配置文件都存放在项目目录的.args下面**
### 目录结构
```
- docker_data # filebrowser 文件挂载根目录
  - public # 多应用挂载
    - music
    - downloads
    - ...
  - ddns # 单一应用内部使用
  - aria2 # 单一应用内部使用
  ...
```
### 网络访问
#### 内网
- 如果安装和正确设置了`adguardhome`,内网将直接访问机器
- 如果没有安装则和外网一致
#### 外网
- 通过cloudflare服务器的代理访问
#### 容器
- 容器均挂载在创建的(bridge)容器网络上
    - traefik 映射宿主机 80/443
    - samba 映射宿主机 139/445 端口
    - ddns 网络模式为hosts以获取ipv6地址
- 部分需要upnp的容器同时挂载在(macvlan)容器网络上
    - 如:qbittorrent
## todo
- [ ] cloudflare速度优化方案提供
## 应用清单

### 网络
名称|说明
-|-
[adguardhome](https://github.com/AdguardTeam/AdGuardHome)|dns服务器
[ddns](https://github.com/timothymiller/cloudflare-ddns)|用于动态ddns服务
[traefik](https://doc.traefik.io/traefik/)|反向代理,自动https证书

### 存储
名称|说明
-|-
[aliyundrive-webdav](https://github.com/messense/aliyundrive-webdav)|将阿里云盘代理为webdav访问
[filebrowser](https://github.com/filebrowser/filebrowser)|web端文件管理器|
[samba](https://github.com/dperson/samba)|smb协议的内网文件共享
[webdav](https://github.com/dezhishen/docker-nginx-webdav)|基于nginx的webdav服务

### 下载
名称|说明
-|-
[aria2-pro](https://github.com/P3TERX/Aria2-Pro-Docker)|aria2,不支持upnp,支持普通多线程下载
[nzbget](https://github.com/linuxserver/docker-nzbget)|nzbget
[qbittorrent](https://github.com/linuxserver/docker-qbittorrent)|qbittorrent,BT下载工具-支持upnp
### 安全
名称|说明
-|-
[vaultwarden](https://github.com/dani-garcia/vaultwarden)|密码托管,用 Rust 编写并与上游 Bitwarden 客户端兼容的 Bitwarden 服务器 API 的替代实现
[vaultwarden-backup](https://github.com/ttionya/vaultwarden-backup)|vaultwarden的备份程序,可以加密后备份到各大网盘和云存储
### 阅读
名称|说明
-|-
[freshrss](https://github.com/FreshRSS/FreshRSS)|rss订阅器,支持信息流的订阅和聚集

### 影音
#### 配置
- prowlarr,添加其他PVR应用,统一进行管理
- prowlarr,添加index,进行资源的搜索
- prowlarr,添加下载客户端 nzbget/qbit
- nzbget/qbit,配置分类和自动保存文件夹
- 下载完成后,PVR应用自动刮削信息
- emby/jellyfin等提供外部统一入口
#### 日常使用
- prowlarr中进行搜索,点击下载
- 等待下载完成
- 下载完成后,进入emby或者jellyfin查看资源
#### 清单
名称|说明
-|-
[emby](https://github.com/linuxserver/docker-emby)|emby,用于组织和管理 电影/音乐/电视/照片,并将它们流式传输到智能电视、流媒体盒和移动设备。
[jellyfin](https://github.com/linuxserver/docker-jellyfin)|jellyfin, Emby 和 Plex 的替代方案，通过多个应用程序从专用服务器向最终用户设备提供媒体。
[lidarr](https://github.com/linuxserver/docker-lidarr)|Lidarr是用户的音乐收藏管理器。
[ombi](https://github.com/linuxserver/docker-ombi)|Ombi允许您托管自己的 Plex 请求和用户管理系统。
[prowlarr](https://github.com/linuxserver/docker-prowlarr)|prowlarr 与 Sonarr、Radarr、Lidarr 和 Readarr 无缝集成,提供PT/BT源管理,提供pt/bt等搜索,发送下载到qbit/nzbget。
[radarr](https://github.com/linuxserver/docker-radarr)|radarr 电影管理。
[readarr](https://github.com/linuxserver/docker-readarr)|readarr 书籍管理
[sonarr](https://github.com/linuxserver/docker-sonarr)|sonarr 电视剧(追剧),管理
[bazarr](https://github.com/linuxserver/docker-bazarr)|bazarr 字幕获取
[chinesesubfinder](https://github.com/allanpk716/ChineseSubFinder)|中文字幕获取







