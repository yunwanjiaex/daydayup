# Linux 透明代理
1. 设置路由转发
    ```bash
    ip rule add fwmark 1 table 100 # mark 为 1 的包都发到 table100
    ip route add local 0.0.0.0/0 dev lo table 100 # table100 中所有包送往 lo
    ```
2. 经过 `PREROUTING` 的包都 mark 为1,此处不考虑代理本机数据包
    ```bash
    iptables -t mangle -A PREROUTING -p tcp -j TPROXY --tproxy-mark 0x1/0x1 --on-ip 127.0.0.1 --on-port 1080
    iptables -t mangle -A PREROUTING -p udp -j TPROXY --tproxy-mark 0x1/0x1 --on-ip 127.0.0.1 --on-port 1080
    ```
3. 有代理服务监听在 `127.0.0.1:1080` ,需要支持透明代理模式
4. [V2Ray](https://github.com/v2fly/v2ray-core) 用于分流,配置文件参考[透明代理(TPROXY)](https://guide.v2fly.org/app/tproxy.html)
5. [mitmproxy](https://docs.mitmproxy.org/stable/howto-transparent/) 用于自动抓包改包,需要在图形界面手动调试可使用 [Charles](https://www.charlesproxy.com/download/)