#!/bin/bash
# RHEL/Rocky 9 虚拟机初始化

if grep -q Rocky /etc/os-release; then
rm -rf /etc/yum.repos.d/*
echo '[baseos]
name=Rocky Linux $releasever - BaseOS
baseurl=https://mirrors.ustc.edu.cn/rocky/$releasever/BaseOS/$basearch/os/
gpgcheck=0
enabled=1

[appstream]
name=Rocky Linux $releasever - AppStream
baseurl=https://mirrors.ustc.edu.cn/rocky/$releasever/AppStream/$basearch/os/
gpgcheck=0
enabled=1

[crb]
name=Rocky Linux $releasever - CRB
baseurl=https://mirrors.ustc.edu.cn/rocky/$releasever/CRB/$basearch/os/
gpgcheck=0
enabled=1

[extras]
name=Rocky Linux $releasever - Extras
baseurl=https://mirrors.ustc.edu.cn/rocky/$releasever/extras/$basearch/os/
gpgcheck=0
enabled=1

[plus]
name=Rocky Linux $releasever - Plus
baseurl=https://mirrors.ustc.edu.cn/rocky/$releasever/plus/$basearch/os/
gpgcheck=0
enabled=1' > /etc/yum.repos.d/rocky.repo
fi

echo '[epel]
name=Extra Packages for Enterprise Linux $releasever - $basearch
baseurl=https://mirrors.ustc.edu.cn/epel/$releasever/Everything/$basearch/
enabled=1
gpgcheck=0

[epel-testing]
name=Extra Packages for Enterprise Linux $releasever - Testing - $basearch
baseurl=https://mirrors.ustc.edu.cn/epel/testing/$releasever/Everything/$basearch/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/epel.repo

dnf update -y
dnf install -y vim tree wget bash-completion tmux jq python3-pip git socat strace unzip lrzsz
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 配置家目录
cd /root
rm -f anaconda-ks.cfg
sed -i '/^alias/d' .bashrc
cat >> .bashrc << "EEE"
function pp(){ ( IFS='|'; grep -P "($*)" ) <<< "$(ps -efHww)"; }
alias ll='ls -alhF'
alias ss='ss -anltup'
HISTFILESIZE=400000
HISTSIZE=10000
PROMPT_COMMAND="history -a"
HISTTIMEFORMAT='| %F %T | '
export HISTSIZE PROMPT_COMMAND HISTTIMEFORMAT
PS1="\[\e[0;31m\][\h:\w]\\$ \[\e[0m\]"
EEE
echo 'syntax on
set paste
set hlsearch
set mouse-=a' > .vimrc
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDcvx/MYzIPzHaXibbU/6eRO6G0vSb5q04awI/hfwoUOjVK3R5007agxmoMtNewiVgk7dOMsfTEzJZ1wdpr80ob12XTZXZl3pVbEJaKaWxKOYxfTwXiWtplaH4sCzlHtELvh7ZAQmB8qHZrhIqXlHk69LoLj9aHRUZSUo6nvULxKJ06iuQJkv/W1jyC/KrZZwh7jJPxLYtl2gw8H+VdUR5GBooi+GiXvTQMag/zU0HK6ThXN0AVv1Yj5D/DuRtKxSExmKqCgJk1y5tX5vlmSqiDHexuguadSb+hExNi73lhl+tmx5x7bG5RxQiD24fkp+VD9CG7VveVlbuwQvxE40HAZmD2OrsD1iOXYbd0SGr9WOJN4Xnnii1jRPUaDSkpB7ody6zUkvn2pWJY1URixpo64RISncqlysHuQHZ+Z5yrH0tBck//zZ1UrDX7HJPYH4ejib7GUrBfXo0prvx9rWR6/0aRZ0MdcnZDEnzDzvfSdcNqeboAorWOl34v34YbwVs= root@kali' > .ssh/authorized_keys
echo '-----BEGIN OPENSSH PRIVATE KEY-----
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
6NDnY/Rt3mPW8AAAAJcm9vdEBrYWxpAQI=
-----END OPENSSH PRIVATE KEY-----
' > .ssh/id_rsa
echo 'Host 192.168.* 10.* 172.16.* 172.17.* 172.18.* 172.19.* 172.2?.* 172.30.* 172.31.* 
    User root
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
' > .ssh/config
chmod 400 .ssh/*

sed -i '/^GRUB_TIMEOUT/s/=.*$/=1/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config
systemctl mask firewalld.service
sed -i '1aIP:\\4' /etc/issue
sed -i '/^ExecStart=/cExecStart=-/sbin/agetty --autologin root --noclear %I' /usr/lib/systemd/system/getty@.service
echo 'net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1' >> /etc/sysctl.d/99-sysctl.conf
systemctl daemon-reload
mkdir /mnt/share
echo '.host:/Downloads /mnt/share fuse.vmhgfs-fuse defaults,allow_other,nofail 0 0' >> /etc/fstab
cd /sbin # 此处为了解决系统里无 mount.fuse 的 bug ,可能删
ln -s mount.fuse3 mount.fuse

echo -n > /root/.bash_history
mount --bind /dev/null /root/.bash_history
poweroff