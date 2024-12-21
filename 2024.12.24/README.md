# 重启后继续执行
### Windows
```powershell
$argv = $script:MyInvocation.UnboundArguments
$psfile = $script:MyInvocation.MyCommand.Path
$md5 = Get-FileHash $psfile -Algorithm md5 | Select-Object -ExpandProperty Hash
if ($argv[0] -ne '--reboot') {
    # 添加开机启动的计划任务
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass $psfile --reboot $argv"
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -TaskName $md5 -Action $action -Trigger $trigger -RunLevel Highest
    
    Write-Host 'do something here before reboot'
    Restart-Computer -Force
}
else {
    $argv.RemoveAt('0')
    # 删除计划任务并继续运行
    Unregister-ScheduledTask -TaskName $md5 -Confirm:$false

    Write-Host 'do something here after reboot'
}
```
* 添加任务计划使脚本在重启后可以继续执行,需要管理员权限
### Linux
```bash
script=$(cd "$(dirname "$0")"; echo "$(pwd)/$(basename "$0")")
md5=$(md5sum "$script" | cut -d' ' -f1)
test x$1 != x--reboot && {
    echo "
        [Unit]
        Description=$md5 service
        [Service]
        User=root
        ExecStart=/bin/bash '$script' --reboot $@
        [Install]
        WantedBy=multi-user.target
    " | sed '1d;$d;s/^ \{8\}//' > /usr/lib/systemd/system/$md5.service
    systemctl enable $md5.service
    
    echo 'do something here before reboot'
    reboot
} || {
    shift
    systemctl disable $md5.service
    rm -f /usr/lib/systemd/system/$md5.service

    echo 'do something here after reboot'
}
```
* 同上,需root权限