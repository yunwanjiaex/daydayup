Set-Location -Path $PSScriptRoot
New-Item -ItemType File -Path "once_$(Get-Date -Format "yy.MM.dd_HH.mm.ss_ffffff")\run.ps1" -Force