# Steam 游戏去 Steam
1. 使用 [Goldberg Emulator](https://github.com/Detanup01/gbe_fork) 模拟 Steam 客户端运行 Steam 游戏,仅适用于那些没有额外验证的游戏,这里以 `Oxygen Not Included (缺氧)` 为例说明
2. 复制原生游戏目录 `steamapps\common\OxygenNotIncluded` 到桌面,然后下载模拟器 `emu-win-release.7z` 解压之
3. 进入游戏目录,找到 `steam_api64.dll` ,`缺氧`的这个文件在 `OxygenNotIncluded_Data\Plugins\x86_64` 下,用模拟器中的文件 `release\regular\x64\steam_api64.dll` 替换他
4. 在 `steam_api64.dll` 同目录新建目录 `steam_settings` ,用于存放伪装 Steam 客户端的各种数据.在新目录下制作以下文件
    * `steam_appid.txt` 游戏 ID
        ```ini
        457140
        ```
    * `depots.txt` 仓库 ID
        ```ini
        457141
        1452491
        2952301
        3302471
        ```
    * `configs.app.ini` DLC ID
        ```ini
        [app::dlcs]
        unlock_all=0
        1452490=Oxygen Not Included - Spaced Out!
        2952300=Oxygen Not Included: The Frosty Planet Pack
        3302470=Oxygen Not Included: The Bionic Booster Pack
        ```
5. 双击 `OxygenNotIncluded.exe` 即可启动游戏.如果有需要联机,手柄等功能的还需要添加其他配置文件,但不在本篇讨论范围之列.有自动化工具如 [Steam-auto-crack](https://github.com/SteamAutoCracks/Steam-auto-crack)