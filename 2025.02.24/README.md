# Linux 无线软路由
### 内外不同网段
系统 `Debian 12` ,两块网卡, `eth0` 与外网相连, `wlan0` 对内网提供无线 AP
```bash
apt install -y firmware-misc-nonfree network-manager
sed -i 's/^managed=.*/managed=true/' /etc/NetworkManager/NetworkManager.conf
systemctl restart NetworkManager
```
启用 2.4G
```bash
nmcli radio wifi on
nmcli connection add type wifi ifname wlan0 con-name wifi24g autoconnect yes ssid "helloworld24g"
nmcli connection modify wifi24g 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
nmcli connection modify wifi24g wifi-sec.key-mgmt wpa-psk
nmcli connection modify wifi24g wifi-sec.psk "12345678"
nmcli connection up wifi24g
```
启用 5G
```bash
nmcli connection add type wifi ifname wlan0 con-name wifi5g autoconnect yes ssid "helloworld5g"
nmcli connection modify wifi5g 802-11-wireless.mode ap 802-11-wireless.band a 802-11-wireless.channel 149 802-11-wireless.powersave 2 ipv4.method shared
nmcli connection modify wifi5g 802-11-wireless-security.key-mgmt wpa-psk
nmcli connection modify wifi5g 802-11-wireless-security.psk "12345678"
iw reg set CN
nmcli radio wifi on
nmcli connection up wifi5g
```
客户端
```bash
nmcli device wifi list/rescan # 显示/刷新 WiFi 列表
nmcli device wifi connect "helloworld" password "12345678" # hidden yes # 连接到(隐藏) WiFi
nmcli connection up/down/delete "helloworld" # 连接/断开/删除已保存 WiFi
```
### 内外同网段
两块网卡 `eth0` 和 `wlan0`, dhcp 获得的 ip 在同一网段,由 `eth0` 网段提供
```bash
nmcli connection add type bridge con-name bridge0 ifname br0
nmcli connection add type bridge-slave ifname eth0 master br0
nmcli connection add type wifi slave-type bridge master br0 ifname wlan0 wifi.mode ap wifi.ssid "helloworld" wifi-sec.key-mgmt wpa-psk wifi-sec.proto rsn wifi-sec.pairwise ccmp wifi-sec.psk "12345678"
nmcli connection down 原eth0的连接
nmcli connection up bridge0
```
### 传统方案
`eth0` 与外网相连, `eth1` 连接内网台式机, `wlan0` 与内网无线设备相连
```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
创建网桥 `br0` ,加入 `eth1`
```bash
nmcli connection add type bridge con-name bridge0 ifname br0
nmcli connection add type bridge-slave ifname eth1 master br0
nmcli connection modify bridge0 ipv4.addresses 192.168.123.1/24 ipv4.method manual ipv6.method disabled
nmcli connection up bridge0
```
配置 `dns` 和 `dhcp`
```bash
apt install -y dnsmasq
echo 'interface=br0
bind-interfaces
dhcp-range=192.168.123.10,192.168.123.250,255.255.255.0,24h
no-resolv
server=114.114.114.114
except-interface=lo
no-dhcp-interface=lo' > /etc/dnsmasq.conf
systemctl enable --now dnsmasq.service
```
共享 ap
```bash
apt install -y hostapd
echo 'bridge=br0
interface=wlan0
driver=nl80211
ssid=helloworld
wpa_passphrase=12345678
wpa=2
wpa_key_mgmt=WPA-PSK
ignore_broadcast_ssid=0
hw_mode=g
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa_pairwise=TKIP
rsn_pairwise=CCMP
channel=1' > /etc/hostapd/hostapd.conf
systemctl unmask hostapd.service
systemctl enable --now hostapd.service
```