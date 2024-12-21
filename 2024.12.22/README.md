# Windows 文件共享服务
1. 服务端开启和关闭
    ```cmd
    net share foooo=C:\shared /GRANT:username,FULL /UNLIMITED
    net share /delete foooo
    ```
2. 客户端连接和删除
    ```cmd
    net use Z: \\192.168.xx.xx\foooo password /user:username
    net use Z: /delete
    ```
3. 服务端执行以下命令关闭远程 `UAC` 限制
    ```powershell
    reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
    ```
    客户端就可以使用 [PsExec](https://learn.microsoft.com/en-us/sysinternals/downloads/psexec) 执行远程命令
    ```powershell
    .\PsExec64.exe \\192.168.xx.xx /u username /p password /accepteula /s powershell -NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -Command ls C:\
    ```
4. 服务端启用匿名共享
    ```powershell
    New-Item -Type Directory -Path C:\shared
    net user guest /active:yes
    icacls C:\shared /grant 'Everyone:(OI)(CI)F' /T
    net share foooo=C:\shared /GRANT:Everyone,FULL /GRANT:"ANONYMOUS LOGON",FULL /UNLIMITED
    # 计算机配置->Windows设置->安全设置->本地策略->用户权限分配->拒绝从网络访问这台计算机->删除Guest
    secedit /export /cfg cfg.ini
    (Get-Content cfg.ini) -replace "SeDenyNetworkLogonRight = Guest","SeDenyNetworkLogonRight =" | Set-Content cfg.ini
    secedit /configure /db sec.sdb /cfg cfg.ini
    gpupdate /force
    ```
    客户端允许匿名登录,可使用任意用户名登录服务
    ```cmd
    reg add HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters /v AllowInsecureGuestAuth /t REG_DWORD /d 1 /f
    ```
5. 第三方工具如 [gohttpserver](https://github.com/codeskyblue/gohttpserver) ,另外还有一些带有图形界面的程序可以用 [winsw](https://github.com/winsw/winsw) 打包成系统服务来使用
    ```powershell
    .\gohttpserver.exe --root=C:\Users\kafka\Downloads --addr=0.0.0.0:8080 --upload --delete --no-index
    # 命令行下载
    curl -O 192.168.xx.x:8080/win11.iso
    # 命令行上传
    curl -F "file=@win11.iso" 192.168.xx.x:8080/tmp/cc
    ```