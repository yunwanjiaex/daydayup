# 常用软件的安装与配置
Set-Location -Path $PSScriptRoot
function get-github-tag {
    param ($tag)
    return Invoke-RestMethod -Uri https://api.github.com/repos/$tag/releases/latest | Select-Object -ExpandProperty tag_name
}
function add-path {
    param ($path)
    # 将路径加入 PATH 变量
    $r = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\Environment", $true)
    $p = $r.GetValue("Path", "", "DoNotExpandEnvironmentNames")
    $r.SetValue("Path", $p.TrimEnd(";") + ";$path;", "ExpandString")
    [Environment]::SetEnvironmentVariable((New-Guid), [NullString]::value, 'User')
}

# Git
$t = get-github-tag git-for-windows/git # v2.47.1.windows.1
Invoke-WebRequest -Uri https://github.com/git-for-windows/git/releases/download/$t/MinGit-$($t -replace 'v(.+)\.win.*','$1')-64-bit.zip -OutFile a.zip
Expand-Archive -Path a.zip -DestinationPath "C:\Program Files\MinGit"
Remove-Item -Force -Recurse -Path a.zip
Copy-Item -Force -Recurse -Path .gitconfig, .ssh -Destination "$env:USERPROFILE"
add-path "C:\Program Files\MinGit\cmd"

# terminal
$t = get-github-tag microsoft/terminal # v1.21.3231.0
Invoke-WebRequest -Uri https://github.com/microsoft/terminal/releases/download/$t/Microsoft.WindowsTerminal_$($t -replace '^v','')_x64.zip -OutFile a.zip
Expand-Archive -Path a.zip -DestinationPath "$env:USERPROFILE\Documents\terminal"
Remove-Item -Force -Recurse -Path a.zip
# 注册右键菜单
$r = [Microsoft.Win32.RegistryKey]::OpenBaseKey("ClassesRoot", "Default")
$r = $r.CreateSubKey("Directory\Background\shell\wt", $true)
$r.SetValue($null, "Windows Terminal Here", "String")
$r.SetValue("Icon", "$env:USERPROFILE\Documents\terminal\wt.exe,0", "String")
$r = $r.CreateSubKey("Command", $true)
$r.SetValue($null, "$env:USERPROFILE\Documents\terminal\wt.exe", "String")
# 注册字体
foreach ($f in Get-ChildItem -Path "$env:USERPROFILE\Documents\terminal\*.ttf") {
    Copy-Item -Force -Path $f -Destination "C:\Windows\Fonts"
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $f.BaseName -PropertyType string -Value $f.name
}
Copy-Item -Force -Recurse -Path "Windows Terminal" -Destination "$env:USERPROFILE\AppData\Local\Microsoft"

# python
$t = "3.13.1" # 此处版本号须手动指定
Invoke-WebRequest -Uri https://www.python.org/ftp/python/$t/python-$t-amd64.exe -OutFile a.exe
Start-Process -FilePath ".\a.exe" -ArgumentList "/quiet InstallAllUsers=1 Include_launcher=0" -Wait
Remove-Item -Force -Path a.exe
& "C:\Program Files\Python$($t -replace '^(\d+)\.(\d+)\.\d+$','$1$2')\python.exe" -m venv "$env:USERPROFILE\Documents\mario"
add-path "$env:USERPROFILE\Documents\mario\Scripts"
& "$env:USERPROFILE\Documents\mario\Scripts\pip" config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# vscode
Invoke-WebRequest -Uri 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive' -OutFile a.zip
Expand-Archive -Path a.zip -DestinationPath "$env:USERPROFILE\Documents\vscode"
Remove-Item -Force -Path a.zip
New-Item -Force -Type Directory -Path "$env:USERPROFILE\Documents\vscode\data\user-data\User", "$env:USERPROFILE\Documents\vscode\tmp"
Copy-Item -Force -Path argv.json -Destination "$env:USERPROFILE\Documents\vscode\data"
Copy-Item -Force -Path settings.json -Destination "$env:USERPROFILE\Documents\vscode\data\user-data\User"
# 注册右键菜单, Set-ItemProperty 对含有 * 号的注册表路径处理有 bug, 此处用 .Net 类
$r = [Microsoft.Win32.RegistryKey]::OpenBaseKey("ClassesRoot", "Default")
foreach ($f in '*\shell\Open with VSCode', 'Directory\shell\vscode', 'Directory\Background\shell\vscode') {
    $s = $r.CreateSubKey($f, $true)
    $s.SetValue($null, "Open with VSCode", "String")
    $s.SetValue("Icon", "$env:USERPROFILE\Documents\vscode\Code.exe,0", "String")
    $s = $s.CreateSubKey("Command", $true)
    $s.SetValue($null, "$env:USERPROFILE\Documents\vscode\Code.exe `"%v`"", "String")
}
# 安装插件
$env:path += ";$env:USERPROFILE\Documents\vscode\bin"
code --force `
    --install-extension MS-CEINTL.vscode-language-pack-zh-hans `
    --install-extension ms-vscode-remote.vscode-remote-extensionpack `
    --install-extension ms-vscode.cpptools-extension-pack `
    --install-extension ms-vscode.powershell `
    --install-extension ms-vscode.hexeditor `
    --install-extension ms-python.python `
    --install-extension ms-python.black-formatter