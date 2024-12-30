# 监控 ssh 会话
### ttylog
当用户已经处于登录状态时,可以用 [ttylog](https://metacpan.org/release/BBB/ttylog-0.85/view/ttylog) 查看他的会话内容,原理是通过 `strace` 调试对方的 sshd 进程.要确保自己拥有高于或等于对方的权限,和比对方更宽的窗口以避免不必要的折行,然后执行 `./ttylog pts/0` ,`pts/0` 为对方的终端设备
### ttyecho
同时可以用以下脚本 `ttyecho` 控制对方的终端,强行插入自己的命令
```python
#!/usr/bin/python3
import sys, fcntl, termios
cmd = sys.argv[2:]
flags = cmd.pop(0) if cmd[0] == "-n" else ""
cmd = " ".join(cmd)
cmd += "\n" if flags else ""

with open("/dev/" + sys.argv[1], "w") as f:
    for c in cmd:
        fcntl.ioctl(f, termios.TIOCSTI, c)
```
1. 执行 `ls` 命令: `./ttyecho pts/0 -n ls -al /etc` , `-n`表明敲完命令回车
2. 发送一些特殊字符,比如 `esc` ,一般用于控制vim: `./ttyecho pts/0 $'\x1b'`
### script
当用户未登录时,可以用 `script` 命令记录 ssh 会话全过程,约等于录屏
1. 有如下脚本 `/usr/local/bin/audit.sh`
    ```bash
    #!/bin/bash
    t="/var/log/ssh_${USER}_${SSH_CLIENT%% *}_$(date +%FT%TS%4N)"
    # 避免影响到 scp 和 sftp 命令
    if [[ $SSH_ORIGINAL_COMMAND ]]; then
        eval "$SSH_ORIGINAL_COMMAND"
        exit
    fi
    script -qfe -t$t.tim $t.out
    ```
2. ssh 登录时执行脚本
    ```bash
    chmod +x /usr/local/bin/audit.sh
    echo 'ForceCommand /usr/local/bin/audit.sh' >> /etc/ssh/sshd_config
    systemctl restart ssh.service
    ```
3. 播放会话内容
    ```bash
    scriptreplay 1.tim 1.out
    ```
