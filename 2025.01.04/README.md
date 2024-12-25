# 制作 Windows PE
1. [参照](https://learn.microsoft.com/zh-cn/windows-hardware/manufacture/desktop/winpe-mount-and-customize),下载安装 [Windows ADK](https://go.microsoft.com/fwlink/?linkid=2196127)(只需勾选部署工具) 和 [Windows PE](https://go.microsoft.com/fwlink/?linkid=2196224)
2. 以管理员身份运行`部署和映像工具环境`
    ```cmd
    cd "..\Windows Preinstallation Environment\amd64\WinPE_OCs\"
    copype amd64 C:\pe
    dism /mount-image /imagefile:"C:\pe\media\sources\boot.wim" /index:1 /mountdir:"C:\pe\mount"

    rem 安装需要的组件
    for %i in (
        WMI NetFx Scripting PowerShell StorageWMI DismCmdlets HTA SecureStartup
        SecureBootCmdlets PlatformId FontSupport-ZH-CN
    ) do dism /add-package /image:"C:\pe\mount" /packagepath:WinPE-%i.cab

    rem 安装中文支持
    for %i in (
        WMI NetFx Scripting PowerShell StorageWMI DismCmdlets HTA SecureStartup
    ) do dism /add-package /image:"C:\pe\mount" /packagepath:zh-cn\WinPE-%i_zh-cn.cab
    dism /add-package /image:"C:\pe\mount" /packagepath:zh-cn\lp.cab
    dism /image:"C:\pe\mount" /set-allintl:zh-cn
    dism /image:"C:\pe\mount" /set-inputlocale:0804:00000804
    dism /image:"C:\pe\mount" /set-timezone:"China Standard Time"
    dism /image:"C:\pe\mount" /set-skuintldefaults:zh-cn
    ```
3. 添加初始化命令到 `C:\pe\mount\Windows\System32\startnet.cmd` 如,强行挂载所有分区并调用根目录下的 `init_pe.bat` 脚本
    ```bat
    powershell -ExecutionPolicy ByPass -NoProfile -Command "foreach ($d in Get-Partition | Where-Object { -not $_.DriveLetter }) { foreach ($c in 99..122) { $d | Set-Partition -NewDriveLetter ([char]$c) -ErrorAction SilentlyContinue; if ($?) { break } } }"
    for %%i in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist %%i:\init_pe.bat %%i:\init_pe.bat
    ```
4. 创建镜像
    ```powershell
    dism /unmount-image /mountdir:"C:\pe\mount" /commit
    makewinpemedia /iso C:\pe C:\pe.iso
    ```