Set-Location -Path $PSScriptRoot
# 同步本地和远程都有可能有改变的代码
git stash
git pull
git stash pop
git add -A
git commit -m "$(Get-Date -Format "yy.MM.dd_HH.mm.ss_ffffff")"
git push

Get-ChildItem -Directory -Filter task_* | ForEach-Object { Start-Job {
        Set-Location -Path $args[0].FullName
        # 没有 run 直接退出
        if ( -not ( Test-Path -Path run.ps1 ) ) { exit }
        if (Test-Path -Path sch.ps1) {
            # sch 运行失败说明暂时不符合执行条件,退出
            powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File sch.ps1
            if ( -not $?) { exit }
        }
        else {
            # 无 sch 有 res 说明已经运行过,退出
            if (Test-Path -Path res.txt) { exit }
        }

        "=========================start==========================" | Out-File -FilePath res.txt
        powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File run.ps1 2>&1 | Out-File -FilePath res.txt -Append
        "=========================finish=========================" | Out-File -FilePath res.txt -Append
    } -ArgumentList $_ }
Get-Job | Wait-Job