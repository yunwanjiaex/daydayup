# Windows 10 LTSC 个人使用
### 准备工作
1. 使用 [Ventoy](https://github.com/ventoy/Ventoy)+[FirPE](https://firpe.cn/page-247) 制作安装U盘,将 `Windows 10 LTSC` 镜像解压到U盘
2. 将 [unattend.xml](./unattend.xml) 文件放到 `sources\$OEM$\$$\Panther\` ,作用是在安装完系统后直接以 `Administrator` 身份登录
3. 将 [MAS_AIO.cmd](https://github.com/massgravel/Microsoft-Activation-Scripts/blob/master/MAS/All-In-One-Version-KL/MAS_AIO.cmd) 和由其 `Extras` 出的 [SetupComplete.cmd](./SetupComplete.cmd) 一起放到 `sources\$OEM$\$$\Setup\Scripts\` 用于系统激活
4. 准备网卡驱动和其他相关驱动,解压软件 [7z](https://github.com/mcmilk/7-Zip-zstd) ,重启进入PE
### 系统配置
1. 安装网卡驱动和 `7z` ,更改主机名,更新系统,补完剩下的的驱动
2. 关闭和禁用系统还原: `SystemPropertiesAdvanced` 和 `组策略>计算机配置>管理模板>系统>系统还原>关闭系统还原>启用`
3. 使用 [power.bat](./power.bat) 开启卓越性能和关闭休眠.`控制面板\系统和安全\电源选项`从不进入睡眠,15分钟关闭屏幕,笔记本合盖睡眠
4. 杂项设置,如系统设置,任务管理器,文件资源管理器,桌面图标,回收站,记事本,拼音输入法等
5. 在控制面板和设置中禁用IE浏览器和媒体播放器,关闭防火墙
### 刚需软件
1. 使用 [windows-defender-remover](https://github.com/ionuttbara/windows-defender-remover) 删除 `Windows Defender`
2. 使用 [windows-update-disabler](https://github.com/tsgrgo/windows-update-disabler) 禁用 Windows 更新
3. 安装任务栏网速监控 [TrafficMonitor](https://github.com/zhongyang219/TrafficMonitor) ,将 [TrafficMonitor](./TrafficMonitor) 复制到 `%USERPROFILE%\Documents`,依赖 [Visual C++ 运行环境](https://aka.ms/vs/17/release/vc_redist.x64.exe)
4. [clash](https://github.com/clash-verge-rev/clash-verge-rev) 科学上网
5. [Firefox](https://download.mozilla.org/?product=firefox-esr-latest-ssl&os=win64&lang=zh-CN) 浏览器,登录后进行界面调整和相关设置,因为网络原因,插件 [uBlock Origin](https://addons.mozilla.org/zh-CN/firefox/addon/ublock-origin/) 可能无法自动同步.禁用浏览器自动更新
    ```bat
    reg add HKLM\Software\Policies\Mozilla\Firefox /f /v DisableAppUpdate /t REG_DWORD /d 1
    ```
6. 看图和视频使用 [ImageGlass](https://imageglass.org/) 和 [VLC](https://www.videolan.org/)
7. 使用 [library.ps1](./library.ps1) 清理 explorer.exe 的系统库