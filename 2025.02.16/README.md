# 启用 OverlayFS
目标: 在 Linux 根目录上启用 OverlayFS ,使系统中所有读写操作均发生在上层目录,重启即还原
### rhel 9
新建 `/usr/lib/dracut/modules.d/90overlayfs` 目录和目录里的2个文件
```bash
# module-setup.sh
#!/usr/bin/bash
check() {
    return 0
}

depends() {
    echo base
}

installkernel() {
    hostonly="" instmods overlay
}

install() {
    inst_hook pre-pivot 10 "$moddir/mount-overlayfs.sh"
}

# mount-overlayfs.sh
#!/usr/bin/sh
type getarg > /dev/null 2>&1 || . /lib/dracut-lib.sh
getargbool 0 rd.overlayfs && overlayfs="yes"
[ -z "$overlayfs" ] && exit 0

mkdir -p /run/ovfs/{lower,upper,work}
mount --bind "$NEWROOT" /run/ovfs/lower
# mount /dev/disk/by-id/xxxx /run/ovfs/upper
mount -t overlay overlay -o ro,lowerdir=/run/ovfs/lower,upperdir=/run/ovfs/upper,workdir=/run/ovfs/work "$NEWROOT"
```
打包 initramfs
```bash
echo 'add_dracutmodules+=" overlayfs "' > /etc/dracut.conf.d/overlayfs.conf
mv -f /boot/initramfs-`uname -r`.img{,.ori}
dracut -f /boot/initramfs-`uname -r`.img
grubby --args="rd.overlayfs" --update-kernel=ALL
```
重启后在系统里做的所有操作均发生在内存中.如果需要临时更改,只需在 grub 编辑界面删除 `rd.overlayfs` .如果需要永久更改,可以将硬盘分区挂载到 `upper` 目录,如注释所示
### debian 12
原理同上,但是所用命令略有不同,先 hook 掉 mountroot 函数
```bash
# /etc/initramfs-tools/scripts/overlay
mountroot() {
    local_mount_root
    mkdir /rootfs
    mount -t tmpfs tmpfs /rootfs
    mkdir /rootfs/lower /rootfs/upper /rootfs/work
    mount -n -o move "${rootmnt}" /rootfs/lower
    # mount UUID=xxx-xxxx-xxxx-xxxx /rootfs/upper
    mount -t overlay overlay -o lowerdir=/rootfs/lower,upperdir=/rootfs/upper,workdir=/rootfs/work "${rootmnt}"
}
```
打包 initramfs ,添加内核启动参数
```bash
# 替换init镜像
echo overlay >> /etc/initramfs-tools/modules
a=`uname -r`
mv /boot/initrd.img-$a{,.ori}
update-initramfs -c -k $a
# 在启动过程中执行 overlay 脚本
echo 'GRUB_CMDLINE_LINUX="boot=overlay"' > /etc/default/grub.d/overlay.cfg
grub-mkconfig -o /boot/grub/grub.cfg
```
### 附: 手动解包 initramfs.img
```bash
# 解包
t=$(cpio -t < initramfs.img 2>&1 1>&- | grep -oP '\d+') # 获取微码大小
dd if=./initramfs.img of=m.bin bs=512 count=$t # 提取微码
dd if=./initramfs.img of=t.img bs=512 skip=$t # 提取 initramfs
mkdir initramfs; cd $_
zcat ../t.img | cpio -idm # 根据不同压缩格式选择不同的解压缩工具
# 打包
find . | cpio -ocR root:root | gzip -9 > ../t.img.new
cat ../m.bin ../t.img.new > ../initramfs.img.new
```