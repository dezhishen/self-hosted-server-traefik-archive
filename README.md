# 自托管服务脚本

![](https://img.shields.io/github/license/dezhishen/self-hosted-server-traefik.svg?style=for-the-badge)
![](https://img.shields.io/github/stars/dezhishen/self-hosted-server-traefik.svg?style=for-the-badge&logo=github)
![](https://img.shields.io/github/forks/dezhishen/self-hosted-server-traefik.svg?style=for-the-badge)
![](https://img.shields.io/github/contributors/dezhishen/self-hosted-server-traefik.svg?style=for-the-badge)


![](https://img.shields.io/static/v1?label=&message=Docker&style=for-the-badge&color=blue&logo=Docker)
![](https://img.shields.io/static/v1?label=&message=traefik&style=for-the-badge&color=blue&logo=Traefik%20Mesh)
![](https://img.shields.io/static/v1?label=&message=cloudflare&style=for-the-badge&color=blue&logo=Cloudflare)
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
- 容器均挂载在创建的容器网络上
    - traefik 映射宿主机 80/443
    - samba 映射宿主机 139/445 端口
    - ddns 网络模式为hosts以获取ipv6地址
## 应用清单

名称|说明|安装选项|官网
-|-|-|-
ddns|用于动态ddns服务|必装|https://github.com/timothymiller/cloudflare-ddns/
traefik|反向代理,自动https证书|必装|https://doc.traefik.io/traefik/
adguardhome|dns服务器|强烈推荐|https://github.com/AdguardTeam/AdGuardHome
aria2-pro|下载神器|推荐|https://github.com/P3TERX/Aria2-Pro-Docker
aliyundrive-webdav|将阿里云盘代理为webdav访问|非必要|https://github.com/messense/aliyundrive-webdav
filebrowser|web端文件管理器|推荐|https://github.com/filebrowser/filebrowser
freshrss|rss订阅器|推荐|https://github.com/FreshRSS/FreshRSS
portainer|容器管理平台|推荐|https://github.com/portainer/portainer
samba|smb协议的内网文件共享|强烈推荐|https://github.com/dperson/samba
vaultwarden|用 Rust 编写并与上游 Bitwarden 客户端兼容的 Bitwarden 服务器 API 的替代实现|推荐|https://github.com/dani-garcia/vaultwarden
vaultwarden-back|vaultwarden的备份程序|推荐|https://github.com/ttionya/vaultwarden-backup
webdav|基于nginx的webdav服务|非必要|https://github.com/dezhishen/docker-nginx-webdav
