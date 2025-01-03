# PXE 服务
1. 系统 `Debian 12` ,ip为 `192.168.99.2` ,网关为 `192.168.99.1` ,关闭网段内的其它dhcp服务.下载 `ipxe` 相关文件
    ```bash
    wget https://boot.ipxe.org/{undionly.kpxe,ipxe.efi} -P /mnt/pxe
    ```
2. 用于测试的配置 `/mnt/pxe/boot.ipxe`
    ```
    #!ipxe
    :start
    menu Hello, World!
    item shell start shell
    item reboot reboot now
    choose --default shell --timeout 10000 option && goto ${option}
    :shell
    shell
    :reboot
    reboot
    ```
3. 安装 `dnsmasq` 提供dns,dhcp,tftp服务
    ```
    apt install -y dnsmasq
    cat > /etc/dnsmasq.conf << EEE
    # dhcp
    dhcp-range=192.168.99.3,192.168.99.254,255.255.255.0,12h
    dhcp-option=option:router,192.168.99.1
    dhcp-option=option:dns-server,192.168.99.2
    # dns
    no-resolv
    server=114.114.114.114
    # tftp
    enable-tftp
    tftp-root=/mnt/pxe
    # ipxe
    dhcp-match=set:bios,option:client-arch,0
    dhcp-match=set:ipxe,175
    dhcp-boot=tag:!ipxe,tag:bios,undionly.kpxe
    dhcp-boot=tag:!ipxe,tag:!bios,ipxe.efi
    dhcp-boot=tag:ipxe,boot.ipxe
    EEE
    systemctl restart dnsmasq.service
    ```
4. 客户端在 bios 中设置从网络启动,看到如下界面说明成功

    ![pxe.png](./pxe.png)

5. 因为 tftp 传输文件速度较慢,可以考虑使用 http 和 samba 传输文件,如下配置有 `Windows PE` 和 `Debian LiveCD` 的启动项,并分别注入了启动脚本
    ```
    #!ipxe
    :start
    menu iPXE Boot Option
    item boot_winpe Windows PE
    item boot_livecd Debian LiveCD
    item reboot reboot now
    choose --default shell --timeout 10000 option && goto ${option}

    :boot_winpe
    kernel http://192.168.99.2/pe/wimboot
    initrd http://192.168.99.2/pe/install.bat  install.bat
    initrd http://192.168.99.2/pe/winpeshl.ini winpeshl.ini
    initrd http://192.168.99.2/pe/BCD          BCD
    initrd http://192.168.99.2/pe/boot.sdi     boot.sdi
    initrd http://192.168.99.2/pe/bootmgr      bootmgr
    initrd http://192.168.99.2/pe/boot.wim     boot.wim
    boot || goto start

    :boot_livecd
    kernel http://192.168.99.2/live/vmlinuz boot=live fetch=http://192.168.99.2/live/filesystem.squashfs
    initrd http://192.168.99.2/live/initrd
    initrd http://192.168.99.2/live/foo.txt /dummy.sh
    boot || goto start

    :reboot
    reboot
    ```
6. `Windows PE` 部分
    * `wimboot` 来自于 [ipxe/wimboot](https://github.com/ipxe/wimboot/releases/latest/download/wimboot)
    * `BCD`, `boot.sdi`, `bootmgr`, `boot.wim` 分别提取自pe的iso镜像 `Boot/BCD`, `Boot/boot.sdi`, `bootmgr`, `sources/boot.wim`
    * `winpeshl.ini` 为注入的配置文件,内容如下,意思是开机启动`install.bat`脚本
        ```ini
        [LaunchApps]
        "install.bat"
        ```
    * `install.bat` 为注入的脚本,执行完后重启,于此同时,原本的 `startnet.cmd` 不会被执行
7. `Debian LiveCD` 部分
    * 解压镜像,获取 `live` 目录下的 `vmlinuz`, `initrd` 和 `filesystem.squashfs` 放到对应位置
    * `foo.txt` 是注入到 `initramfs` 里的脚本,位置是 `/dummy.sh` ,如果要将脚本注入到 `rootfs` ,可以以 `initramfs` 为跳板将脚本复制到 `rootfs` ,具体方法是制作 `Debian LiveCD` 时,在 `chroot` 部分修改 `init` 脚本
        ```bash
        echo $'#!/bin/sh
        [ "x$1" = xprereqs ] && echo && exit 0
        . /usr/share/initramfs-tools/hook-functions
        sed -i \'/^exec run-init/i[ -f /dummy.sh ] && cat /dummy.sh >> $rootmnt/etc/rc.local\' $DESTDIR/init' > /usr/share/initramfs-tools/hooks/dummy
        chmod +x /usr/share/initramfs-tools/hooks/dummy
        update-initramfs -ck all
        ```