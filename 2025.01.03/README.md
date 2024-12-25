# 系统一键自毁
### Linux
一般情况下,在 Linux 系统上较为容易,只需用 root 权限执行
```bash
for i in {1..5}; do # 擦写5次sda
    dd if=/dev/zero of=/dev/sda bs=1M conv=noerror &
done
wait
echo b > /proc/sysrq-trigger # 重启
```
### Windows
由于 Windows 内核限制,如果不注入代码到内核态,只能覆写系统盘的前`1M`数据,约等于删除分区表,并无实际意义,然而可以"曲线救国"

1. 设置 -> 更新和安全 -> 恢复 -> 重置此电脑
    ```powershell
    $namespaceName = "root\cimv2\mdm\dmmap"
    $className = "MDM_RemoteWipe"
    $methodName = "doWipeProtectedMethod"
    $session = New-CimSession

    $params = New-Object Microsoft.Management.Infrastructure.CimMethodParametersCollection
    $param = [Microsoft.Management.Infrastructure.CimMethodParameter]::Create("param", "", "String", "In")
    $params.Add($param)

    $instance = Get-CimInstance -Namespace $namespaceName -ClassName $className -Filter "ParentID='./Vendor/MSFT' and InstanceID='RemoteWipe'"
    $session.InvokeMethod($namespaceName, $instance, $methodName, $params)
    ```
    [参考](https://techcommunity.microsoft.com/t5/windows-deployment/factory-reset-windows-10-without-user-intervention/m-p/1339823),通过系统重置来清空硬盘,需要以 `system` 权限运行
2. 使用随机密钥加密 BitLocker
    ```ps1
    # 组策略: 计算机配置 -> 管理模板 -> Windows 组件 -> BitLocker 驱动器加密 -> 操作系统驱动器 -> 启动时需要附加身份验证 -> 已启用
    $p="HKLM:\SOFTWARE\Policies\Microsoft\FVE"
    New-Item -Force -Path $p
    Set-ItemProperty -Path $p -Name "EnableBDEWithNoTPM" -Value 1
    Set-ItemProperty -Path $p -Name "UseAdvancedStartup" -Value 1
    Set-ItemProperty -Path $p -Name "UseTPM" -Value 2
    Set-ItemProperty -Path $p -Name "UseTPMPIN" -Value 2
    Set-ItemProperty -Path $p -Name "UseTPMKey" -Value 2
    Set-ItemProperty -Path $p -Name "UseTPMKeyPIN" -Value 2
    # 启用 BitLocker 全盘加密
    $s = ConvertTo-SecureString "$(Get-Random)$p$(Get-Random)$(Get-Random)$(Get-Random)" -AsPlainText -Force
    Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -SkipHardwareTest -Password $s -PasswordProtector
    # 监测加密是否完成
    while ($true) {
        $p = Get-BitLockerVolume -MountPoint "C:" | Select-Object -ExpandProperty "EncryptionPercentage"
        if ($p -eq 100) { Restart-Computer -Force }
        Start-Sleep -Seconds 5
    }
    ```
    重启后,在开机时会要求输入密码,但是密码是啥谁也不知道.只需以管理员权限运行,但对于已经启用 `BitLocker` 的机器无效