# 生成一个新目录
Set-Location -Path $PSScriptRoot/..
[DateTime]$d = Get-ChildItem -Directory -Filter 20* | Select-Object -Last 1 -ExpandProperty Name
[String]$d = $d.adddays(1).ToString("yyyy.MM.dd")
New-Item -Force -ItemType File -Path "$d/README.md"
Add-Content -Path .\README.md -Value "| $d | [xxxxxxxxxx](./$d/README.md) | xxxxxxxxx |"