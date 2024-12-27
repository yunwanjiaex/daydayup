#!/bin/bash
# 低配 ansible

for a in "$@"; do
    [ "${a:0:2}" == '--' ] && opt=${a:2} || eval $opt+='("$a")'
done
[ -t 0 ] || command+=("$(cat)")
for h in "${host[@]}"; do
    [ ${#upload[@]} != 0 ] && scp -rT "${upload[@]}" $h:
    ( IFS=$'\n'; echo "${command[*]}" ) | ssh -T $h bash -sx
    [ ${#download[@]} != 0 ] && scp -rOT $h:"${download[*]}" $(mktemp $$-$h-XXX -dp .)
done

# ./s.sh --host 192.168.44.1{36,{40..46}} 192.168.88.88 \
#        --upload ./* \
#        --command 'systemctl status --full nginx.service' \
#        --download /etc/issue /var/log
# 对 host 里的每一台服务器发起 ssh 连接,先上传 upload 列出的本地文件或目录,再执行 command 中的命令,最后下载 download 中的服务器文件或目录到本地. command 中的命令也可以从标准输入读取