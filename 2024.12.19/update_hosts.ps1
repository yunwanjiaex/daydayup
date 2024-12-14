# 更新 Steam 和 Github 的 hosts
$h = "C:\Windows\System32\drivers\etc\hosts"
(Test-Path -Path "$h.ori") -or (Copy-Item -Path $h -Destination "$h.ori")
Invoke-RestMethod -Uri https://gitlab.com/ineo6/hosts/-/raw/master/next-hosts | Set-Content -Path $h
ipconfig /flushdns
Invoke-RestMethod -Uri https://raw.githubusercontent.com/Clov614/SteamHostSync/main/Hosts_steam | Add-Content -Path $h
ipconfig /flushdns