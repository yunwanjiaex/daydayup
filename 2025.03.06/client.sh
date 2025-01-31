#!/bin/bash
cd "$(dirname "$0")"
domain="yun.wanjia.ex"
awk '$2 !~ "'$domain'" { print } END { print "'"$(cat ip.txt)    $domain"'"}' \
    /etc/hosts | tac | tac | tee /etc/hosts &> /dev/null # 避免使用临时文件