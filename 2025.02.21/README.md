# nginx 单双向证书
### 单向认证
自签名 ca
```bash
openssl genrsa -out ca.key 4096 # 生成私钥 ca.key
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/C=CN/ST=GD/L=GZ/O=yunwanjia/OU=yunwanjia/CN=yunwanjia/emailAddress=yun.wanjia.ex@gmail.com" # 生成根证书
```
用 ca 签发服务端证书
```bash
openssl genrsa -out server.key 4096 # 生成服务端私钥
openssl rsa -in server.key -pubout -out server.pub # 生成服务端公钥,非必要
openssl req -new -key server.key -out server.csr -subj "/C=CN/ST=GD/L=GZ/O=ohhhhhh/OU=wangdefa/CN=*.domain.com/emailAddress=admin@domain.com" # 生成申请签名证书
openssl x509 -req -CA ca.crt -CAkey ca.key -in server.csr -out server.crt -days 3650 # ca签名
```
服务器配置
```
server {
    listen 443 ssl;
    server_name www.domain.com;
    ssl_certificate /cert/server.crt;
    ssl_certificate_key /cert/server.key;
    ...
}
```
客户端安装 ca 证书或忽略证书直接访问
```bash
curl --cacert ./ca.crt https://www.domain.com # -k
```
### 双向认证
服务端添加以下配置
```
server {
    ...
    ssl_client_certificate /cert/ca.crt; # 根证书
    ssl_verify_depth 1;
    ssl_verify_client on; # 开启客户端验证
    ...
}
```
客户端证书生成与服务端相同,此处略,验证如下
```bash
curl --cacert ./ca.crt --cert ./client.crt --key ./client.key https://www.domain.com
```
在 Windows 下通过 Edge 浏览器访问,需要转换证书格式
```bash
openssl pkcs12 -export -certfile ca.crt -in client.crt -inkey client.key -out client.pfx -passout pass:
```
设置 -> 隐私搜索和服务 -> 安全性 -> 管理证书 -> 导入 -> 选择生成的证书 -> 证书存储选择个人 -> 重启浏览器