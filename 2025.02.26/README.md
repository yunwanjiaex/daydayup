# ssh 常用命令
### 复制文件
```bash
scp -r root@1.2.3.4:/home/user /root
# 在A上运行,A可以连接B和C,将目录从B复制到C
scp -r3 hostB:/usr/local hostC:/mnt
```
### sftp 服务
```bash
# help 查看相关命令
sftp root@1.2.3.4 -P port
```
### 运行远端 gui 程序
```bash
# Wayland 服务端和客户端都要安装 waypipe
waypipe ssh root@1.2.3.4
# Xorg 远端需开启 X11Forwarding
ssh -X root@1.2.3.4
```
### socks 代理
```bash
# 在A上运行,A开放本地1080端口,所有访问A的1080端口的流量将从B出去
ssh -D 1080 userB@hostB # -fgNT
```
### 本地端口转发
```bash
# 在A上运行,A可以访问B,B可以访问C,访问A的portA即转发到C的portC
ssh -L portA:hostC:portC userB@hostB
# ipv6 格式 portA/hostC/portC
```
### 远程端口转发
```bash
# 在A上运行,A可以同时访问B和C,访问C的portC即通过A转发到B的portB,一般来说,B在内网,C在公网
ssh -R portC:hostB:portB userC@HostC
# C端须开启 GatewayPorts
```
### 多级跳板
```bash
# 通过跳板A访问B
ssh -J userA@hostA:2222 userB@hostB
# 多层跳转
ssh -J userA@hostA:2222,userB@hostB:4444 userC@hostC:6666
```
### 多路复用
```bash
# 建立连接
ssh -oControlMaster=yes -oControlPath=/tmp/test.sock -oControlPersist=yes user@host
# 复用上面的连接,免去密码验证码等验证
ssh -S /tmp/test.sock user@host
# 验证连接是否断开
ssh -S /tmp/test.sock -O check user@host
# 退出复用
ssh -S /tmp/test.sock -O exit user@host
```
### 公钥和私钥
```bash
# 无交互生成密钥
yes | ssh-keygen -t rsa -b 4096 -q -N '' -f ~/.ssh/id_rsa
# 用私钥生成公钥
ssh-keygen -y -f ./private.key > ./public.key
```
### 执行本地命令
在ssh连接后,按`~C`进入命令模式,输入`!cmd`执行本地命令,如`! exec bash --login -i >&2`.需在`.ssh/config`中添加如下行
```
Host *
    IgnoreUnknown EnableEscapeCommandline
    EnableEscapeCommandline yes
    PermitLocalCommand yes
```