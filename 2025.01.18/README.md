# Windows 启用 sshd
1. 开启服务
    ```powershell
    Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.*' | Add-WindowsCapability -Online
    ```
2. 默认登录shell为 `cmd` ,改为 `powershell`
    ```powershell
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
    ```
3. 服务的自启,启动和重启
    ```powershell
    Set-Service -Name sshd -StartupType Automatic
    Start-Service -Name sshd
    Restart-Service -Name sshd -Force
    ```
4. 二进制文件在 `C:\Windows\System32\OpenSSH` ,配置文件为 `C:\ProgramData\ssh\sshd_config` ,改变端口须同时修改防火墙和配置文件
    ```powershell
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 8022
    ```
5. 管理员组登录密钥放在 `C:\ProgramData\ssh\administrators_authorized_keys` ,普通用户密钥放在 `~\.ssh\authorized_keys` ,并确保该文件权限正确
    ```powershell
    icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
    ```