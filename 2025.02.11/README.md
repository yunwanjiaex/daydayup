# PC 远程开机
1. 在BIOS中打开 `Wake on Lan` 或类似选项,并且关闭 `Energy Save` 等省电选项
2. 设置网卡,在 Windows 上,设备管理器 -> 对应网卡 -> 属性 -> 电源管理 -> 勾选`允许此设备唤醒计算机`和`只允许幻数据包唤醒计算机`;在 Linux 上,命令 `ethtool eth0 | grep Wake-on` 查看网卡是否支持以及是否开启, `d` 为 `disable` ,命令 `ethtool -s eth0 wol g` 开启`幻数据包模式`,部分网卡在下次开机后会重置此状态,所以可能需要将此命令写入开机启动项
3. 在网关路由器上绑定要唤醒设备的 ip 和 mac ,以便外网转发进内网的数据包能转换为正确的 mac 地址
4. 唤醒功能的安装和调试
    ```bash
    apt install wakeonlan
    # 在内网只需
    wakeonlan 00:11:22:33:44:55
    # 如果是从外网唤醒内网机器,配合路由器转发至内网端口9,协议 udp, mac 随意
    wakeonlan -i ip_address -p port mac_address
    # 本地监听 udp 协议的端口9,测试是否能收到数据包
    nc -ulvp 9
    ```