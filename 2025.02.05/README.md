# 无盘系统
### 配置 iSCSI
1. 如前所述先要安装 pxe 服务
2. 在  ip 为 `192.168.99.3` 的 `Debian` 上安装 `iSCSI` 服务
    ```bash
    apt install -y tgt lvm2

    # 新建 lvm 分区用作远程系统的磁盘
    pvcreate /dev/sdb
    vgcreate vg_iscsi /dev/sdb
    lvcreate -l +100%FREE vg_iscsi -n lv_disk1
    # 或直接使用文件
    # dd if=/dev/zero of=disk1.img count=0 bs=1 seek=100G

    # 启用iSCSI硬盘
    cat > /etc/tgt/conf.d/disk1.conf << EEE
    <target iqn.2025-01.server:disk1>
        backing-store /dev/mapper/vg_iscsi-lv_disk1
        # incominguser disk1 ppsswwdd
    </target>
    EEE
    systemctl restart tgt.service
    
    # 查看硬盘情况
    tgtadm --mode target --op show
    ```
### Windows 11
将 Windows 11 镜像解压并提供 samba 服务,将 PE 里的文件放到 `/mnt/pxe/pe`, `boot.ipxe` 内容为
```
#!ipxe
:start
menu iPXE Boot Option
item boot_win11 Boot Windows 11
item install_win11 Install Windows 11
item reboot reboot now
choose --default boot_win11 --timeout 10000 option && goto ${option}

:boot_win11
sanboot iscsi:192.168.99.3:::1:iqn.2025-01.server:disk1 || goto start

:install_win11
sanhook iscsi:192.168.99.3:::1:iqn.2025-01.server:disk1
kernel http://192.168.99.2/pe/wimboot
initrd http://192.168.99.2/pe/BCD      BCD
initrd http://192.168.99.2/pe/boot.sdi boot.sdi
initrd http://192.168.99.2/pe/bootmgr  bootmgr
initrd http://192.168.99.2/pe/boot.wim boot.wim
boot || goto start

:reboot
reboot
```
启动客户端,选择 `Install Windows 11`
```cmd
rem 卡在这一步,可能是缺少网卡驱动
wpeinit
rem 去除 Windows 11 安装限制
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1
rem 挂载 samba ,执行 setup.exe
net use \\192.168.99.2\win11
\\192.168.99.2\win11\setup.exe /noreboot
rem 改注册表
reg load HKLM\iscsi C:\Windows\System32\config\SYSTEM
reg add "HKLM\iscsi\ControlSet001\Control\Session Manager\Memory Management" /v PagingFiles /t REG_MULTI_SZ /f
reg unload HKLM\iscsi
rem 重启
wpeutil reboot
```
等待重启选择 `Boot Windows 11` 完成剩下的安装
### Rocky 9
`boot.ipxe` 内容如下
```
#!ipxe
:start
menu iPXE Boot Option
item boot_linux Rocky 9
item install_linux Install Rocky 9
item reboot reboot now
choose --default boot_linux --timeout 10000 option && goto ${option}

:boot_linux
#set username disk1
#set password ppsswwdd
sanboot iscsi:192.168.99.3:::1:iqn.2025-01.server:disk1 || goto start

:install_linux
sanhook iscsi:192.168.99.3:::1:iqn.2025-01.server:disk1
set base https://mirrors.ustc.edu.cn/rocky/9/BaseOS/x86_64/os
kernel ${base}/images/pxeboot/vmlinuz inst.repo=${base}
initrd ${base}/images/pxeboot/initrd.img
boot || goto start

:reboot
reboot
```