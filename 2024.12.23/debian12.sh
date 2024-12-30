#!/bin/bash
# Debian 12 虚拟机初始化

# 更新系统
for i in ' bookworm' ' bookworm-updates' ' bookworm-backports' '-security bookworm-security'; do
    echo "deb https://mirrors.ustc.edu.cn/debian$i main contrib non-free non-free-firmware"
done > /etc/apt/sources.list
apt-get update -yq && apt-get full-upgrade -yq

# 配置开发环境
apt-get install -y build-essential linux-headers-amd64 python3-pip curl tmux git yq vim socat xxd tree strace gdb unzip lrzsz
rm -f /usr/lib/python3.11/EXTERNALLY-MANAGED
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 配置家目录
cd /root
cat > .bashrc << "EEE"
. /etc/bash_completion
function pp(){ ( IFS='|'; grep -P "($*)" ) <<< "$(ps -efHww)"; }
alias ls='ls --color=auto'
alias ll='ls -AlhF'
alias ss='ss -anltup'
alias grep='grep --color=auto'
HISTFILESIZE=400000
HISTSIZE=10000
PROMPT_COMMAND="history -a"
HISTTIMEFORMAT='| %F %T | '
export HISTSIZE PROMPT_COMMAND HISTTIMEFORMAT
PS1="\[\e[0;32m\][\h:\w]\\$ \[\e[0m\]"
EEE
echo 'syntax on
set paste
set hlsearch
set mouse-=a' > .vimrc
mkdir .ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDcvx/MYzIPzHaXibbU/6eRO6G0vSb5q04awI/hfwoUOjVK3R5007agxmoMtNewiVgk7dOMsfTEzJZ1wdpr80ob12XTZXZl3pVbEJaKaWxKOYxfTwXiWtplaH4sCzlHtELvh7ZAQmB8qHZrhIqXlHk69LoLj9aHRUZSUo6nvULxKJ06iuQJkv/W1jyC/KrZZwh7jJPxLYtl2gw8H+VdUR5GBooi+GiXvTQMag/zU0HK6ThXN0AVv1Yj5D/DuRtKxSExmKqCgJk1y5tX5vlmSqiDHexuguadSb+hExNi73lhl+tmx5x7bG5RxQiD24fkp+VD9CG7VveVlbuwQvxE40HAZmD2OrsD1iOXYbd0SGr9WOJN4Xnnii1jRPUaDSkpB7ody6zUkvn2pWJY1URixpo64RISncqlysHuQHZ+Z5yrH0tBck//zZ1UrDX7HJPYH4ejib7GUrBfXo0prvx9rWR6/0aRZ0MdcnZDEnzDzvfSdcNqeboAorWOl34v34YbwVs= root@kali' > .ssh/authorized_keys
echo '-----BEGIN OPENSSH PRIVATE KEY-----
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
6NDnY/Rt3mPW8AAAAJcm9vdEBrYWxpAQI=
-----END OPENSSH PRIVATE KEY-----
' > .ssh/id_rsa
echo 'Host *
    User root
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
' > .ssh/config
chmod 400 .ssh/*

# 做一些处理
mkdir /mnt/share
echo '.host:/Downloads /mnt/share fuse.vmhgfs-fuse defaults,allow_other 0 0' >> /etc/fstab
sed -i '/^GRUB_TIMEOUT/s/=.*$/=1/' /etc/default/grub
update-grub
sed -i '1aIP:\\4' /etc/issue
sed -i '/^ExecStart=/cExecStart=-/sbin/agetty --autologin root --noclear %I' /usr/lib/systemd/system/getty@.service
echo 'net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1' >> /etc/sysctl.d/99-sysctl.conf
systemctl daemon-reload

# 删除非root用户和清空历史
ls /home/ | xargs -n1 userdel -rf
echo -n > /root/.bash_history
mount --bind /dev/null /root/.bash_history
poweroff
