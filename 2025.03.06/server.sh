#!/bin/bash
cd "$(dirname "$0")"
read old_ip < ip.txt

ip_pool=(ipinfo.io/ip ipv4.ip.sb ifcfg.me icanhazip.com ifconfig.me ip.me 4.ipw.cn ifconfig.io)
shuf -e ${ip_pool[@]} | while read ip; do
    new_ip=$(curl --noproxy '*' -4s $ip)
    # 没有获取到 ip 就换个网站
    [[ "$new_ip" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]] || continue
    # 如果 ip 不变则退出
    [ "x$new_ip" = "x$old_ip" ] && exit
    # 写入文件进行同步
    echo "$new_ip" > ip.txt
    git add -A
    git commit -m $(date "+%y.%m.%d_%H.%M.%S_%6N")
    git push -u origin main
    exit
done