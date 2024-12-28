# 远程 PowerShell
### 远程终端
1. 服务端和客户端都启用: `winrm quickconfig -quiet -force`
2. 客户端信任服务端: `winrm set winrm/config/client @{TrustedHosts="*"}`
3. 连接服务端: `winrs -r:http://192.168.xx.xx:5985 -u:uuuuu -p:ppppp powershell`
### 远程PowerShell
1. 服务端和客户端同时开启,并互相信任
    ```powershell
    Enable-PSRemoting -SkipNetworkProfileCheck -Force
    Set-Item WSMan:localhost\Client\TrustedHosts -Value * -Force
    Set-NetFirewallRule -Name 'WINRM-HTTP*' -RemoteAddress Any
    ```
2. 执行命令
    ```powershell
    # 进入交互shell
    Enter-PSSession -ComputerName 192.168.xx.xx -Credential win2025\administrator
    # 单条命令
    Invoke-Command -ComputerName 192.168.xx.xx -Credential win2025\administrator -ScriptBlock { Get-ChildItem -Path $home }
    # -FilePath C:\test.ps1 执行脚本, $using:home 使用主控端变量 $home
    ```
3. 自动登录
    ```powershell
    # 将密码存入文件,登录时从文件读取
    ConvertTo-SecureString "123456" -AsPlainText -Force | ConvertFrom-SecureString | Set-Content "C:\passwd.txt"
    $passwd = Get-Content "C:\passwd.txt" | ConvertTo-SecureString
    $cred = New-Object System.Management.Automation.PSCredential("win2025\administrator",$passwd)
    Enter-PSSession -ComputerName 192.168.xx.xx -Credential $cred
    ```
### 网页PowerShell
1. 仅限 Windows Server 开启
    ```ps1
    Install-WindowsFeature -Name WindowsPowerShellWebAccess -IncludeManagementTools
    Install-PswaWebApplication -UseTestCertificate
    Add-PswaAuthorizationRule -UserName * -ComputerName * -ConfigurationName *
    ```
2. 访问 `https://xxxx/pswa`,用户名如 `win2025\administrator` ,计算机名如 `win2025`