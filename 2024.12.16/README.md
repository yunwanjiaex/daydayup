# 自解压执行文件
### Linux
```bash
#!/bin/bash
[ -d "$1" ] || exit 1
tmpfile=$(mktemp run_XXX -p .)

cat << 'EEE' > $tmpfile
#!/bin/sh
tmpdir=$(mktemp -d)
l=$(awk '/^exit/{print NR+1; exit 0; }' "$0")
tail -n+$l "$0" | tar xzpm -C $tmpdir
cd $tmpdir
[ -z "$1" ] && ./setup.sh || "$@"
exit 0
EEE

tar czpm -C "$1" . >> $tmpfile
chmod +x $tmpfile
```
* `./main.sh ./package_directory` 打包目录 `package_directory` 下的所有文件生成 `./run_XXX`
* `./run_XXX program arg1 arg2 ...` 执行, `program` 为相对 `package_directory` 的路径且有可执行权限,无参数默认执行目录下的 `setup.sh`
### Windows 其一
```powershell
param([string]$d = "AAAA:\")
if (-not (Test-Path -PathType Container -Path "$d")) {
    throw "USAGE: $($MyInvocation.MyCommand.Name) -d Directory"
}

$t1 = New-TemporaryFile
@'
set t=%temp%\%RANDOM%~%RANDOM%~%RANDOM%~%RANDOM%
md %t% & cd /d %t% & md 1
certutil -decode "%~f0" 1.zip
>>1.vbs echo set o = CreateObject("Shell.Application")
>>1.vbs echo set f = o.NameSpace("%cd%\1.zip").items
>>1.vbs echo o.NameSpace("%cd%\1").CopyHere(f)
cscript //nologo 1.vbs & cd 1
if "%1"=="" (start setup.bat) else (start %*)
exit /b
'@ | Set-Content -Path $t1

($t2 = New-TemporaryFile) | Remove-Item
Get-ChildItem -Recurse $d | Compress-Archive -Force -DestinationPath "$t2.zip"
certutil -encode "$t2.zip" $t2
Get-Content -Path $t1, $t2 | Set-Content -Path .\run.bat
Remove-Item -Force -Path $t1, $t2, "$t2.zip"
```
* `./main.ps1 -d ./package_directory` 打包得到文件 `./run.bat`
* 运行 `run.bat` 不带参数,默认执行打包目录下的 `setup.bat` ,也可以跟各种参数 `.\run.bat start.exe arg1 arg2 ...`
### Windows 其二
1. 下载[7z lzma sdk](https://7-zip.org/sdk.html)提取`bin\7zSD.sfx`
2. 将要执行的程序打包成7z文件,注意是打包目录下的文件而非目录本身
3. 配置文件 `config.txt` ,解压后执行目录下的 `test.bat` ,可以通过命令行传递参数.其他配置参考 `DOC\installer.txt`
    ```
    ;!@Install@!UTF-8!
    RunProgram="test.bat"
    ;!@InstallEnd@!
    ```
4. 制成exe文件
    ```cmd
    copy /b 7zSD.sfx + config.txt + test.7z run.exe
    ```