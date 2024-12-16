rem Windows Server 2025 虚拟机初始化
rem 运行脚本前安装 vmware-tools
cd /d "%~dp0"
rem 密码最长使用期限
net accounts /maxpwage:unlimited
rem 无须按 Ctrl+Alt+Del 登录
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v disablecad /t REG_DWORD /d 1 /f
rem 禁用关机事件
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v ShutDownReasonOn /t REG_DWORD /d 0 /f
rem 登录时不启动服务器管理器
reg add "HKLM\SOFTWARE\Microsoft\ServerManager" /v DoNotOpenServerManagerAtLogon /t REG_DWORD /d 1 /f
rem 关闭自动更新
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f
rem 显示文件扩展名和隐藏文件
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideDrivesWithNoMedia /t REG_DWORD /d 0 /f
rem 自动登录, autologon 来自 https://learn.microsoft.com/en-us/sysinternals/
Autologon.exe /accepteula administrator "" "123qwe!@#QWE"
rem KMS激活
slmgr //b /ipk D764K-2NDRG-47T6Q-P8T8W-YP6DF
slmgr //b /skms kms.03k.org
slmgr //b /ato
rem 禁止自动关闭屏幕
powercfg /x -monitor-timeout-ac 0
rem 移除 AzureArcSetup
dism /online /remove-capability /capabilityname:azurearcsetup~~~~ /norestart
rem 移除 Windows Defender
dism /online /disable-feature /featurename:windows-defender /norestart
rem 禁用防火墙
netsh advfirewall set allprofiles state off
rem 设置主机名
netdom renamecomputer %COMPUTERNAME% /newname "win2025" /force
rem 安装 Windows 更新, expect 来自 https://github.com/hymkor/expect
expect.exe update.lua
rem 关机
start /b "" cmd /c del /f /q expect.exe update.lua Autologon.exe "%~nx0" & shutdown /s /t 0
