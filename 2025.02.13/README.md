# Debian On SurfacePro4
### 系统安装
1. 下载系统镜像 [debian-xx.xx.xx-amd64-DVD-1.iso](https://mirrors.tuna.tsinghua.edu.cn/debian-cd/current/amd64/iso-dvd/) ,将其放入已安装 `Ventoy` 的U盘中
2. 按住 `Surface Pro 4` 音量+不放,再按一下电源键进入 BIOS 后松开音量键,设置 `USB Storage` 为第一启动项, `Secure Boot` 设置为 `Microsoft & 3rd party CA`
3. 启动进入 `Ventoy` 选择刚刚下载的 iso 镜像,以正常模式启动.安装过程没什么要注意的
### 更新内核
参照[文档](https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup#debian--ubuntu)以 `root` 权限执行以下命令后重启
```bash
curl -s https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | gpg --dearmor > /etc/apt/trusted.gpg.d/linux-surface.gpg
echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" \
    > /etc/apt/sources.list.d/linux-surface.list
apt update
apt install linux-image-surface linux-headers-surface libwacom-surface iptsd
apt install linux-surface-secureboot-mok
```