# GRE, IPsec 和 WireGuard
### 背景
* 服务器A公网IP为 `11.11.11.11` ,内网网段为 `172.17.11.0/24`  
* 服务器B公网IP为 `22.22.22.22` ,内网网段为 `192.168.22.0/24`  
* 在A和B之间架设隧道,使两个内网网段之间可以互通,预先启用数据包转发
### GRE 隧道
在A上
```bash
# GRE 隧道对端为 22.22.22.22
nmcli connection add con-name gre-A type ip-tunnel ip-tunnel.mode gre ifname gre1 remote 22.22.22.22
# 新建 IP 为 10.0.0.1 用于隧道
nmcli connection modify gre-A ipv4.method manual ipv4.addresses '10.0.0.1/30'
# 去往 192.168.22.0/24 的数据包下一跳为 10.0.0.2
nmcli connection modify gre-A +ipv4.routes "192.168.22.0/24 10.0.0.2"
nmcli connection up gre-A
```
B与A类似,调换对应参数即可
```bash
nmcli connection add con-name gre-B type ip-tunnel ip-tunnel.mode gre ifname gre1 remote 11.11.11.11
nmcli connection modify gre-B ipv4.method manual ipv4.addresses '10.0.0.2/30'
nmcli connection modify gre-B +ipv4.routes "172.17.11.0/24 10.0.0.1"
nmcli connection up gre-B
```
### IPsec over GRE
`GRE` 隧道不提供加密,有些协议如 `telnet`, `http`, `dns`, `icmp` 等可能会被中间人篡改,需要再套一层 `IPsec` 用于加密,在A和B上生成密钥
```bash
dnf install -y libreswan
ipsec initnss
ipsec newhostkey
# xxxxxx 填入上一步生成的 ckaid ,记下 leftrsasigkey= 右侧的字符串
ipsec showhostkey --left --ckaid xxxxxx
```
编辑 `/etc/ipsec.d/ipsec.conf` ,下面以A为例说明,B的话对调 `left` 和 `right`, `leftrsasigkey` 和 `rightrsasigkey` 的值即可
```
conn ipsecovergre
    left=10.0.0.1
    right=10.0.0.2
    authby=rsasig
    auto=start
    leftrsasigkey=balabala_in_A
    rightrsasigkey=labalaba_in_B
```
如果是 `GRE over IPsec` ,配置文件略有不同,其它完全一样
```
conn greoveripsec
    type=transport
    left=11.11.11.11
    right=22.22.22.22
    authby=rsasig
    auto=start
    leftprotoport=gre
    rightprotoport=gre
    leftrsasigkey=balabala_in_A
    rightrsasigkey=labalaba_in_B
```
启动 `systemctl start ipsec.service`
### WireGuard 隧道
对于A,B其中之一无法提供公网端口的,可以使用传统隧道,此处以 `WireGuard` 为例,在A和B上生成密钥
```bash
dnf install -y wireguard-tools
cd /etc/wireguard
# 生成私钥和公钥
wg genkey > private.key
wg pubkey < private.key > public.key
```
服务端A的配置 `/etc/wireguard/wg0.conf`
```ini
[Interface]
PrivateKey = A的 private.key 的内容
Address = 10.0.0.1
ListenPort = 55555 # 监听 udp 的 55555 端口
PostUp = ip route add 192.168.22.0/24 dev %i # 接口up后转发路由
PreDown = ip route del 192.168.22.0/24 dev %i # 接口down前删除路由

[Peer] # 可以有多个 Peer ,每个 Peer 使用同一个密钥
PublicKey = B的 public.key 的内容
AllowedIPs = 10.0.0.2, 10.0.0.3 # 允许对端以这些 ip 连接
```
客户端B的配置
```ini
[Interface]
PrivateKey = B的 private.key 的内容
Address = 10.0.0.2
PostUp = ip route add 172.17.11.0/24 dev %i
PreDown = ip route del 172.17.11.0/24 dev %i

[Peer]
PublicKey = A的 public.key 的内容
AllowedIPs = 10.0.0.1
EndPoint = 11.11.11.11:55555 # A的真实ip地址
PersistentKeepalive = 10 # 每 10 秒发送 ping 包保活
```
启动 `systemctl start wg-quick@wg0`