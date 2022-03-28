# !/bin/bash
while true; do
    echo "Updating hosts file"
    wget -q -O - https://gitee.com/ineo6/hosts/raw/master/hosts > /etc/hosts
    sleep 3600
done