# 激活 Windows 与 Office
### vlmcsd
下载 [Wind4/vlmcsd](https://github.com/Wind4/vlmcsd/releases) 服务端,防火墙放行1688端口,虽已停更但依旧好使
    ```bash
    binaries/Windows/intel/vlmcsd-Windows-x64.exe # Windows
    binaries/Linux/intel/static/vlmcsd-x64-musl-static # Linux
    ```
### Windows
根据 [KMS密钥](https://learn.microsoft.com/zh-cn/windows-server/get-started/kms-client-activation-keys) 在网上搜索对应的镜像文件,注意要有`VL`,`SW_`,`批量授权`等字样,完成系统安装后执行如下命令
    ```bat
    slmgr //b /ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
    slmgr //b /skms 192.168.xx.xx
    slmgr //b /ato
    ```

如需转换 Windows 版本,找到目标版本的系统,将 `C:\Windows\System32\spp\tokens\skus` 覆盖到要转换的系统,执行`slmgr /rilc`
### Office
1. 下载运行 [ODT工具](https://www.microsoft.com/en-us/download/details.aspx?id=49117) 得到 `setup.exe`
2. 使用 [Office自定义工具](https://config.office.com/deploymentsettings) 制作配置文件 `configuration.xml` ,以下是可以用在 `Office LTSC 2024` 的配置文件,[PIDKEY](https://learn.microsoft.com/en-us/office/volume-license-activation/gvlks) ,只安装了三件套
    ```xml
    <Configuration>
      <Add OfficeClientEdition="64" Channel="PerpetualVL2024" MigrateArch="TRUE">
        <Product ID="ProPlus2024Volume" PIDKEY="XJ2XN-FW8RK-P4HMP-DKDBV-GCVGB">
          <Language ID="zh-cn" />
          <ExcludeApp ID="Access" />
          <ExcludeApp ID="Lync" />
          <ExcludeApp ID="OneDrive" />
          <ExcludeApp ID="OneNote" />
          <ExcludeApp ID="Outlook" />
          <ExcludeApp ID="Publisher" />
        </Product>
      </Add>
      <Updates Enabled="TRUE" />
      <RemoveMSI />
      <Display Level="Full" AcceptEULA="TRUE" />
    </Configuration>
    ```
3. 获取离线安装包: `.\setup.exe /download .\configuration.xml` ,在线安装: `.\setup.exe /configure .\configuration.xml` ,若在安装 Windows 时已设置相同的 KMS 服务器,则无需任何操作,否则
    ```bat
    cd /d "C:\Program Files\Microsoft Office\Office16"
    cscript ospp.vbs /inpkey:XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
    cscript ospp.vbs /sethst:192.168.xx.xx
    cscript ospp.vbs /act
    ```
### [Microsoft Activation Scripts](https://github.com/massgravel/Microsoft-Activation-Scripts)
多合一激活脚本,详见[官网](https://massgrave.dev/)文档,利弊写的很清楚.总之就是运行 `MAS/All-In-One-Version-KL/MAS_AIO.cmd` 从4种激活方式中选一种
| 激活类型 | 支持产品 | 激活时效 | 需要联网 |
| :---: | :---: | :---: | :---: |
| HWID | Windows 10,11 | 永久 | 是 |
| Ohook | Office 2013 及之后但不包括 UWP | 永久 | 否 |
| KMS38 | Windows 10,11 和 Server 2016 及之后 | 到 2038 年 | 否 |
| Online KMS | Windows 和 Office | 180 天自动续期 | 是 |