# Termux 和它的 ssh
1. 安装 [Termux](https://f-droid.org/zh_Hans/packages/com.termux/) 并初始化
    ```bash
    # 修改为中科大源或清华源
    termux-change-repo
    apt update -y && apt full-upgrade -y -o Dpkg::Options::="--force-confnew"
    # 再次修改
    termux-change-repo 
    # 安装一些常用软件
    apt install -y build-essential python vim openssh wget android-tools iproute2 mount-utils bash-completion 
    # 读取共享存储中的内容
    termux-setup-storage
    ```
2. 配置 sshd ,只允许密钥登录,监听 42824 端口
    ```bash
    echo 'PrintMotd no
    PasswordAuthentication no
    PermitEmptyPasswords no
    PubkeyAuthentication yes
    AuthorizedKeysFile .ssh/authorized_keys
    TCPKeepAlive yes
    Subsystem sftp /data/data/com.termux/files/usr/libexec/sftp-server
    Port 42824' > /data/data/com.termux/files/usr/etc/ssh/sshd_config
    # 将公钥内容替换到这里
    echo 'ssh-rsa AAAA....' > ~/.ssh/authorized_keys
    ```
3. 安装 [Termux:Boot](https://f-droid.org/zh_Hans/packages/com.termux.boot/) 后配置开机启动
    ```bash
    mkdir -p ~/.termux/boot/
    echo '#!/data/data/com.termux/files/usr/bin/bash
    termux-wake-lock
    sshd' > ~/.termux/boot/start-sshd
    chmod +x ~/.termux/boot/start-sshd
    ```
4. 启用 adb 调试后,在 `Termux` 中连接
    ```bash
    adb connect 192.168.xx.xx
    adb -s 192.168.xx.xx:5555 shell
    ```
    或在 `adb` 中调用 `Termux` 命令
    ```bash
    run-as com.termux files/usr/bin/bash -lic 'export PATH=/data/data/com.termux/files/usr/bin:$PATH; export LD_PRELOAD=/data/data/com.termux/files/usr/lib/libtermux-exec.so; bash -i'
    ```