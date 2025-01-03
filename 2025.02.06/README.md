# 无人值守安装系统
前提: 已经按照前文部署好 pxe 相关服务
### RHEL 9
1. 在红帽官网上找到 [Kickstart Generator](https://access.redhat.com/labs/kickstartconfig/) ,按照安装系统的步骤走一遍,然后点击 `Show Text` 得到 `kickstart.txt` ,或者使用已安装系统里的 `/root/anaconda-ks.cfg` 作为配置,放到 `/mnt/pxe/rhel9/` 下
2. 下载红帽系统镜像 `rhel-9.5-x86_64-dvd.iso` ,挂载到 `/mnt/pxe/rhel9/iso/` , `boot.ipxe` 内容如下
    ```
    #!ipxe
    :start
    menu iPXE Boot Option
    item install_rhel9 Red Hat Enterprise Linux 9
    choose --default shell --timeout 10000 option && goto ${option}

    :install_rhel9
    kernel http://192.168.99.2/rhel9/iso/images/pxeboot/vmlinuz inst.repo=http://192.168.99.2/rhel9/iso inst.ks=http://192.168.99.2/rhel9/kickstart.txt
    initrd http://192.168.99.2/rhel9/iso/images/pxeboot/initrd.img
    boot || goto start
    ```
### Ubuntu 24.04
1. 在已安装系统里找到 `/var/log/installer/autoinstall-user-data` ,这个是类似 `kickstart` 的配置文件,可以参考[官方文档](https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html)对其加以修改,完成后放到 `/mnt/pxe/ubuntu2404/`
2. 下载Ubuntu镜像 `ubuntu-24.04-desktop-amd64.iso` ,放到 `/mnt/pxe/ubuntu2404/` ,并挂载到 `/mnt/pxe/ubuntu2404/iso/` , `boot.ipxe` 内容如下
    ```
    #!ipxe
    :start
    menu iPXE Boot Option
    item install_ubuntu2404 Ubuntu Desktop 24.04
    choose --default shell --timeout 10000 option && goto ${option}

    :install_ubuntu2404
    kernel http://192.168.99.2/ubuntu2404/iso/casper/vmlinuz ip=dhcp autoinstall cloud-config-url=/dev/null url=http://192.168.99.2/ubuntu2404/ubuntu-24.04-desktop-amd64.iso ds=nocloud-net;s=http://192.168.99.2/ubuntu2404/autoinstall-user-data
    initrd http://192.168.99.2/ubuntu2404/iso/casper/initrd
    boot || goto start
    ```
    因为 Ubuntu 会将约 5.7G 的镜像一次性下载到内存,如果内存较小可以使用 `nfs` 服务共享解压缩后的镜像
### Windows 11
1. 可以按照微软官方[文档](https://learn.microsoft.com/zh-cn/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs?view=windows-11#create-and-modify-an-answer-file)制作无人值守应答文件,也可以在 [GitHub Gist](https://gist.github.com/) 中搜索 `unattend.xml` 或 `autounattend.xml` 获取成吨的现成配置
2. 解压 Windows 镜像并通过 samba 共享,将 `unattend.xml` 也放入其中,使用前文所述的 `Windows PE` ,注入如下安装脚本
    ```bat
    wpeinit
    net use \\192.168.99.2\win11    
    \\192.168.99.2\win11\setup.exe /unattend:\\192.168.99.2\win11\unattend.xml
    ```