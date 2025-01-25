# S22 启用 LXC
1. 参考 [lateautumn233/Common-Android-Kernel-Tree](https://github.com/lateautumn233/Common-Android-Kernel-Tree/commits/lxc/) 对内核代码进行修改.执行 `run.sh` 之前,在 `common` 的父目录下执行 `patch -p0 < lxc.patch`
2. 刷入新内核后,进入 `termux` 安装 `lxc` ,后续命令均使用 tsu 切换到 root 执行
    ```bash
    apt install -y root-repo
    apt install -y lxc tsu
    ```
3. 执行 `patch -d/ -p0 < systemd.patch` 在容器中启用 `systemd` ,每次开机后需执行 `lxc-setup-cgroups` 初始化
4. 安装 `Debian 12` 容器
    ```bash
    # 下载
    lxc-create -t download -n debian12 -- -d debian -r bookworm -a arm64 --server mirrors.sdu.edu.cn/lxc-images --no-validate
    # 给 root 用户设置密码
    chroot $PREFIX/var/lib/lxc/debian12/rootfs /bin/passwd
    # 启动,停止和销毁容器
    lxc-start -Fn debian12
    lxc-stop -kn debian12
    lxc-destroy -n debian12
    # 容器内设置 DNS
    echo -e '[Resolve]\nDNS=114.114.114.114' > /etc/systemd/resolved.conf
    systemctl restart systemd-resolved
    ```
5. 使用主机网络.修改 `$PREFIX/var/lib/lxc/debian12/config` 中的 `lxc.net.0.type = none` ,若修改 `$PREFIX/etc/lxc/default.conf` 则只对后续创建的容器生效
6. nat 网络共享.先对相关文件打补丁: `patch -d/ -p0 < nat.patch`, 然后修改 `$PREFIX/etc/default/lxc` 中的 `USE_LXC_BRIDGE="true"` 启用 nat ,最后修改 `$PREFIX/var/lib/lxc/debian12/config` 中的配置为
    ```
    lxc.net.0.type = veth
    lxc.net.0.link = lxcbr0
    lxc.net.0.flags = up
    ```
    每次开机后需执行 `$PREFIX/libexec/lxc/lxc-net restart` 初始化