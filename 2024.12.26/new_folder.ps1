# 生成一个新目录
Set-Location -Path $PSScriptRoot/..
[DateTime]$d = Get-ChildItem -Directory -Filter 20* | Select-Object -Last 1 -ExpandProperty Name
$t = (Get-Date).AddDays(-1)
if ($d -le $t) { $d = $t }
[String]$d = $d.AddDays(1).ToString("yyyy.MM.dd")
New-Item -Force -ItemType File -Path "$d/README.md"
Set-Content -Path "$d/README.md" -Value "# "
Add-Content -Path .\README.md -Value "| $d | [xxxxxxxxxx](./$d/README.md) | xxxxxxxxx |"