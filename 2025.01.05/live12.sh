#!/usr/bin/bash
# 制作 Debian 12 LiveCD ,参考 https://www.willhaley.com/blog/custom-debian-live-environment/

apt-get update
apt-get install -y debootstrap squashfs-tools xorriso isolinux syslinux-efi grub-pc-bin grub-efi-amd64-bin grub-efi-ia32-bin mtools dosfstools
rm -rf /LIVECD; mkdir -p /LIVECD/{staging/{efi/boot,boot/grub/x86_64-efi,isolinux,live},tmp}; cd /LIVECD
debootstrap --arch=amd64 --variant=minbase bookworm ./rootfs http://mirrors.ustc.edu.cn/debian/

for i in dev sys proc dev/pts; do
    mount --bind /$i ./rootfs/$i
done
# 配置系统,其它地方都是固定流程,只需修改这里即可
chroot ./rootfs << 'EOF'
echo debian-livecd > /etc/hostname
for i in ' bookworm' ' bookworm-updates' ' bookworm-backports' '-security bookworm-security'; do
    echo "deb http://mirrors.ustc.edu.cn/debian$i main contrib non-free non-free-firmware"
done > /etc/apt/sources.list
apt-get update && apt-get full-upgrade -y
apt-get install -y --no-install-recommends linux-image-amd64 live-boot systemd-sysv vim tmux openssh-server curl iproute2 iputils-ping network-manager
apt-get autoremove -y && apt-get clean -y
echo root:pppppp | chpasswd
echo 'PermitRootLogin yes
PubkeyAuthentication yes
PasswordAuthentication yes' > /etc/ssh/sshd_config.d/root.conf
# 此处在 chroot 环境中,做任何你想做的
# 开机启动脚本,使用前需确认网络状态
echo '#!/bin/bash
tmux new-session -d ping 127.0.0.1' > /etc/rc.local
chmod +x /etc/rc.local
EOF
umount ./rootfs/{dev/pts,dev,sys,proc}

# 打包文件系统
mksquashfs ./rootfs ./staging/live/filesystem.squashfs -e boot {vmlinuz,initrd.img}{,.old}
cp ./rootfs/boot/vmlinuz-* ./staging/live/vmlinuz
cp ./rootfs/boot/initrd.img-* ./staging/live/initrd

# 配置 BIOS 启动
cat << 'EOF' > ./staging/isolinux/isolinux.cfg
UI vesamenu.c32

MENU TITLE Boot Menu
DEFAULT linux
TIMEOUT 100
MENU RESOLUTION 640 480

LABEL linux
  MENU LABEL Debian 12 BIOS toram
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live toram

LABEL linux
  MENU LABEL Debian 12 BIOS nomodeset
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live nomodeset
EOF
cp /usr/lib/ISOLINUX/isolinux.bin ./staging/isolinux/
cp /usr/lib/syslinux/modules/bios/* ./staging/isolinux/

# 配置 UEFI 启动
cat << 'EOF' > ./staging/boot/grub/grub.cfg
insmod part_gpt
insmod part_msdos
insmod fat
insmod iso9660
insmod all_video
insmod font

set default="0"
set timeout=10

menuentry "Debian 12 EFI toram" {
  search --no-floppy --set=root --label DEBLIVE
  linux ($root)/live/vmlinuz boot=live toram
  initrd ($root)/live/initrd
}

menuentry "Debian 12 EFI nomodeset" {
  search --no-floppy --set=root --label DEBLIVE
  linux ($root)/live/vmlinuz boot=live nomodeset
  initrd ($root)/live/initrd
}
EOF
cp ./staging/boot/grub/grub.cfg ./staging/efi/boot/
cp -r /usr/lib/grub/x86_64-efi/* ./staging/boot/grub/x86_64-efi/

# 制作 UEFI 启动文件
cat << 'EOF' > ./tmp/grub-embed.cfg
if ! [ -d "$cmdpath" ]; then
  if regexp --set=1:isodevice '^(\([^)]+\))\/?[Ee][Ff][Ii]\/[Bb][Oo][Oo][Tt]\/?$' "$cmdpath"; then
    cmdpath="${isodevice}/efi/boot"
  fi
fi
configfile "${cmdpath}/grub.cfg"
EOF
grub-mkstandalone -O i386-efi --modules="part_gpt part_msdos fat iso9660" --locales="" --themes="" --fonts="" --output=./staging/efi/boot/bootia32.efi boot/grub/grub.cfg=./tmp/grub-embed.cfg
grub-mkstandalone -O x86_64-efi --modules="part_gpt part_msdos fat iso9660" --locales="" --themes="" --fonts="" --output=./staging/efi/boot/bootx64.efi boot/grub/grub.cfg=./tmp/grub-embed.cfg

# 制成镜像
dd if=/dev/zero of=./staging/efiboot.img bs=1M count=20
mkfs.vfat ./staging/efiboot.img
mmd -i ./staging/efiboot.img ::/efi ::/efi/boot
mcopy -vi ./staging/efiboot.img ./staging/efi/boot/bootia32.efi ./staging/efi/boot/bootx64.efi ./staging/boot/grub/grub.cfg ::/efi/boot/
xorriso -as mkisofs -iso-level 3 -o ./debian-custom.iso -full-iso9660-filenames -volid "DEBLIVE" --mbr-force-bootable -partition_offset 16 -joliet -joliet-long -rational-rock -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -eltorito-boot isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table --eltorito-catalog isolinux/isolinux.cat -eltorito-alt-boot -e --interval:appended_partition_2:all:: -no-emul-boot -isohybrid-gpt-basdat -append_partition 2 C12A7328-F81F-11D2-BA4B-00A0C93EC93B ./staging/efiboot.img ./staging