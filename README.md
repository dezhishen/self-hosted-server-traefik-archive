# 自托管服务脚本
## 注意事项
- 部分地区的宽带会封闭443/80等端口
- 曾出现运营商关闭账户的情况
## 目的

ddns+cloudflare(免备案，免费防御体系) 实现外网访问

## 要求

- 一个域名，不管多少级
- 机器（树莓派等）
    - 机器需要长期开启
    - 机器需要有防火墙
- 机器具有至少一个公网地址（ipv4/ipv6）
    - 推荐ipv6,获取方式更简便
    - ipv6的获取方式
        - 光猫设置为桥接
        - 开启光猫的ipv6
        - 路由器开启ipv6
        - 路由器拨号
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
git clone 
cd
chmod +x ./start.sh
chmod +x -R ./scripts
./start.sh
```
