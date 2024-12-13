# 制作P社凝聚力补丁
1. 以 `Stellaris` 为例,在购买了 `Paradox Interactive` 的正版游戏 DLC 的前提下,如何将其制作成补丁进行分享
2. 登录购买了正版游戏DLC的账号,下载安装所有DLC
3. 进入 `C:\Program Files (x86)\Steam\steamapps\common\Stellaris`,将 `dlc` 目录复制到桌面,可参考 [Stellaris-DLC](https://github.com/Russifiers-for-Humans/Stellaris-DLC/releases/tag/3.14)
4. 下载 [CreamAPI v5.3](https://cs.rin.ru/forum/viewtopic.php?f=29&t=70576) ,从中提取出 `steam_api64.dll`
5. 制作配置文件 `cream_api.ini` ,将DLC的ID全部写进去,同样放到桌面.可参考 [cream_api.ini](https://github.com/seuyh/stellaris-dlc-unlocker/blob/main/creamapi_launcher_files/cream_api.ini)
6. 打包好以上文件就算制作完成.安装时,先将原先游戏目录下的 `steam_api64.dll` 改为 `steam_api64_o.dll` ,然后将打包好的文件覆盖进去即可