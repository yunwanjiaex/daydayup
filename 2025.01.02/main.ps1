Set-Location -Path $PSScriptRoot
function format_date { Get-Date -Format "yy.MM.dd_HH.mm.ss_ffffff" }

# 同步本地和远程都有可能有改变的代码
git pull
git add -A
git commit -m "$(format_date)"
git push

# 进入最后一个 once 开头的文件夹,若有 res.txt 或没有 run.ps1 则退出
Get-ChildItem -Directory -Filter once* | Select-Object -Last 1 | Set-Location
$res = "res_${env:computername}.txt"
if ((Test-Path -Path $res) -or (-not (Test-Path -Path run.ps1))) { Exit }

# 否则执行 run.ps1 ,执行结果写入 res.txt
"start at $(format_date)" | Out-File -FilePath $res
powershell -NoProfile -ExecutionPolicy Bypass -File run.ps1 | Out-File -FilePath $res -Append
"finish at $(format_date)" | Out-File -FilePath $res -Append