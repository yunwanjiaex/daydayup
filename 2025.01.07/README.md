# 跨平台执行的脚本
```bash
#!/usr/bin/env -S bash # 2>nul & goto MsWin

echo "Hi, I'm ${SHELL}."
read -p "press any key to continue"
exit $?

:MsWin
@echo off
echo Hello, I'm %COMSPEC%.
pause
```
* 一个可以在 Windows 和 Linux 的桌面环境下执行的脚本,在 Ubuntu 24.04 和 Windows 10 上测试通过
* 后缀为`bat`,换行符是`LF`而不是`CRLF`, Windows 下双击运行, Linux 下赋予可执行权限后右键`作为程序运行`

![hello](./hello.png)