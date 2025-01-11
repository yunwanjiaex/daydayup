# 雷电模拟器去广告
1. 雷电模拟器[海外版](https://www.ldplayer.net/other/version-history-and-release-notes.html)广告少但需要直连 `Google` (连不上约等于没广告),[国内版](https://www.ldmnq.com/other/version-history-and-release-notes.html)各种广告和弹窗起飞.这里以国内版`9.1.36`为例进行去广告,安装完成后不要运行,如果已经运行过,请先删除 `%APPDATA%\leidian9`
2. 进入模拟器安装目录找到 `dnplayer.exe` ,用二进制编辑器打开它,将 `ldmnq.com` 字样替换为其它的等长字符串,这里使用 `sed`+`xxd`
    ```bash
    # 将二进制文件转为字符串
    xxd -p dnplayer.exe | tr -d '\n' > 1.txt
    # 将 ldmnq.com 替换为 ddddd.ddd
    sed -i 's/6c646d6e712e636f6d/64646464642e646464/g' 1.txt
    # 将 Unicode 的 ldmnq.com 替换为 ddddd.ddd
    sed -i 's/6c0064006d006e0071002e0063006f006d/640064006400640064002e006400640064/g' 1.txt
    # 再将字符串转回为二进制文件
    sed -i 's/../\\x&/g' 1.txt
    printf $(cat 1.txt) > dnplayer.exe
    rm -f 1.txt
    ```
3. 添加同目录下的 `system.vmdk` 到 Linux 虚拟机中,挂载它的第2个分区 `mount --mkdir /dev/sda2 /mnt/sda2`
4. 进入 `/mnt/sda2` ,删除应用商店 `system/priv-app/ldAppStore` 和新游预约 `system/priv-app/storenter` ,并将桌面 `system/app/Launcher3/Launcher3.apk` 替换为自己喜欢的,文件名保持 `Launcher3.apk` 不变
5. 运行雷电多开器,删除所有旧的模拟器,以确保新建模拟器都是基于修改过的 `system.vmdk`