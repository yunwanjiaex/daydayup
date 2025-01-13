# 配置 OpenVPN
1. 在 Windows 上,下载 [OpenVPN](https://openvpn.net/community-downloads/) ,自定义安装全部组件
2. 进入 `C:\Program Files\OpenVPN\easy-rsa` ,将 `vars.example` 复制为 `vars` ,修改以下信息
    ```
    set_var EASYRSA_REQ_COUNTRY     "CN"
    set_var EASYRSA_REQ_PROVINCE    "GD"
    set_var EASYRSA_REQ_CITY        "GZ"
    set_var EASYRSA_REQ_ORG         "yunwanjia"
    set_var EASYRSA_REQ_EMAIL       "yun.wanjia.ex@gmail.com"
    set_var EASYRSA_REQ_OU          "yunwanjia"

    set_var EASYRSA_KEY_SIZE        2048
    set_var EASYRSA_CA_EXPIRE       3650
    set_var EASYRSA_CERT_EXPIRE     825
    ```
3. 生成证书
    ```ps1
    & "C:\Program Files\OpenVPN\easy-rsa\EasyRSA-Start.bat"
    ./easyrsa init-pki
    # 生成 ca
    ./easyrsa build-ca nopass
    # 生成服务端密钥, server_mini 为服务端名字
    ./easyrsa gen-req server_mini nopass
    ./easyrsa sign server server_mini
    # 使用 Diffie-Hellman 算法
    ./easyrsa gen-dh
    # 生成客户端密钥, client_each 为客户端名字
    ./easyrsa gen-req client_each nopass
    ./easyrsa sign client client_each
    exit
    # 使用 TLS 加密
    & "C:\Program Files\OpenVPN\bin\openvpn.exe" --genkey secret "C:\Program Files\OpenVPN\easy-rsa\pki\ta.key"
    ```
4. 将 `C:\Program Files\OpenVPN\easy-rsa\pki` 中的文件按照客户端和服务端分别复制到各自机器的 `C:\Program Files\OpenVPN\config` 下.在Linux下为 `/etc/openvpn/client/` ,并将 `xxx.ovpn` 重命名为 `xxx.conf`
5. 服务端配置 `server.ovpn` 示例
    ```
    # 监听 33333 端口
    local 0.0.0.0
    port 33333
    proto tcp
    dev tun

    topology subnet
    # 子网网段为 10.10.10.0/24
    server 10.10.10.0 255.255.255.0
    push "dhcp-option DNS 114.114.114.114"
    push "dhcp-option DNS 223.5.5.5"

    data-ciphers AES-256-CBC
    data-ciphers-fallback AES-256-CBC
    ca ca.crt
    cert server_mini.crt
    key server_mini.key
    dh dh.pem
    tls-auth ta.key 0
    persist-key
    persist-tun

    # 客户端之间可以互通
    client-to-client
    duplicate-cn
    keepalive 10 120
    auth-nocache
    status openvpn-status.log
    log openvpn.log
    log-append openvpn.log
    verb 3
    ```
6. 客户端配置 `client.ovpn` 示例
    ```
    client
    dev tun
    proto tcp
    # 服务端地址
    remote local.yunwanjia.com 33333
    resolv-retry infinite
    nobind
    persist-key
    persist-tun
    data-ciphers AES-256-CBC
    data-ciphers-fallback AES-256-CBC
    mute-replay-warnings
    ca ca.crt
    cert client_each.crt
    key client_each.key
    auth-nocache
    tls-auth ta.key 1
    remote-cert-tls server
    log openvpn.log
    log-append openvpn.log
    verb 3
    ```
7. 将证书嵌入客户端配置文件方便分发,在客户端配置后面追加,替换xxxxx为自己的证书的内容
    ```
    key-direction 1
    <ca>
    -----BEGIN CERTIFICATE-----
    xxxxx
    -----END CERTIFICATE-----
    </ca>
    <cert>
    -----BEGIN CERTIFICATE-----
    xxxxx
    -----END CERTIFICATE-----
    </cert>
    <key>
    -----BEGIN PRIVATE KEY-----
    xxxxx
    -----END PRIVATE KEY-----
    </key>
    <tls-auth>
    -----BEGIN OpenVPN Static key V1-----
    xxxxx
    -----END OpenVPN Static key V1-----
    </tls-auth>
    ```
8. 开机启动
    * 将 `server` 里的文件复制到 `C:\Program Files\OpenVPN\config-auto` 下,并使 `OpenVPNService` 开头的服务自动启动,即可实现开机启动
    * 将 `client` 整个目录复制到 `C:\Program Files\OpenVPN\config` 下,可实现手动启动
    * Linux以 `systemctl enable openvpn-client@client.service --now` 命令启动