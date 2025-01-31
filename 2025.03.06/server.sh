#!/bin/bash
# 另一种 DDNS
cd "$(dirname "$0")"
ip_pool=(ipinfo.io/ip ipv4.ip.sb ifcfg.me icanhazip.com ifconfig.me ip.me 4.ipw.cn ifconfig.io)

shuf -e ${ip_pool[@]} | while read ip; do
    new_ip=$(curl --noproxy '*' -4s $ip)
    # 没有获取到 ip 就换个网站
    [[ "$new_ip" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]] || continue
    # 写入文件进行同步
    > ip.txt echo "$new_ip" && exit
done

# 如果不想花钱买域名,可以在服务端将动态 ip 定时更新到 git 仓库
# 客户端使用 client.sh 按时同步仓库即可获取到最新 ip
# 脚本依赖前文 git 远控运行