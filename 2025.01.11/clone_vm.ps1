# 批量克隆 VMware Workstation 虚拟机
param(
    [Parameter(Mandatory = $true)][string]$vm,
    [Parameter(Mandatory = $true)][string]$snap,
    [int]$count = 1, [string[]]$command
)
$vmrun = 'C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe'
$vmpath = 'C:\Users\kunkun\Documents\vm'
for ($t = 1; $t -le $count; $t++) {
    $newvm = "$vm-$t"
    & $vmrun -T ws clone "$vmpath\$vm\$vm.vmx" "$vmpath\$newvm\$newvm.vmx" linked -snapshot="$snap" -cloneName="$newvm"
    if (-not $command) { continue }
    & $vmrun -T ws start "$vmpath\$newvm\$newvm.vmx"
    & $vmrun -T ws getGuestIPAddress "$vmpath\$newvm\$newvm.vmx" -wait
    & $vmrun -gu $command[0] -gp $command[1] -T ws runProgramInGuest "$vmpath\$newvm\$newvm.vmx" $command[2..$command.count]
}

# usage: .\clone_vm.ps1 -vm debian12 -snap initial -count 3 -command root,"ppsswwdd",/bin/bash,-c,"apt-get update; apt-get full-upgrade -y; poweroff"
# 意思是: 克隆名称为 debian12 的虚拟机的 initial 快照,克隆3个,如果有 command 参数则开启克隆的虚拟机执行后面跟着的命令,以 root 身份,密码为 ppsswwdd 登录系统执行 apt-get 和 poweroff 命令,没有 command 则不开机