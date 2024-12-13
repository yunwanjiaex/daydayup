# aria2 下载器
1. 下载 [aria2](https://github.com/aria2/aria2) ,提取出 `aria2c.exe`
2. 下载 GUI 界面 [AriaNg](https://github.com/mayswind/AriaNg)(AllInOne) ,将 `index.html` 放到 `aria2c.exe` 同目录
3. 将配置文件 [aria2.conf](./aria2.conf) 放到同目录,注意修改第2行的下载目录和第47行的rpc密码,并创建空文件 `aria2.session`
4. 启动脚本 [aria2.vbs](./aria2.vbs)
5. 打开 `index.html` ,`AriaNg 设置` -> `导入 AriaNg 设置`,将 [browser.txt](./browser.txt) 内容复制到其中