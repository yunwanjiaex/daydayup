# 端口敲门
1. 安装: `apt-get install knockd`
2. 配置
    ```bash
    # 按顺序访问 eth0 网卡上的 ip 的 tcp 端口 66,55555,999 则启动 nginx ,60秒后关闭
    echo '[startnginx]
        sequence = 66,55555,999
        tcpflags = syn
        seq_timeout = 10
        start_command = systemctl start nginx
        cmd_timeout = 60
        stop_command = systemctl stop nginx' > /etc/knockd.conf
    echo 'START_KNOCKD=1
    KNOCKD_OPTS="--verbose -i eth0"' > /etc/default/knockd
    systemctl start knockd.service
    ```
3. 验证.因为 `knockd` 使用了 `libpcap` ,比之于 `netfilter` 更为底层,所以可以无视 `iptables` 的 `DROP`
    ```bash
    for i in 66 55555 999; do
        curl -m1 192.168.88.130:$i &> /dev/null
        sleep 1
    done
    ```