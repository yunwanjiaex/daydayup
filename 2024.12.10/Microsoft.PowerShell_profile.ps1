Set-PSReadlineKeyHandler -Chord Ctrl+d -Function DeleteCharOrExit
Write-Host -NoNewLine "$([char]0x1B)[6 q"
