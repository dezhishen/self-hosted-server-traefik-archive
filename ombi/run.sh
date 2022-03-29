# !/bin/bash
# 后台启动 update-hosts.sh
nohup /bin/bash /update-hosts.sh > /config/update-hosts.log 2>&1 &
/init
