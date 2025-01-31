# 重置 Windows 开机密码
1. 进入 PE 或登陆界面按住 `Shift` 键重启,疑难解答,高级选项,命令提示符
2. 执行
    ```bat
    cd C:\Windows\System32
    copy Utilman.exe Utilman.exe.bak /y
    copy cmd.exe Utilman.exe /y
    shutdown /r /t 0
    ```
3. 再次进入系统后,在登陆界面点击右下角的辅助功能打开 cmd 窗口,执行
    ```bat
    net user administrator ppsswwdd
    ```
4. 进入系统后,将 `Utilman.exe` 还原