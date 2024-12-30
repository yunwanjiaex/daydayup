# Linux 的备份与还原
### dd
```bash
dd if=/dev/zero of=dd.txt; rm -f dd.txt # 用 0 写满硬盘
dd if=/dev/sda1 | gzip > /mnt/b.gz # 备份
dd if=/mnt/b.gz | gunzip > /dev/sda1 # 还原
```
适用于完整备份任何数据,但是无法增量
### tar
```bash
tar --selinux --acls --xattrs -cf b.tgz -C /mnt/rootfs . # 备份
tar --selinux --acls --xattrs -xf b.tgz -C /mnt/rootfs # 还原
```
适用于备份 Linux 文件,在备份时加上 `-g m.txt` 可以记录文件更新数据,从而在下次备份时可以只将增量数据备份到另一个压缩包
### rsync
```bash
rsync -ahvzAX ./source ./dest
```
适用于同步目录,不打包,自带远程拷贝服务
### lvm
```bash
# 创建一个快照分区,数据在改动前会复制到这个分区,然后在原分区进行修改
lvcreate -pr -s -L 10G -n ssss /dev/debian-vg/root
# 应用更改,也就是删除快照分区
lvremove /dev/debian-vg/ssss
# 回滚到快照前,重新挂载或重启后生效
lvconvert --merge /dev/debian-vg/ssss
```
### btrfs
```bash
# 对根分区创建快照,同 lvm 一样也是 CoW ,恢复部分文件直接 cp 即可
btrfs subvolume snapshot -r / /hello
# 复制快照内容到另一个 btrfs 分区的目录中
btrfs send /hello | btrfs receive /mnt/backup
# 增量备份
btrfs subvolume snapshot -r / /hello-gen2
btrfs send -p /hello /hello-gen2 | btrfs receive /mnt/backup
# 删除快照,即应用更改
btrfs subvolume delete /hello
# 回滚到快照前的状态,重启进入 LiveCD, 若非正在使用的分区可以在线 mv
mount -t btrfs -o subvol=/ /dev/sda1 /mnt; cd $_
mv @rootfs waaaa
mv waaaa/hello @rootfs
# 重启后删除旧卷
btrfs subvolume set-default /
## btrfs subvolume list /
btrfs subvolume delete --subvolid xx /
```